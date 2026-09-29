---
id: 001
status: implementada
depende_de: []
---

# Aplicar a fundação do design system ao tema do app

> `status`: `rascunho` → `aprovada` → `implementada` (ou `descartada`). Uma spec
> só vira `aprovada` quando **Perguntas em aberto** estiver vazia. Ao fechar,
> `/destilar 001` leva para `docs/architecture.md` e `docs/conventions.md` só o
> que ela virou estado; a spec fica aqui como histórico.

## Objetivo

O tema atual é o do template (cinza/índigo, claro e escuro). O design do Uni Cronos
(Figma, Page 1 — 4 telas mobile de 390px) tem outra identidade: esquema tonal
Material 3 a partir do amarelo `#FECB29`, Montserrat nos títulos e Inter no corpo.
Esta spec troca a **fundação** — cores, tipografia, espaçamento, raios, sombras e
modo de tema — para que as specs de tela que vêm depois só consumam tokens, sem
hex nem tamanho de fonte solto.

O arquivo do Figma não tem estilos, variáveis nem componentes (export do Google
Stitch): todos os valores abaixo foram **inferidos** das ocorrências na Page 1 e
arredondados para a escala quando o valor era ruído de exportação (ex.: gap de
`168.06`).

Decisões já tomadas: marca **Uni Cronos**; idioma oficial pt (en/es como tradução);
**só tema claro** por enquanto.

## Requisitos funcionais

- **RF-01:** O `ColorScheme` do tema claro carrega todos os papéis de cor usados
  pelo design (tabela em Contratos), não só os dez que o `AppThemeFactory` monta.
- **RF-02:** Todo papel de cor, inclusive os adicionais, passa pelo filtro de
  daltonismo do perfil ativo — exatamente uma vez.
- **RF-03:** O `TextTheme` segue a escala tipográfica do design: Montserrat em
  display/headline/title-large, Inter em title-medium/small, body e label.
- **RF-04:** Montserrat e Inter vão empacotadas no app e funcionam sem rede.
- **RF-05:** O app renderiza sempre no tema claro, qualquer que seja a
  preferência salva ou o brilho do sistema. A escolha de tema continua no menu de
  acessibilidade — a preferência é salva, mas não muda a renderização enquanto
  não houver tema escuro.
- **RF-06:** Espaçamento, raios e sombras ficam disponíveis como constantes
  nomeadas para as telas consumirem.
- **RF-07:** Botão preenchido (CTA) usa o amarelo do design; o acento dos
  elementos interativos (TextButton, Switch, progresso, seleção de texto) usa a
  primária dourada, não o índigo do template.
- **RF-08:** O texto do tema é opaco e segue o design: `onSurface` (`#1A1C1C`) no
  texto principal e `onSurfaceVariant` (`#4E4633`) no secundário — no lugar do
  `black87`/`black54` translúcidos que o `next_core_service` aplica por padrão.
  *(Acrescentado durante a implementação, aprovado.)*

## Critérios de aceite

- **CA-01:** Com perfil de daltonismo `normal`, o `ColorScheme` do tema ativo tem
  exatamente os valores da tabela de cores em Contratos, papel a papel.
- **CA-02:** Com um perfil de daltonismo diferente de `normal`, cada papel
  adicional (`primaryContainer`, `surfaceContainer*`, `outline`, `outlineVariant`,
  `onSurfaceVariant`, `errorContainer`, `onErrorContainer`,
  `onPrimaryContainer`) é igual a
  `AppColorBlindUtils.applyColorBlindFilter(<hex da tabela>, perfil)` — filtrado
  uma vez, nem zero nem duas.
- **CA-03:** Cada estilo do `TextTheme` listado na tabela tipográfica tem a
  família, o peso, o tamanho, a altura de linha e o espaçamento entre letras da
  tabela.
- **CA-04:** Os arquivos de fonte de Montserrat e Inter declarados no
  `pubspec.yaml` carregam do bundle do app (`rootBundle`) sem erro.
- **CA-05:** Todo par texto/fundo da tabela de contraste tem razão ≥ 4.5:1.
- **CA-06:** Com preferência salva `dark`, e também com `system` e
  `platformBrightness` escuro, o app renderiza com `Brightness.light`.
- **CA-07:** A folha de acessibilidade continua oferecendo a escolha de tema;
  escolher `escuro` nela salva a preferência e o app continua renderizando com
  `Brightness.light`.
- **CA-08:** `FilledButton` e `ElevatedButton` pintam o fundo com
  `primaryContainer` e o texto com `onPrimaryContainer`; `TextButton`, `Switch`,
  indicador de progresso e cursor usam `primary`.
- **CA-09:** Os estilos da tabela tipográfica pintam o texto com `onSurface`,
  exceto `bodyMedium` e `bodySmall`, que usam `onSurfaceVariant`.

## Fora de escopo

- Telas (Login, Hub, Lançar Certificado, Dashboard), navegação inferior e app bar —
  specs seguintes, que consomem estes tokens.
