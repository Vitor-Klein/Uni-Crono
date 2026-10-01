# Arquitetura — Uni-Crono

Como o sistema é montado **hoje**. Descreve estado, não intenção: se algo aqui
ficar defasado do código, virou ficção — corrija junto com a mudança que o defasou.

As decisões travadas ("não reabrir sem perguntar") **não** moram aqui: moram na
seção `<architecture>` do `CLAUDE.md`, que é o que o agente lê em todo turno. Aqui
fica a descrição; lá, o que não se discute.

Stack: Flutter (Dart), com os microsserviços `next_*` da BFAC.

## Visão em uma tela

Um diagrama certo poupa três parágrafos. Anote **o que cada seta significa** —
seta sem legenda é ambígua: "chama"? "depende de"? "publica evento para"?

```text
  ┌─────────────┐    (o que a seta significa)    ┌─────────────┐
  │      …      │ ─────────────────────────────▶ │      …      │
  └─────────────┘                                └─────────────┘
```

Escolha o recorte que explica **este** sistema — camadas, fluxo de dados, ou o
caminho de uma requisição de ponta a ponta. Um diagrama que serve, não três
genéricos.

## Onde mora o quê

```text
…/
├── …          # o que mora aqui
└── …          # o que mora aqui
```

## Regras de dependência

Quem pode importar quem — e principalmente **quem não pode**, que é a metade que
o código sozinho não conta:

- … depende de …
- … **não** depende de … — porque …

## Navegação

Rotas em `lib/core/navigation/app_routes.dart` (`AppRoutes`), montadas pelo
`AppRouter` (`lib/app/app_router.dart`), todas com `AppTransitions.fade` — que
respeita a preferência de "reduzir animações":

- **Fora da casca** (sem barra inferior): `/splash`, `/login`,
  `/upgrade-required`, `/webview`.
- **Casca** (`StatefulShellRoute.indexedStack`, widget `AppShell` em
  `lib/app/shell/`): quatro abas, cada uma um branch — `/dashboard` (inicial),
  `/upload`, `/activities`, `/profile`. Cada aba guarda seu estado ao trocar:
  as páginas das outras abas ficam montadas fora do palco. Tocar na aba já
  selecionada volta para a raiz dela (`goBranch(initialLocation: true)`).

A splash (`SplashScreen(duration:)`, 3 s por padrão) leva a `/dashboard`. O
`redirect` é a função pura `AppRouter.resolveRedirect`, nesta ordem:

1. a splash sempre passa;
2. com a trava de atualização bloqueando, tudo vai para `/upgrade-required`; ao
   liberar, `/upgrade-required` vai para `/dashboard` (ou `/login`, sem sessão);
3. sem sessão, toda rota que não é `/login` vai para `/login` — inclusive a
   casca e o `/webview`;
4. com sessão, `/login` vai para `/dashboard`.

O router roda o `redirect` de novo quando a trava muda **ou** quando a sessão
muda (`refreshListenable` = `Listenable.merge` da trava com um
`StreamListenable` do `SessionCubit`): entrar leva ao Dashboard e sair leva ao
login sem navegação manual.

### Sessão (login simulado)

O login não consulta servidor: a tela `/login` (`LoginPage`,
`lib/features/auth/`) valida só o formato — instituição escolhida em
`Institutions.all` (UTFPR, UFPR, PUCPR, UEL), e-mail no formato
`^[^@\s]+@[^@\s]+\.[^@\s]+$` (`isValidEmail`), senha não vazia — e mostra o erro
de cada campo, que some quando o campo é corrigido. Entrar (botão ou "concluído"
no teclado) chama `SessionCubit.signIn` com o e-mail sem espaços nas pontas.

- `Session` guarda só **e-mail e instituição**; a senha nunca sai do campo — não
  é salva, passada adiante nem registrada em log.
- `SharedPrefsSessionRepository` grava em `session_email` e
  `session_institution` (no web, `localStorage`, em texto). Ao carregar, só vale
  sessão com e-mail em formato válido e instituição da lista; qualquer outra
  coisa conta como "sem sessão".
- A sessão é lida no `AppBootstrap`, **antes do `runApp`**, e entra como estado
  inicial do `SessionCubit` (`Cubit<Session?>`): o `redirect` nunca confunde
  "carregando" com "sem sessão". Falha na leitura vira "sem sessão" e só o tipo
  do erro vai para o log.
