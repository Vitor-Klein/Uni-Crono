---
id: 008
status: implementada
depende_de: [006]
---

# Mostrar o progresso de horas no Dashboard

> `status`: `rascunho` → `aprovada` → `implementada` (ou `descartada`). Uma spec
> só vira `aprovada` quando **Perguntas em aberto** estiver vazia. Ao fechar,
> `/destilar NNN` leva para `docs/architecture.md` e `docs/conventions.md` só o
> que ela virou estado; a spec fica aqui como histórico.

## Objetivo

Tela "Dashboard de Horas" do Figma sobre um repositório de horas em memória. É
esse repositório que o upload (009) altera e que o resumo do Perfil (010) lê.

## Requisitos funcionais

- **RF-01:** O Dashboard mostra o progresso de Horas Complementares e Horas de
  Extensão: horas acumuladas, meta e barra de progresso.
- **RF-02:** Mostra a lista "Aprovados recentemente", do mais novo ao mais
  antigo.
- **RF-03:** Quando o repositório muda, o Dashboard atualiza sem recarregar.
- **RF-04:** "Ver todos" mostra o aviso "Disponível em breve".

## Critérios de aceite

- **CA-01:** Com os dados iniciais, o Dashboard mostra "Horas Complementares"
  com "130 horas" e "200 no total", e "Horas de Extensão" com "45 horas" e "100
  no total"; as barras estão em 0,65 e 0,45.
- **CA-02:** A lista "Aprovados recentemente" mostra, nesta ordem: Workshop de
  Tecnologia Comunitária (+15 h, Horas de Extensão), Seminário Avançado de
  Python (+8 h, Horas Complementares), University Game Jam 2024 (+24 h, Horas
  Complementares), cada um com "Aprovado".
- **CA-03:** Adicionar ao repositório um certificado de 10 h em Horas
  Complementares faz o Dashboard mostrar "140 horas" e o certificado no topo da
  lista, sem trocar de tela.
- **CA-04:** O repositório calcula o resumo: horas totais (175), certificados
  aprovados (3) e percentual da meta somada das duas categorias (58%).
- **CA-05:** A barra de progresso nunca passa de 1,0, mesmo com horas acima da
  meta.
- **CA-06:** "Ver todos" mostra "Disponível em breve".

## Fora de escopo

- Lista completa de certificados, filtros, reprovados/pendentes.

## Regras de negócio e invariantes

- Horas de uma categoria = horas-base da categoria + soma dos certificados
  aprovados nela. As horas-base representam o histórico antes do protótipo:
  98 h complementares e 30 h de extensão — com os três certificados iniciais,
  dá exatamente os 130 h e 45 h do Figma.
- O percentual da meta arredonda para baixo.
- Cada abertura do app começa dos mesmos dados iniciais.

## Contratos

```dart
enum HourCategory { complementary, extension }

class ApprovedCertificate {
  final String id;
  final String title;
  final HourCategory category;
  final int hours;
  final DateTime approvedAt;
}

class CategoryProgress { final HourCategory category; final int hours; final int goal; }

class HoursSummary { final int totalHours; final int certificates; final int goalPercent; }

abstract class HoursRepository {
  Stream<HoursSnapshot> watch(); // emite o estado atual ao assinar
  Future<void> add(ApprovedCertificate certificate);
}
// HoursSnapshot: List<CategoryProgress> progress, List<ApprovedCertificate> recent,
// HoursSummary summary.
// InMemoryHoursRepository: horas-base por categoria + os três certificados
// iniciais; metas 200 (complementares) e 100 (extensão).
```

- Leiaute (Figma "Dashboard de Horas"): título "Progresso acadêmico"
  (`headlineSmall`); card por categoria (`surfaceContainerLowest`, raio
  `AppRadii.md`, `AppShadows.sm`) com título `titleLarge`, subtítulo
  `bodyLarge`/`onSurfaceVariant`, barra `LinearProgressIndicator` (trilha
  `surfaceContainer`, valor `primary`), "130 horas" `labelLarge w700` e "200 no
  total" `labelLarge`; seção "Aprovados recentemente" `titleLarge` + "Ver
  todos" `TextButton`; item com ícone, título `titleMedium`, categoria
  `bodyMedium`, "+15 h" `labelLarge w700 primary` e "Aprovado".
- Subtítulos: Complementares "Atividades extracurriculares", Extensão
  "Envolvimento com a comunidade".
- Provido no `AppProviders` como `RepositoryProvider<HoursRepository>`.

## Dependências e impacto

- Novo `lib/features/hours/`.
- `lib/app/app_providers.dart`, a aba Dashboard da casca, ARBs.

## Decisões durante a implementação

- **`BehaviorSubject` do `rxdart`** (dependência que já existia) entrega o
  estado atual a quem assina o `watch()`, sem esperar a próxima mudança.
- **`HoursRepository.dispose()` entrou no contrato:** o `RepositoryProvider`
  fecha o stream quando a árvore sai.
- **Datas fictícias dos certificados iniciais** (20/09, 12/09 e 30/08/2026)
  fixam a ordem da lista. Os títulos ficam em pt nos três idiomas: são dados,
  não interface.
- **CA-03 no widget nasceu verde:** o Cubit já assinava o stream desde o card de
  progresso. O comportamento está travado pelo teste de unidade do repositório
  e pelo teste de widget.
- **Barras anunciadas com categoria e horas** ("Horas Complementares", "130 de
  200 horas"): no Flutter 3.47 o papel "progressBar" só aceita número como
  valor, então a barra fica sob `Semantics(label, value)` + `ExcludeSemantics` e
  perde esse papel. Achado da revisão da tarefa, junto com horas e meta, que
  ficavam juntas à esquerda em vez de nas pontas do card.
- **Testes da lista com tela alta (800×2000):** o `ListView` é preguiçoso e,
  na tela padrão de teste, os itens nem eram construídos. Telas estreitas com
  rolagem ficam com os testes de 320dp e 360dp a 1,5×.
- **Ícone do card acima do título, num círculo** (como o dos itens da lista),
  em vez de ao lado dele como no Figma: em 360dp com texto "Grande", o título
  dividia a linha com o ícone e quebrava no meio da palavra
  ("Complementare/s", es "Complementaria/s"). Sem o ícone na linha, o título tem
  a largura toda. Achado da verificação manual; o teste de telas estreitas não
  pegava porque não há estouro. O teste carrega a Montserrat real para medir.
  Limite conhecido: em 320dp com "Grande", ou a 1,5×, uma palavra de 14 letras
  não cabe em `titleLarge` e ainda quebra; o Flutter não hifeniza.

## Perguntas em aberto