- Nome do app em `MaterialApp.title`, ícone, splash e textos de marca ("EduHours" →
  "Uni Cronos") — vão junto com a primeira spec de tela.
- Trocar o ARB de referência de `app_en.arb` para `app_pt.arb` (idioma oficial) —
  spec própria.
- Tema escuro.
- Componentes reutilizáveis (card, chip, campo de texto) — nascem na spec da
  primeira tela que os usa.

## Regras de negócio e invariantes

- Nenhum widget fora de `lib/core/theme/` declara cor, família de fonte, raio ou
  sombra literal: tudo vem de `Theme.of(context)` ou das constantes de tokens.
- O filtro de daltonismo é aplicado exatamente uma vez a cada cor do tema.
- O app só tem tema claro: `darkTheme` e `themeMode` nunca produzem
  `Brightness.dark`.
- Todo par texto/fundo do esquema mantém contraste ≥ 4.5:1 (WCAG AA, texto
  normal).

## Contratos

Esboço — os nomes de classe são proposta; os **valores** são o contrato.

### Cores (tema claro)

| Papel `ColorScheme` | Hex | Onde aparece no design |
|---|---|---|
| `primary` | `#755B00` | ícones ativos, links, acento |
| `onPrimary` | `#FFFFFF` | — (derivado) |
| `primaryContainer` | `#FECB29` | botão principal, destaque |
| `onPrimaryContainer` | `#6F5600` | texto sobre o amarelo |
| `secondary` | `#5B5F61` | uso pontual (3 ocorrências) |
| `surface` | `#F9F9F9` | fundo das telas |
| `surfaceContainerLowest` | `#FFFFFF` | cards, navegação inferior |
| `surfaceContainerLow` | `#F3F3F4` | |
| `surfaceContainer` | `#EEEEEE` | chips, trilha de progresso |
| `surfaceContainerHigh` | `#E8E8E8` | campos |
| `surfaceContainerHighest` | `#E2E2E2` | bordas de card |
| `onSurface` | `#1A1C1C` | texto principal |
| `onSurfaceVariant` | `#4E4633` | texto secundário |
| `outline` | `#807660` | borda de campo |
| `outlineVariant` | `#D2C5AC` | divisores |
| `error` | `#BA1A1A` | — (padrão do esquema tonal M3; o Figma só tem o par de container) |
| `onError` | `#FFFFFF` | — (derivado) |
| `errorContainer` | `#FFDAD6` | |
| `onErrorContainer` | `#93000A` | |

### Tipografia

| Estilo `TextTheme` | Família | Peso | Tamanho | Altura | Letter-spacing | Uso no design |
|---|---|---|---|---|---|---|
| `displayMedium` | Montserrat | 600 | 48 | 1.10 | −0.96 | título "Opportunity Hub" |
| `headlineLarge` | Montserrat | 700 | 36 | 1.11 | 0 | título "Curate Record" |
| `headlineMedium` | Montserrat | 600 | 32 | 1.20 | −0.32 | título do card destaque |
| `headlineSmall` | Montserrat | 600 | 28 | 1.20 | 0 | título de tela, marca no login |
| `titleLarge` | Montserrat | 500 | 24 | 1.30 | 0 | título de card/seção |
| `titleMedium` | Inter | 500 | 18 | 1.60 | 0 | título de item de lista |
| `bodyLarge` | Inter | 400 | 16 | 1.60 | 0 | corpo, campos |
| `bodyMedium` | Inter | 400 | 14 | 1.50 | 0 | descrição de card |
| `labelLarge` | Inter | 600 | 14 | 1.00 | 0.70 | botões, chips, rótulos de campo |
| `labelSmall` | Inter | 700 | 10 | 1.50 | 0.50 | tag de categoria (caixa alta aplicada no texto) |

A marca na app bar usa Montserrat 700 24 — é `titleLarge` com `w700`, sem estilo
próprio.

### Espaçamento, raios, sombras

```dart
abstract final class AppSpacing {
  static const double xs = 4, sm = 8, md = 12, lg = 16, xl = 24, xxl = 32,
      xxxl = 48, section = 80;
  static const double screenGutter = xl; // margem lateral das telas
}

abstract final class AppRadii {
  static const double xs = 2, sm = 4, md = 8, lg = 12, pill = 9999;
}

abstract final class AppShadows {
  // Consolidação das 11 sombras do design (2–5% de opacidade) em 3 níveis.
  static const sm = [BoxShadow(color: Color(0x0D000000), offset: Offset(0, 1), blurRadius: 2)];
  static const md = [BoxShadow(color: Color(0x0D000000), offset: Offset(0, 4), blurRadius: 6, spreadRadius: -1)];
  static const lg = [BoxShadow(color: Color(0x0D735C00), offset: Offset(0, 10), blurRadius: 40, spreadRadius: -10)];
}
```

### Fontes

TTF estáticos em `assets/fonts/`, com a licença `OFL.txt` de cada família ao lado,
declarados na seção `fonts:` do `pubspec.yaml` com o `weight` de cada arquivo:

