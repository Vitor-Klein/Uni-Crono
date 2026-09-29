---
id:
status: rascunho
depende_de: []
---

# Título curto e verbal

> `status`: `rascunho` → `aprovada` → `implementada` (ou `descartada`). Uma spec
> só vira `aprovada` quando **Perguntas em aberto** estiver vazia. Ao fechar,
> `/destilar NNN` leva para `docs/architecture.md` e `docs/conventions.md` só o
> que ela virou estado; a spec fica aqui como histórico.

## Objetivo

O que muda e por quê.

## Requisitos funcionais

O comportamento esperado, em linguagem direta — o que o sistema deve fazer, não como.

- …

## Critérios de aceite

Cada critério ganha um ID. Todo teste referencia o ID — `grep -r "CA-01" test/`
responde "isso está implementado?" em um segundo.

- **CA-01:** …
- **CA-02:** …

## Fora de escopo

O que esta spec deliberadamente **não** faz.

## Regras de negócio e invariantes

O que precisa ser verdade **sempre**, não só no fluxo acima. É a seção que vira
`docs/architecture.md` na destilação — escreva como afirmação sobre o sistema.

- …

## Contratos

Cole o real: tipos, JSON, schema, assinatura, evento. Descrição em prosa vira
alucinação. Também vai para `docs/architecture.md`.

```…
…
```

## Dependências e impacto

Os arquivos e sistemas que esta spec toca. É daqui que o `/destilar` tira o
escopo a conferir no código ao fechar a spec — se ficar vazia, ele para e
pergunta em vez de adivinhar.

- …

## Estratégia de teste específica

Só entra aqui o que **foge** do padrão de teste do projeto. Se não foge, a
seção fica vazia — e seção vazia se apaga, não se preenche com "nada a
declarar". Vai para `docs/conventions.md`, e só se virou regra permanente do
projeto; se for particularidade desta spec, fica só aqui.

- …

## Decisões durante a implementação

Preencher **depois**, ao fechar a spec. Só o que divergiu do planejado e por quê.
A decisão que ficou travada vai para o `CLAUDE.md`; o enredo do desvio fica aqui.

- …

## Perguntas em aberto

- [ ] …
