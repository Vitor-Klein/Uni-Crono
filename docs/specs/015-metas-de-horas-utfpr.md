---
id: 015
status: implementada
depende_de: [008, 014]
---

# Usar as metas de horas da UTFPR: 35 h complementares e 200 h de extensão

> `status`: `rascunho` → `aprovada` → `implementada` (ou `descartada`). Uma spec
> só vira `aprovada` quando **Perguntas em aberto** estiver vazia. Ao fechar,
> `/destilar NNN` leva para `docs/architecture.md` e `docs/conventions.md` só o
> que ela virou estado; a spec fica aqui como histórico.

## Objetivo

As metas do app (200 h complementares, 100 h de extensão) não são as da UTFPR,
que pede **35 h complementares** e **200 h de extensão**. As metas passam a ser
essas, iguais para todas as instituições: não se sabe ainda se UFPR, PUCPR e
UEL seguem a mesma regra.

## Requisitos funcionais

- **RF-01:** A meta de horas complementares é 35 h; a de extensão, 200 h.
- **RF-02:** As metas são as mesmas para todas as instituições.
- **RF-03:** A % da meta no cartão de cada categoria do Dashboard é calculada
  com inteiros e arredondada para baixo, como o percentual do resumo, e para em
  100%.

## Critérios de aceite

- **CA-01:** Com os certificados de demonstração, as complementares mostram
  130 de 35 h (barra cheia, "100%") e a extensão 45 de 200 h (barra em 0,225,
  "22%").
- **CA-02:** O resumo do Perfil com os certificados de demonstração mostra
  "175 h", "5" e "74%" (175 de 235 h).
- **CA-03:** Sem certificados: 0 de 35 h, 0 de 200 h e 0% da meta.
- **CA-04:** A % do cartão arredonda para baixo: 45 de 200 h é "22%", não 23%.

## Fora de escopo

- Metas por instituição (vira spec própria quando houver as regras das outras).
- Metas configuráveis pelo servidor.

## Regras de negócio e invariantes

- `HoursSnapshot.goals` é a fonte única das metas; Dashboard e Perfil leem dela.
- Toda % de meta é inteira, arredondada para baixo, e a barra para em 1,0.

## Contratos

```dart
// lib/features/hours/domain/hours.dart
static const goals = {
  HourCategory.complementary: 35,
  HourCategory.extension: 200,
};

class CategoryProgress {
  /// Share of the goal reached, in whole percent, rounded down and capped
  /// at 100.
  int get percent;
}
```

## Dependências e impacto

- `lib/features/hours/domain/hours.dart`,
  `lib/features/hours/presentation/dashboard_page.dart`.
- Testes que escrevem a regra antiga (200/100): `test/hours_snapshot_test.dart`,
  `test/dashboard_page_test.dart`, `test/profile_page_test.dart`,
  `test/visual_refresh_test.dart` — os valores esperados mudam porque a regra
  mudou; o comportamento que verificam é o mesmo.
- `docs/architecture.md` (seção **Horas**).

## Decisões durante a implementação

- **O selo de % do Dashboard deixou de usar ponto flutuante** (`ratio * 100`
  arredondado), que poderia dar 22 ou 23 para 45 de 200; passou a usar
  `CategoryProgress.percent`, com inteiros, como o resumo.
- Os testes das specs 008, 010 e 014 que escreviam 200/100, 0,65/0,45, 58% e
  65%/45% tiveram os valores esperados trocados pela regra nova, sem mudar o
  que verificam.

## Perguntas em aberto