- `Montserrat`: 500, 600, 700
- `Inter`: 400, 500, 600, 700

### Ícones

`Icons.*_outlined` do SDK do Flutter (Material Symbols Outlined é o traço do
design). Nenhum pacote de ícones novo.

### Pares de contraste (CA-05)

`onSurface`/`surface`, `onSurfaceVariant`/`surface`, `primary`/`surface`,
`onSurface`/`surfaceContainerLowest`, `onPrimaryContainer`/`primaryContainer`,
`onPrimary`/`primary`, `onError`/`error`, `onErrorContainer`/`errorContainer`.

Conta de referência: `onPrimaryContainer`/`primaryContainer` dá ≈ 4.58:1 — passa,
mas com pouca folga.

## Dependências e impacto

- `lib/core/theme/template_theme_provider.dart` — valores do `_LightConfig`,
  `TemplateCtaColors`; o comentário que cita `hooks/test/contrast_gate_test.dart`
  aponta para um arquivo que não existe — o teste de contraste do CA-05 o
  substitui.
- `lib/core/theme/` — novo arquivo de tokens (espaçamento, raios, sombras, papéis
  de cor adicionais, `TextTheme`).
- `lib/app/app.dart` — o `builder` já estende o tema (CTA e acento); passa a
  estender `colorScheme` e `textTheme`, e a forçar o tema claro.
- `lib/features/settings/presentation/settings_modal.dart` — a ação de tema
  fica; só não muda mais a renderização.
- `pubspec.yaml` e `assets/fonts/` — fontes.
- `next_core_service` 2.0.0 (dependência, não se edita): `AppThemeFactory` só
  monta dez papéis de cor, uma `fontFamily` e quatro estilos de texto — o resto
  tem que ser acrescentado pelo app.

## Estratégia de teste específica

Os testes do tema montam `MyApp` com `debugHome` (como `test/widget_test.dart`) e
leem `Theme.of(context)` do widget renderizado — é o tema que o usuário vê, já com
o `builder` aplicado, e não o `ThemeData` do factory isolado. Contraste é
calculado com `Color.computeLuminance()`.

## Decisões durante a implementação

- **Defeito corrigido fora da lista de impacto:** `lib/core/widgets/app_modal.dart`
  disparava a asserção de debug "ListTile … ink splashes may be invisible" ao
  abrir o modal de ajustes — o efeito de toque dos itens era pintado no
  `Material` da bottom sheet, abaixo da decoração, e ficava invisível. O teste do
  CA-07 expôs o defeito; a correção é um `Material` transparente entre a
  decoração e a lista.
- **CAs que nasceram verdes (desvio consciente do RED):** CA-07 (o comportamento
  veio junto com o CA-06), CA-02 (o filtro foi ligado no CA-01) e CA-05 (a tabela
  já estava aplicada). Cada um foi validado por mutação: sem filtro e com filtro
  duplo (CA-02), e `onPrimaryContainer` clareado para 2.67:1 (CA-05) — os testes
  falham nos mutantes.
- **`TemplateCtaColors` removida:** existia porque o `ColorScheme` do factory não
  tinha um par para o CTA; com `primaryContainer`/`onPrimaryContainer` no esquema,
  o botão lê do esquema e a classe ficou sem função.
- **Acento:** `accent1Color` virou a primária dourada na origem (config), não só
  no `builder` — `message_card` e `messages_drawer_header` também leem `accent1`.
- **Fonte base:** `fontFamily` do tema claro virou `Inter`, para que os estilos
  fora da tabela (ex.: `bodySmall`, `labelMedium`) também saiam em Inter.
- **`darkTheme` retirado do `MaterialApp`**, junto com `themeMode: ThemeMode.light`
  — sem uso quando o modo é fixo.
- **Gates:** `<quality_gates>` do `CLAUDE.md` foi preenchido; `flutter analyze`
  de CLI não roda plugins, então `dart run custom_lint` entrou como gate próprio.
- **RF-06 sem teste:** `AppSpacing`, `AppRadii` e `AppShadows` são constantes sem
  comportamento; testá-las só repetiria o código.
- **Fontes:** Montserrat de `JulietaUla/Montserrat` (master), Inter da release
  v4.1 de `rsms/inter` (`extras/ttf/`).
- **RF-08 / CA-09 acrescentados no meio da implementação:** o factory pinta
  `titleLarge`/`titleMedium` com `black87` e `bodyMedium`/`bodySmall` com
  `black54` translúcidos. Aprovado fixar `textPrimaryColor`/`textSecondaryColor`
  no config — assim as cores passam pelo filtro do próprio factory, uma vez.
- **Verificação manual (web, 390×844):** fontes, cores, efeito de toque do modal
  e "Escuro" salvo sem mudar a renderização conferidos no navegador. Vistos de
  passagem, fora do escopo: título da aba "uni_cronos" (`MaterialApp.title`) e
  textos da folha de acessibilidade do `next_widgets_service` em inglês
  ("Accessibility", "Color Blind Profile").

## Perguntas em aberto

