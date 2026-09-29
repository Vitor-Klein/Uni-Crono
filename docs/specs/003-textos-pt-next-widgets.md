---
id: 003
status: implementada
depende_de: [002]
---

# Traduzir para pt os textos do next_widgets_service

> `status`: `rascunho` → `aprovada` → `implementada` (ou `descartada`). Uma spec
> só vira `aprovada` quando **Perguntas em aberto** estiver vazia. Ao fechar,
> `/destilar NNN` leva para `docs/architecture.md` e `docs/conventions.md` só o
> que ela virou estado; a spec fica aqui como histórico.

## Objetivo

O `next_widgets_service` 4.2.1 traz seus textos (`S`) só em en e es. Com o app em
pt — o idioma oficial —, o `NextWidgetsFallbackDelegate` carrega o `en`, e a folha
de acessibilidade mostra "Accessibility", "Color Blind Profile" etc. em inglês.

## Requisitos funcionais

- **RF-01:** Com o app em pt, os 16 textos do `S` do `next_widgets_service`
  aparecem em pt.
- **RF-02:** Em en e es, o app continua usando as traduções do próprio pacote.
- **RF-03:** Carregar os textos em pt não altera o `Intl.defaultLocale` global
  (o `S.load` do pacote altera).

## Critérios de aceite

- **CA-01:** Com o app em pt, a folha de acessibilidade mostra "Acessibilidade" e
  "Perfil de daltonismo", e não "Accessibility" nem "Color Blind Profile".
- **CA-02:** O `S` que o delegate de fallback entrega para pt tem, em cada um dos
  16 textos, o valor da tabela em Contratos.
- **CA-03:** O delegate de fallback não atende en nem es.
- **CA-04:** Carregar o delegate de fallback para pt não muda o
  `Intl.defaultLocale`.

## Fora de escopo

- Publicar `intl_pt.arb` no próprio `next_widgets_service` — é o conserto
  definitivo, noutro repositório; quando sair, o fallback deixa de ser
  necessário.

## Regras de negócio e invariantes

- Todo texto visível com o app em pt está em pt.

## Contratos

| Chave `S` | pt |
|---|---|
| `accessibilityDialogTitle` | Acessibilidade |
| `accessibilityTooltip` | Abrir opções de acessibilidade |
| `theme` | Tema |
| `light` | Claro |
| `dark` | Escuro |
| `colorBlindMode` | Modo daltônico |
| `apply` | Aplicar |
| `accessibility` | Acessibilidade |
| `accessibilityOpenHint` | Abrir opções de acessibilidade |
| `close` | Fechar |
| `colorBlindProfile` | Perfil de daltonismo |
| `colorBlindNormal` | Normal |
| `colorBlindProtanopia` | Protanopia |
| `colorBlindDeuteranopia` | Deuteranopia |
| `colorBlindTritanopia` | Tritanopia |
| `colorBlindAchromatopsia` | Acromatopsia |

Esboço: uma subclasse de `S` com os 16 getters em pt, entregue pelo
`NextWidgetsFallbackDelegate` quando o idioma é pt, sem passar por `S.load`.

## Dependências e impacto

- `lib/core/localization/next_widgets_fallback_delegate.dart`.

## Decisões durante a implementação

- **CA-03 nasceu verde:** é o comportamento que já existia (o `isSupported` do
  fallback já recusava en/es) e que a mudança não podia quebrar.
- Os outros idiomas não cobertos continuam caindo em `en` via `S.load` — só pt
  ganhou textos próprios.

## Perguntas em aberto
