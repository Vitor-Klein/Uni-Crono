# Arquitetura — Uni-Crono

Como o sistema é montado **hoje**. Descreve estado, não intenção: se algo aqui
ficar defasado do código, virou ficção — corrija junto com a mudança que o defasou.

As decisões travadas ("não reabrir sem perguntar") **não** moram aqui: moram na
seção `<architecture>` do `CLAUDE.md`, que é o que o agente lê em todo turno. Aqui
fica a descrição; lá, o que não se discute.

Stack: Flutter (Dart), com os microsserviços `next_*` da BFAC; Supabase
(Auth, Postgres, Storage) como servidor, sem servidor próprio. Os PDFs dos
certificados são lidos no próprio app (`pdfrx`).

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

- **Fora da casca** (sem barra inferior): `/splash`, `/login`, `/signup`,
  `/upgrade-required`, `/webview`.
- **Casca** (`StatefulShellRoute.indexedStack`, widget `AppShell` em
  `lib/app/shell/`): quatro abas, cada uma um branch — `/dashboard` (inicial),
  `/upload` (com `/upload/manual` dentro, ainda com a barra inferior),
  `/activities`, `/profile`. Cada aba guarda seu estado ao trocar: as páginas
  das outras abas ficam montadas fora do palco. Tocar na aba já selecionada
  volta para a raiz dela (`goBranch(initialLocation: true)`).
- **Estado da casca:** o `UploadCubit` (arquivo escolhido e envio) e o
  `ProfileCubit` (perfil e resumo das horas) nascem no `pageBuilder` da casca.
  Sair da conta tira o app da casca e descarta os dois.

A splash (`SplashScreen(duration:)`, 3 s por padrão) leva a `/dashboard`. O
`redirect` é a função pura `AppRouter.resolveRedirect`, nesta ordem:

1. a splash sempre passa;
2. com a trava de atualização bloqueando, tudo vai para `/upgrade-required`; ao
   liberar, `/upgrade-required` vai para `/dashboard` (ou `/login`, sem sessão);
3. sem sessão, toda rota que não é `/login` nem `/signup` vai para `/login` —
   inclusive a casca e o `/webview`;
4. com sessão, `/login` e `/signup` vão para `/dashboard`.

O router roda o `redirect` de novo quando a trava muda **ou** quando a sessão
muda (`refreshListenable` = `Listenable.merge` da trava com um
`StreamListenable` do `SessionCubit`): entrar leva ao Dashboard e sair leva ao
login sem navegação manual.

### Conta e sessão

A conta é do Supabase Auth (e-mail e senha). O app só conhece a chave
publicável do projeto.

- **`AuthGateway`** (`lib/features/auth/data/`): `current`, `changes()`,
  `signIn`, `signUp`, `signOut`; em produção, `SupabaseAuthGateway`. As
  recusas são `AuthFailure` tipadas — `InvalidCredentials`,
  `WrongInstitution`, `EmailAlreadyRegistered`, `ConfirmationRequired`,
  `NetworkFailure` —, cada uma com a sua mensagem (`authFailureMessage`).
- **`Session`:** id do usuário, e-mail e instituição. A instituição vem dos
  metadados da conta (`user_metadata.institution_id`), sem requisição; conta
  sem instituição de `Institutions.all` não entra.
- **O SDK guarda e renova a sessão.** `Supabase.initialize` roda em
  `AppBootstrap.connectAccountServer()`, antes do `runApp`: o `SessionCubit`
  começa da sessão que o SDK ainda tem, e o `redirect` nunca confunde
  "carregando" com "sem sessão".
- **`SessionCubit`** (`Cubit<Session?>`): `signIn(email, password,
  institutionId)` só emite a sessão depois de conferir que a conta é da
  instituição escolhida; se não for, encerra a sessão no servidor e lança
  `WrongInstitution`. Do servidor, o cubit só aceita o fim da sessão (saiu em
  outro lugar, venceu sem renovação). O `changes()` do gateway descarta os
  erros que o SDK põe no stream de sessão.
