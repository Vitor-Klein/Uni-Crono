---
id: 018
status: implementada
depende_de: [001, 014]
---

# Ligar o tema escuro

> `status`: `rascunho` → `aprovada` → `implementada` (ou `descartada`). Uma spec
> só vira `aprovada` quando **Perguntas em aberto** estiver vazia. Ao fechar,
> `/destilar NNN` leva para `docs/architecture.md` e `docs/conventions.md` só o
> que ela virou estado; a spec fica aqui como histórico.

## Objetivo

O menu de acessibilidade já oferece Sistema / Claro / Escuro e salva a escolha,
mas o app só desenha o tema claro (decisão travada até aqui). A escolha passa a
valer: com "Escuro", ou "Sistema" num aparelho escuro, todas as telas ficam
escuras.

Reabre a decisão travada "só tema claro", a pedido de quem decide o produto.

## Requisitos funcionais

- **RF-01:** O tema segue a escolha salva: Claro → claro; Escuro → escuro;
  Sistema → o do aparelho.
- **RF-02:** O tema escuro tem a paleta da marca: fundo preto-amarronzado,
  cartões um pouco mais claros que o fundo, texto creme e o dourado como
  acento (abaixo).
- **RF-03:** No header escuro, o chapéu e o "Uni" ficam creme sobre o selo
  dourado-escuro; "Cronos" mantém o amarelo `#FFD238`; os ícones da barra de
  status ficam claros.
- **RF-04:** Todo par texto/fundo do tema escuro tem contraste de pelo menos
  4,5:1, e toda cor passa pelo filtro de daltonismo exatamente uma vez — as
  mesmas regras do claro.

## Critérios de aceite

- **CA-01:** Com "Escuro" salvo, o app desenha o tema escuro, com cada papel de
  cor igual à tabela abaixo.
- **CA-02:** Com "Sistema" salvo e o aparelho escuro, o app desenha o escuro;
  com o aparelho claro, o claro. Com "Claro" salvo, sempre o claro.
- **CA-03:** Escolher "Escuro" no menu de acessibilidade salva a escolha e
  troca o app para o escuro na hora.
- **CA-04:** No escuro, todo par texto/fundo do esquema tem contraste ≥ 4,5:1.
- **CA-05:** No escuro, os papéis vindos de `app_tokens.dart` passam pelo filtro
  de daltonismo exatamente uma vez.
- **CA-06:** No escuro, a barra de status do header pede ícones claros.
- **CA-07:** No escuro, Dashboard, Enviar, Atividades e Perfil abrem sem
  estourar e sem nenhum fundo branco (`#FFFFFF`).

## Fora de escopo

- Trocar a paleta clara.
- Imagens (splash, ícones): ficam as mesmas nos dois temas.

## Regras de negócio e invariantes

- Nenhum widget escolhe cor pelo tema: todos leem do `ColorScheme`; a troca de
  claro para escuro é só de tokens.
- `AppColorRoles.applyTo` escolhe os valores pelo brilho do esquema que recebe.

## Contratos

Paleta escura (factory em `_DarkConfig`, o resto em `AppColorRoles`):

| Papel | Hex | Papel | Hex |
|---|---|---|---|
| `primary` | `#F2C14E` | `onPrimary` | `#3D2F00` |
| `primaryContainer` | `#5A4500` | `onPrimaryContainer` | `#FFE08B` |
| `primaryFixedDim` | `#FFD238` | `tertiary` | `#F3E6C8` |
| `secondary` | `#C4C7C9` | `onSecondary` | `#2D3133` |
| `surface` | `#15130F` | `onSurface` | `#EDE7DB` |
| `surfaceContainerLowest` | `#221F19` | `onSurfaceVariant` | `#D3C8B1` |
| `surfaceContainerLow` | `#2B2720` | `outline` | `#9C917A` |
| `surfaceContainer` | `#353028` | `outlineVariant` | `#4F4738` |
| `surfaceContainerHigh` | `#403A31` | `error` / `onError` | `#FFB4AB` / `#690005` |
| `surfaceContainerHighest` | `#4B443A` | `errorContainer` / `onErrorContainer` | `#93000A` / `#FFDAD6` |

`surfaceContainerLowest` é o fundo dos cartões nas duas paletas: no claro é o
branco; no escuro, um tom acima do fundo, para o cartão se destacar.

## Dependências e impacto

- `lib/app/app.dart` (`themeMode` e `darkTheme`).
- `lib/core/theme/template_theme_provider.dart` (`_DarkConfig`),
  `lib/core/theme/app_tokens.dart` (`AppColorRoles` por brilho).
- `lib/app/shell/shell_app_bar.dart` (barra de status).
- `test/app_theme_test.dart`: os testes CA-06 e CA-07 (spec 001) afirmavam que o
  escuro salvo **não** muda o desenho; passam a afirmar o contrário, porque a
  regra mudou. `test/dark_theme_test.dart` (novo).
- `CLAUDE.md` (decisão travada de tema), `docs/architecture.md`.

## Decisões durante a implementação

- `AppColorRoles` deixou de ser uma lista de constantes e virou dois conjuntos
  (`light` e `dark`); o `applyTo` escolhe pelo brilho do esquema que recebe.
- O `_DarkConfig` do template (acento roxo, fundo cinza-azulado) foi trocado
  pela paleta da marca; o `surface` escuro é a cor da tela, como no claro.
- O teste "Sistema segue o aparelho" virou dois testes, um por brilho: montar
  o app duas vezes no mesmo teste reaproveitava a árvore e não lia o tema novo.

## Perguntas em aberto