- `SessionCubit.signOut()` apaga a sessão.
- "Esqueci?" e "Solicitar acesso" mostram "Disponível em breve".
- Os rótulos visíveis ficam fora da árvore de acessibilidade; cada campo carrega
  o seu rótulo (`_NamedField`), anunciado uma vez, com o campo.
- A validação é só de interface: com autenticação real, ela precisa existir no
  servidor.

A casca tem:

- **App bar** (`ShellAppBar`): um `NextAppBar` (o lint do projeto proíbe o
  `AppBar` do Flutter) com a marca `kAppName` (`lib/app/app_info.dart`)
  centralizada, sem botão de voltar, e o avatar com as iniciais do aluno
  (`DemoStudent`, `lib/features/profile/domain/`). O avatar é um alvo de 48dp,
  anunciado como "Abrir menu", e abre o modal "Mais" (`showHomeMoreModal`):
  Mensagens, Configurações, Compartilhar/Privacidade/Termos quando o Remote
  Config tem a URL, nome e versão do app.
- **Barra inferior** (`NavigationBar`): ícones `*_outlined`; indicador da aba
  ativa em `primaryContainer` com ícone `onPrimaryContainer`; rótulo ativo em
  `primary`, inativos em `onSurfaceVariant`.

As telas das abas ainda são provisórias (`TabPlaceholderPage`, só o título).

### Estado de notificações

"Notificações ativadas" tem um único dono: o `NotificationsCubit`
(`lib/features/notifications/presentation/`), criado na inicialização
(`lazy: false`) no `AppProviders`, sobre a interface `NotificationsPreference`
— em produção `PushNotificationsPreference`, que delega ao `PushService`. A
troca é otimista; se a gravação falha, o valor anterior volta e `setEnabled`
devolve `false`. `openNotificationsSheet(context)` abre a folha de notificações,
grava pelo Cubit e mostra o aviso de sucesso ou erro. A folha e o modal de
configurações recebem o valor atual ao abrir; não escutam o Cubit enquanto estão
abertos.

O `RemoteConfigService.get` devolve o valor padrão quando o Firebase não está
disponível, em vez de lançar exceção.

## Idioma

pt é o idioma oficial. Sem preferência salva, o `MaterialApp` recebe
`locale: const Locale('pt')` — o app abre em pt qualquer que seja o idioma do
aparelho. en e es são traduções: valem quando há uma preferência salva
(`LocaleCubit`, chave `preferred_locale`). A escolha fica no modal de
configurações (item "Idioma"), que abre a `showLanguageSheet` do
`next_widgets_service` com Português, English e Español — cada um no próprio
idioma, sem opção "Sistema".

A geração de l10n usa `lib/l10n/app_pt.arb` como referência (`l10n.yaml`), e
`AppLocalizations.supportedLocales` começa por pt. Os três ARBs têm as mesmas
chaves.

Os textos do `next_widgets_service` (`S`, usados na folha de acessibilidade) só
vêm em en e es no pacote. O `NextWidgetsFallbackDelegate`
(`lib/core/localization/`) cobre o que o pacote não cobre: em pt entrega uma
subclasse de `S` com os textos em pt, sem passar por `S.load` — que alteraria o
`Intl.defaultLocale` global; qualquer outro idioma não coberto cai em `en`.

## Tema e design system

O app renderiza **só o tema claro**: o `MaterialApp` recebe `themeMode:
ThemeMode.light` e não tem `darkTheme`. A escolha de tema do menu de
acessibilidade continua lá e é salva pelo `AppThemeCubit`, mas não muda o que é
renderizado.

O tema é montado em duas camadas:

1. **`AppThemeFactory`** (`next_core_service`), alimentado pelo `_LightConfig` de
   `lib/core/theme/template_theme_provider.dart`. Ele monta só dez papéis de cor
   (`primary`, `secondary`, `tertiary`, `error`, `surface` e seus `on*`), uma
   `fontFamily` (Inter) e as cores de quatro estilos de texto.
2. **O `builder` do `MaterialApp`** (`lib/app/app.dart`) acrescenta o que o factory
   não monta, a partir de `lib/core/theme/app_tokens.dart`:
   - `AppColorRoles.applyTo` — `primaryContainer`, `surfaceContainer*`,
     `onSurfaceVariant`, `outline*`, `errorContainer`/`onErrorContainer`;
   - `AppTypography.applyTo` — a escala tipográfica;
   - o estilo dos botões preenchidos (`primaryContainer`/`onPrimaryContainer`) e
     o acento de TextButton, Switch, progresso e seleção (`accent1` = `primary`).