- **Login** (`LoginPage`): instituição, e-mail (`isValidEmail`) e senha; erro
  por campo e um erro do formulário (`FormError`, anunciado pelo leitor de
  tela). "Esqueci?" mostra "Disponível em breve"; "Criar conta" abre `/signup`.
- **Cadastro** (`SignUpPage`): nome, instituição, curso, período (1 a 12),
  e-mail e senha (8 caracteres ou mais). O perfil vai como metadados do
  cadastro; o gatilho `handle_new_user` cria a linha de `profiles`, e os checks
  da tabela recusam dado inválido no servidor. Com a confirmação de e-mail
  ligada no painel, o cadastro mostra "Conta criada. Confirme o e-mail para
  entrar.".
- Os campos das duas telas vêm de `auth_form_fields.dart` (`LabeledField`,
  `InstitutionField`, `PasswordField`): o rótulo visível fica fora da árvore de
  acessibilidade e o campo carrega o rótulo, anunciado uma vez.
- A senha só vai para o SDK: não é salva, passada adiante nem registrada em log.

A casca tem:

- **Header** (`ShellAppBar`, no `Scaffold.appBar`, 72dp): widget próprio, sem
  `AppBar` (o lint do projeto o proíbe) e sem `NextAppBar` (que só centraliza um
  título de texto). À esquerda, o selo redondo `primaryContainer` com o chapéu
  **preenchido** (`Icons.school`, em `tertiary`) e a marca `kAppName`
  (`lib/app/app_info.dart`) em `headlineSmall` Bold, em duas cores: "Uni" em
  `tertiary` e "Cronos" em `primaryFixedDim` — como logotipo, dispensada do
  contraste mínimo de texto. Em tela estreita a marca encolhe para caber, em
  vez de ser cortada. Sem botão de voltar. À direita, o botão "mais"
  (`Icons.more_vert_outlined` num círculo branco): alvo de 48dp, anunciado como
  "Abrir menu", que abre o modal "Mais" (`showHomeMoreModal`): Mensagens,
  Configurações, Compartilhar/Privacidade/Termos quando o Remote Config tem a
  URL, nome e versão do app.
- **O Perfil não tem header:** a página cuida da barra de status (`SafeArea`) e
  abre no cartão do aluno.
- **Barra inferior** (`NavigationBar`): ícones `*_outlined`; indicador da aba
  ativa em `primaryContainer` com ícone `onPrimaryContainer`; rótulo ativo em
  `primary`, inativos em `onSurfaceVariant`.

As abas: Dashboard (ver **Horas**), Enviar (**Envio de certificado**),
Atividades (**Hub de Oportunidades**) e Perfil (**Perfil**).

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

## Horas

As horas do aluno vêm do `HoursRepository` (`lib/features/hours/data/`), provido
no `AppProviders` como `RepositoryProvider<HoursRepository>`, acima de todos os
`BlocProvider`. O `dispose` do provider fecha o repositório.

- **Contrato:** `watch()` entrega o último `HoursSnapshot` e cada mudança — uma
  carga que falha chega como erro `HoursLoadFailure`; `refresh()` carrega de
  novo; `dispose()` fecha.
- **Em produção é o `SupabaseHoursRepository`:** lê `certificates` do aluno
  (`id`, `title`, `category`, `hours`, `approved_at`), filtrando por `user_id`
  e do mais novo ao mais antigo. Linha que o app não entende (categoria
  desconhecida, horas fora de 1 a 999) falha a carga em vez de ser somada. No
  sign-out ele esquece o snapshot: o repositório vive acima do router, e o
  próximo aluno no aparelho não vê as horas do anterior.
