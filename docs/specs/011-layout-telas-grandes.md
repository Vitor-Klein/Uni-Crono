---
id: 011
status: rascunho
depende_de: [006, 007, 008, 009, 010]
---

# Adaptar o app para telas grandes (web em computador)

> `status`: `rascunho` → `aprovada` → `implementada` (ou `descartada`). Uma spec
> só vira `aprovada` quando **Perguntas em aberto** estiver vazia. Ao fechar,
> `/destilar NNN` leva para `docs/architecture.md` e `docs/conventions.md` só o
> que ela virou estado; a spec fica aqui como histórico.

## Objetivo

O protótipo foi desenhado e construído para celular (Figma de 390px). No web em
computador ele estica as telas de celular na largura toda. Esta spec adapta a
casca e as telas para janelas largas, depois que as telas do protótipo
(007–010) estiverem prontas — para adaptar o que existe, e não um alvo em
movimento.

## Requisitos funcionais

- …

## Critérios de aceite

- …

## Fora de escopo

- Tablet e celular na horizontal, a menos que a resposta às perguntas abaixo os
  inclua.

## Regras de negócio e invariantes

- O layout de celular (até o primeiro ponto de quebra) continua exatamente como
  está.

## Contratos

## Dependências e impacto

- `lib/app/shell/` (casca e navegação), as telas das specs 007–010.

## Decisões durante a implementação

- …

## Perguntas em aberto

- [ ] Pontos de quebra: a partir de que largura muda o layout (ex.: 600 e
  1024)? Tablet entra?
- [ ] Navegação em tela larga: `NavigationRail` lateral, menu lateral fixo
  (sidebar) ou a mesma barra inferior?
- [ ] Conteúdo: largura máxima centralizada (coluna de leitura) ou telas que
  aproveitam a largura (ex.: Dashboard em grade, Hub em colunas de cards)?
- [ ] Existe referência visual para desktop, ou o design sai do design system
  atual?
