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

## Idioma

pt é o idioma oficial. Sem preferência salva, o `MaterialApp` recebe
`locale: const Locale('pt')` — o app abre em pt qualquer que seja o idioma do
aparelho. en e es são traduções: valem quando há uma preferência salva
(`LocaleCubit`, chave `preferred_locale`). O app ainda não tem seletor de idioma
na interface.

A geração de l10n usa `lib/l10n/app_pt.arb` como referência (`l10n.yaml`), e
`AppLocalizations.supportedLocales` começa por pt. Os três ARBs têm as mesmas
chaves.

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
(TTF estáticos, licença OFL ao lado), sem download em runtime.

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