- **`HoursSnapshot.fromCertificates`** (função pura, em
  `lib/features/hours/domain/`) aplica as regras:
  - horas de uma categoria = soma dos certificados dela; aluno novo começa
    em 0 h;
  - metas (`HoursSnapshot.goals`): 35 h complementares e 200 h de extensão —
    as da UTFPR, usadas para todas as instituições;
  - o percentual do resumo é a soma das horas sobre a soma das metas,
    arredondado para baixo;
  - a barra de progresso (`CategoryProgress.ratio`) para em 1,0, mesmo com as
    horas acima da meta;
  - a % de cada categoria (`CategoryProgress.percent`) é inteira, arredondada
    para baixo e para em 100;
  - `recent` traz todos os certificados, do mais novo ao mais antigo.
- **`DashboardPage`:** o `DashboardCubit` (`DashboardState`: snapshot ou falha)
  assina o repositório e chama `refresh()` ao abrir. Carregando, indicador; com
  falha, "Não foi possível carregar suas horas" e "Tentar de novo"; sem
  certificados, "Nenhum certificado ainda". Como a casca mantém as abas
  montadas, um certificado novo já aparece ao voltar.
- **A página é um `ListView` preguiçoso** com:
  - um card branco por categoria (`AppRadii.xl`, `AppShadows.lg`). No topo, o
    ícone num selo dourado suave e, na outra ponta, a % da meta num selo
    (`CategoryProgress.ratio`, logo nunca acima de 100%). O título vem **abaixo**
    do ícone, e não ao lado como no Figma, para ter a largura toda e não quebrar
    no meio da palavra em telas estreitas com texto grande. Depois vêm o
    subtítulo e a barra, e embaixo as horas e a meta, nas duas pontas;
  - a seção "Aprovados recentemente", com "Ver todos" ("Disponível em breve"):
    um card por certificado, com as horas num selo e "Aprovado" com um ícone
    de confirmação; sem certificados, um quadro vazio com ícone.
- **Leitor de tela:** cada barra é anunciada com a categoria e "N de M horas",
  em `Semantics(label, value)` com a barra dentro de `ExcludeSemantics`. Por
  isso ela não tem o papel de barra de progresso, que só aceita um número como
  valor.

## Supabase

Projeto `uni-cronos` (org KleinOS, `sa-east-1`). As migrações moram em
`supabase/migrations/`; os testes de banco, em `supabase/tests/` — SQL que roda
numa transação desfeita no fim e levanta exceção a cada asserção que falha.

| Tabela / bucket | Quem lê | Quem escreve |
|---|---|---|
| `profiles` (`full_name`, `institution_id`, `course`, `term`) | o próprio aluno | o gatilho `handle_new_user`, a partir dos metadados do cadastro |
| `certificates` (`title`, `issuer`, `category`, `hours` 1–999, `file_path`, `file_sha256`, `source` `extracted`/`manual`, `approved_at`; único por aluno e SHA-256) | o próprio aluno | o próprio aluno, só com o próprio `user_id`; ninguém altera nem apaga |
| `opportunities` (curso ou evento, categoria, horas, quem oferece, modalidade, início, link `https`, destaque, publicada) | aluno autenticado, só as publicadas | migração ou painel |
| bucket `certificates` (privado, 10 MB, só PDF) | o aluno, na própria pasta `<uid>/` | o aluno envia e apaga na própria pasta |

- RLS ligada em todas as tabelas de `public`. O papel `anon` não lê nada; o
  `authenticated` só grava certificado com o próprio `user_id` e não altera
  nem apaga linha nenhuma.
- O app só conhece a chave publicável. Como quem grava o certificado é o app,
  quem chamar a API direto pode lançar horas sem PDF de verdade: risco aceito.
- O catálogo inicial são seis exemplos fictícios: quem oferece leva
  "(exemplo)" e os links apontam para `example.com`.

## Envio de certificado

A aba Enviar (`lib/features/upload/`) lê o PDF no próprio aparelho e conta as
horas; elas entram sem tela de conferência.

- **Escolha:** `CertificatePicker` (em produção, `FilePickerCertificatePicker`,
  só PDF). O app aceita o arquivo que termina em `.pdf`, tem até 10 MB e começa
  com `%PDF-` (`isAcceptedCertificate`); senão, "Use um PDF de até 10 MB".