**Filtro de daltonismo:** toda cor do tema passa por
`AppColorBlindUtils.applyColorBlindFilter` **exatamente uma vez**. As do factory
já saem filtradas (inclusive `accent1`); as literais de `app_tokens.dart` são
filtradas no `builder` pelo `f()`. Filtrar de novo uma cor que veio do factory
aplica a matriz duas vezes.

### Cores (tema claro)

| Papel | Hex | Papel | Hex |
|---|---|---|---|
| `primary` | `#755B00` | `onPrimary` | `#FFFFFF` |
| `primaryContainer` | `#FECB29` | `onPrimaryContainer` | `#6F5600` |
| `secondary` | `#5B5F61` | `onSecondary` | `#FFFFFF` |
| `surface` | `#F9F9F9` | `onSurface` | `#1A1C1C` |
| `surfaceContainerLowest` | `#FFFFFF` | `onSurfaceVariant` | `#4E4633` |
| `surfaceContainerLow` | `#F3F3F4` | `outline` | `#807660` |
| `surfaceContainer` | `#EEEEEE` | `outlineVariant` | `#D2C5AC` |
| `surfaceContainerHigh` | `#E8E8E8` | `error` / `onError` | `#BA1A1A` / `#FFFFFF` |
| `surfaceContainerHighest` | `#E2E2E2` | `errorContainer` / `onErrorContainer` | `#FFDAD6` / `#93000A` |

O fundo das telas é `surface`; cards e folhas ficam nos `surfaceContainer*`. O
texto do tema é opaco: `onSurface` no principal, `onSurfaceVariant` em
`bodyMedium`/`bodySmall`. Todo par texto/fundo do esquema tem contraste ≥ 4.5:1.

### Tipografia

Montserrat nos títulos, Inter no resto — ambas empacotadas em `assets/fonts/`
(TTF estáticos, licença OFL ao lado), sem download em runtime. A licença de cada
família é registrada no `LicenseRegistry` na inicialização
(`FontLicenses.register()` em `AppBootstrap.initialize()`), lida de
`assets/fonts/<Família>-OFL.txt` só quando a tela de licenças pede. Uma família
nova em `AppTypography` precisa do seu `*-OFL.txt` declarado como asset.

| Estilo | Família | Peso | Tamanho / altura | Letter-spacing |
|---|---|---|---|---|
| `displayMedium` | Montserrat | 600 | 48 / 1.10 | −0.96 |
| `headlineLarge` | Montserrat | 700 | 36 / 1.11 | 0 |
| `headlineMedium` | Montserrat | 600 | 32 / 1.20 | −0.32 |
| `headlineSmall` | Montserrat | 600 | 28 / 1.20 | 0 |
| `titleLarge` | Montserrat | 500 | 24 / 1.30 | 0 |
| `titleMedium` | Inter | 500 | 18 / 1.60 | 0 |
| `bodyLarge` | Inter | 400 | 16 / 1.60 | 0 |
| `bodyMedium` | Inter | 400 | 14 / 1.50 | 0 |
| `labelLarge` | Inter | 600 | 14 / 1.00 | 0.70 |
| `labelSmall` | Inter | 700 | 10 / 1.50 | 0.50 (caixa alta aplicada no texto) |

### Espaçamento, raios, sombras

Constantes em `app_tokens.dart`:

- `AppSpacing` — grade de 4: `xs 4`, `sm 8`, `md 12`, `lg 16`, `xl 24`, `xxl 32`,
  `xxxl 48`, `section 80`; `screenGutter` = 24 (margem lateral das telas).
- `AppRadii` — `xs 2`, `sm 4`, `md 8`, `lg 12`, `pill 9999`.
- `AppShadows` — `sm`, `md`, `lg`: sombras de 5% de opacidade, a `lg` com tom
  dourado.

## Onde entra código novo

- Cor, fonte, espaçamento, raio ou sombra de design: em
  `lib/core/theme/app_tokens.dart` (ou no `_LightConfig`, se for um dos papéis que
  o factory monta) — nunca literal no widget. Os widgets herdados do template
  (`app_modal`, `notifications_sheet`, …) ainda têm raios e cores literais.
- Código de … vai em `…`.

Se duas coisas parecidas moram em lugares diferentes, é aqui que se diz como não
confundir as duas. É o erro mais caro de quem chega no projeto.
