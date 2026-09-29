# docs/ — Uni-Crono

Toda a documentação do projeto mora aqui. Ela se divide em duas naturezas que não
se misturam:

- **Estado** — `architecture.md` e `conventions.md`: o sistema como ele é hoje.
- **Processo** — `specs/` e `plans/`: o que se decidiu fazer, e como.

Fluxo de trabalho: **spec-driven development + TDD**.

## Os papéis

| Arquivo | Muda com que frequência | Quem lê |
|---|---|---|
| `CLAUDE.md` (raiz) | Quase nunca — só em decisão de arquitetura | A IA, em todo turno |
| `architecture.md` · `conventions.md` | A cada spec que muda o sistema | Quem chega no projeto |
| `specs/NNN-*.md` | Durante a vida da feature; depois fica como histórico | Quem implementa e quem revisa |
| `plans/` | Durante a implementação | Quem implementa |

## O laço

```
1. A spec nasce em specs/, copiando specs/_template.md.
2. Preencher. Deixar "Perguntas em aberto" honesta — é aqui que a spec ganha ou perde.
3. Revisar juntos. A spec só vira status: aprovada quando "Perguntas em aberto" está VAZIA.
4. Abrir o turno: "implemente a spec NNN".
5. Ciclo RED-GREEN-REFACTOR, um CA por vez (workflow no CLAUDE.md).
6. Fechar: status: implementada + "Decisões durante a implementação" com o que divergiu.
7. Destilar com /destilar NNN: o que a spec virou estado entra em architecture.md e
   conventions.md; a spec fica em specs/ como histórico.
8. Revisar antes do commit com /revisar NNN.
```

As seções que alimentam o passo 7 são fixas: **Regras de negócio e invariantes**,
**Contratos**, **Estratégia de teste específica** e **Decisões durante a
implementação** são as que viram estado; **Dependências e impacto** é de onde o
`/destilar` tira o escopo a conferir no código. Sem esses nomes na spec, o
`/destilar` não tem o que ler.

## A regra que impede a spec de apodrecer

Todo teste referencia o ID do critério de aceite no nome:

```
CA-03: rejeita pedido sem itens com 422
```

Assim `grep -r "CA-03" test/` responde "isso está implementado?" em um segundo. O
teste que lê esse CA fica ligado à spec que o definiu. A numeração sequencial da
spec garante rastreabilidade — desde o turno até o commit que fecha a feature.

## Numeração

As specs seguem `001`, `002`, … sequencial, nunca reaproveitado. Feature
abandonada fica com `status: descartada` e continua em `specs/`: o histórico do
que você decidiu *não* fazer vale tanto quanto o que foi implementado.

## Mantendo em dia

`architecture.md` e `conventions.md` descrevem estado, não intenção. Se um deles
ficar defasado do código, ele virou ficção — corrija junto com a mudança que o
defasou, ou deixe o `/destilar` fazer isso ao fechar a spec.