- **Leitura:** `PdfTextExtractor` (em produção, `PdfrxTextExtractor`: o texto
  das até 10 primeiras páginas, pelo PDFium; "" quando o PDF não tem texto ou
  não abre) e as regras de `readCertificate` (abaixo).
- **Lançamento:** `CertificateLauncher`; em produção, o
  `SupabaseCertificateLauncher`:
  - sem texto ou sem carga horária, nada sobe: `Unreadable`, com o arquivo e o
    título lido, e o app abre o formulário manual;
  - o aluno já tem esse PDF (mesmo SHA-256): `Duplicate`, sem upload;
  - senão, sobe o PDF para `certificates/<uid>/<uuid v4>.pdf` e grava o
    certificado (`source` `extracted`, ou `manual` pelo formulário). Se a
    gravação falha, o PDF que subiu é apagado; violação do único por aluno e
    SHA-256 também é `Duplicate`;
  - sem rede ou com o servidor recusando: `ReaderUnavailable`.
- **Estado:** o `UploadCubit` (arquivo, arquivo recusado, enviando, falha, PDF
  pendente) nasce na casca, para `/upload` e `/upload/manual` trabalharem no
  mesmo arquivo.
- **Lançado** (`finishLaunch`): recarrega as horas, esvazia a aba, mostra
  "Certificado lançado: +N h em <categoria>" e vai ao Dashboard. Vindo do
  formulário, primeiro leva a aba Enviar de volta a `/upload` e só no frame
  seguinte vai ao Dashboard, para a aba não reabrir no formulário.
- **Formulário manual** (`/upload/manual`, `ManualEntryPage`): título
  preenchido pela leitura, horas de 1 a 999 e categoria (Horas Complementares
  por padrão). "Cancelar" volta a `/upload` com o arquivo ainda escolhido. O
  formulário é um `SingleChildScrollView`, não uma lista preguiçosa: campo
  construído fora da tela sairia do `Form` e escaparia da validação.
- A tela segue a "Lançar Certificado" do Figma; a área tracejada é um
  `CustomPainter` com os tokens (`outlineVariant`, `AppRadii.lg`). Não há
  arrastar e soltar.

## Leitura do certificado

Regras de `lib/features/upload/domain/certificate_reading.dart`, sobre o texto
sem acentos e em minúsculas (`foldText`, `lib/core/utils/fold_text.dart`):

- **horas:** o número depois de "carga horária" (até 40 caracteres entre os
  dois); senão a primeira duração (`8h`, `10h30`, `20 horas`, `12 hrs`,
  `40 (quarenta) horas`) que não seja hora do relógio (precedida de "às",
  "das" ou "até"). Minutos são descartados; fora de 1 a 999, não há horas;
- **categoria:** extensão se o texto fala em "extensão" ou "extensionista";
  senão, complementares;
- **título:** o nome entre aspas depois de "participou d(o|a)", "concluiu o
  curso" ou "evento"; senão o trecho depois dos dois primeiros marcadores, até a
  vírgula ou o ponto; senão o nome do arquivo, cada palavra com inicial
  maiúscula. No máximo 120 caracteres;
- **emissor:** o nome da instituição da conta, quando aparece no texto.

## Hub de Oportunidades

A aba Atividades (`lib/features/opportunities/`) lista o catálogo do
`OpportunityRepository` (em produção, `SupabaseOpportunityRepository`: só as
publicadas).

- `visibleOpportunities` (função pura): os filtros Todas / Cursos / Eventos /
  Extensão / Complementares (um por vez) e a busca por título, descrição e quem
  oferece valem juntos (E). A busca ignora maiúsculas e acentos
  (`foldText`). O destaque vem primeiro; os outros, por data de início.
- Linha do catálogo que o app não entende é pulada (o resto aparece); link que
  não é `https` é descartado. "Inscrever-se" só aparece com link e abre fora do
  app pelo `LinkOpener` (`lib/core/utils/link_opener.dart`; em produção, o
  navegador do sistema).
