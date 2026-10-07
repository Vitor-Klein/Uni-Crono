---
id: 016
status: implementada
depende_de: [010, 014]
---

# Modernizar a página de Atividades (Hub de Oportunidades)

> `status`: `rascunho` → `aprovada` → `implementada` (ou `descartada`). Uma spec
> só vira `aprovada` quando **Perguntas em aberto** estiver vazia. Ao fechar,
> `/destilar NNN` leva para `docs/architecture.md` e `docs/conventions.md` só o
> que ela virou estado; a spec fica aqui como histórico.

## Objetivo

Levar o Hub para o mesmo visual do Dashboard e do Perfil (014), sem mudar o
conteúdo nem o comportamento: título com ícone, busca mais bonita, filtros e
cartões mais limpos.

## Requisitos funcionais

- **RF-01:** "Hub de Oportunidades" ganha, ao lado, o ícone da aba
  (`explore_outlined`) num selo amarelo, como o chapéu do header; o título usa
  o tamanho do título do Dashboard (`headlineSmall`).
- **RF-02:** A busca vira um campo branco, arredondado em pílula, com sombra
  suave e lupa; mantém o rótulo "Buscar oportunidades" e o texto de ajuda.
- **RF-03:** Os filtros ficam em pílulas: o selecionado em `primaryContainer`,
  os outros brancos com borda fina.
- **RF-04:** Os cartões ficam brancos, mais arredondados (`AppRadii.xl`), com a
  sombra suave dourada; o ícone do tipo vai num selo dourado suave; as horas,
  num selo com relógio. O destaque mantém o bloco ilustrado no topo, agora em
  dourado suave.
- **RF-05:** Tudo o mais fica: textos, ordem, filtros, busca, "Inscrever-se"
  (preenchido no destaque, contorno nos outros), vazio, carregando, erro e
  puxar para recarregar.

## Critérios de aceite

- **CA-01:** O título "Hub de Oportunidades" fica sozinho, sem selo nem ícone,
  grande (`headlineLarge`, Bold); num celular de 360dp, quebra em "Hub de" sobre
  "Oportunidades" inteira.
- **CA-02:** A busca é um campo arredondado em pílula, com a lupa, e continua
  anunciada como "Buscar oportunidades".
- **CA-03:** As horas de cada cartão ficam num selo junto do ícone de relógio.
- **CA-04:** Os testes do Hub (010) continuam passando sem mudança, inclusive em
  320dp a 1x e 360dp a 1,5x.

## Fora de escopo

- Mudar conteúdo, filtros, ordem ou o que "Inscrever-se" faz.
- Botão de limpar a busca.

## Dependências e impacto

- `lib/features/opportunities/presentation/opportunities_page.dart`.
- Testes: `test/hub_refresh_test.dart` (novo).
- `docs/architecture.md` (leiaute do Hub).

## Decisões durante a implementação

- **Sem ícone no título.** O selo amarelo com `explore_outlined` ao lado de
  "Hub de Oportunidades" (RF-01) foi feito e depois retirado a pedido; o
  título ficou sozinho em `headlineSmall`, e o CA-01 passou a exigir isso.
- O título deixou o `displayMedium` do Figma; passou pelo `headlineSmall` e, a
  pedido, ficou no `headlineLarge` (36px Bold), para chamar mais atenção.

## Perguntas em aberto