- Carregando, indicador; com falha, "Não foi possível carregar as
  oportunidades" e "Tentar de novo"; puxar para baixo recarrega; sem resultado,
  "Nenhuma oportunidade encontrada".
- O destaque é um card com bloco ilustrado (ícone do tipo sobre
  `surfaceContainer`, no lugar da foto do Figma) e botão preenchido; os outros
  são cards com botão contornado. O controlador da busca pertence à página,
  porque a lista é preguiçosa.

## Perfil

A aba Perfil (`lib/features/profile/`) mostra o `ProfileCubit` da casca: o
`StudentProfile` do `ProfileRepository` (em produção,
`SupabaseProfileRepository`: a linha de `profiles` do aluno, com o e-mail da
conta) e o `HoursSummary` do mesmo `HoursRepository` do Dashboard — os dois
nunca divergem.

O amarelo é acento, nunca fundo de cartão: os cartões são brancos
(`surfaceContainerLowest`, `AppRadii.xl`) e os ícones ficam em selos dourados
suaves.

- Cartão do aluno: avatar grande com as iniciais (`StudentProfile.initials`),
  nome, e-mail e uma pílula com "instituição · curso · Nº período"; abaixo de
  uma divisória, o resumo — horas lançadas, certificados e percentual da meta —,
  cada número com seu ícone, separados por divisórias verticais.
- "PREFERÊNCIAS", num cartão: Notificações, Idioma e Acessibilidade, com seta,
  abrem as mesmas folhas do modal de configurações (`openNotificationsSheet`;
  `openLanguageSheet` e `openAccessibilitySheet`, de
  `lib/features/settings/presentation/settings_sheets.dart`).
- "CONTA", num cartão: "Sair", em `error` e sem seta, pede confirmação ("Sair
  da conta?") e chama `SessionCubit.signOut()`.
- Com falha, "Não foi possível carregar seu perfil" e "Tentar de novo" no lugar
  da identidade, dentro do cartão.

## Configuração

Os valores públicos de build vêm de `--dart-define-from-file=config/app.json`
(fora do git; o formato está em `config/app.example.json`), lidos por
`AppConfig` (`lib/core/config/`): `SUPABASE_URL` e `SUPABASE_PUBLISHABLE_KEY`.
Sem eles, o `main()` mostra `ConfigMissingApp` (a mensagem diz como rodar) em
vez do app. No VS Code, o `.vscode/launch.json` já passa o arquivo.

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
   - `AppColorRoles.applyTo` — `primaryContainer`/`onPrimaryContainer`,
     `primaryFixedDim`, `tertiary` (substitui o do factory), `surfaceContainer*`,
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
| `primaryFixedDim` | `#F0B400` | `tertiary` | `#1E3A6E` |
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
`primaryFixedDim` e `tertiary` são cores da marca (o "Cronos" e o chapéu do
header), não papéis de texto: o dourado sobre `surface` não chega a 4.5:1 e só
aparece no logotipo.

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
- `AppRadii` — `xs 2`, `sm 4`, `md 8`, `lg 12`, `xl 20` (cartões grandes e a
  folha do modal), `pill 9999`.
- `AppShadows` — `sm`, `md`, `lg`: sombras de 5% de opacidade, a `lg` com tom
  dourado.

## Onde entra código novo

- Cor, fonte, espaçamento, raio ou sombra de design: em
  `lib/core/theme/app_tokens.dart` (ou no `_LightConfig`, se for um dos papéis que
  o factory monta) — nunca literal no widget. Os widgets herdados do template
  (`notifications_sheet`, …) ainda têm raios e cores literais; o `app_modal`
  já usa os tokens.
- Código de … vai em `…`.

Se duas coisas parecidas moram em lugares diferentes, é aqui que se diz como não
confundir as duas. É o erro mais caro de quem chega no projeto.
