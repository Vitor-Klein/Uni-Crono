# Dashboard de Horas — Plano de implementação

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** A aba Dashboard mostra o progresso de horas (Complementares e Extensão) e os certificados aprovados recentemente, sobre um repositório em memória que o upload (009) e o Perfil (010) vão usar.

**Architecture:** `lib/features/hours/` com tipos de domínio (`HourCategory`, `ApprovedCertificate`, `CategoryProgress`, `HoursSummary`, `HoursSnapshot`), `HoursRepository` + `InMemoryHoursRepository` (dados) sobre um `BehaviorSubject` do `rxdart` — quem assina recebe o estado atual na hora e cada `add` emite um novo — e `DashboardCubit` + `DashboardPage` (apresentação). O repositório é provido no `AppProviders` (`RepositoryProvider<HoursRepository>`); a aba `/dashboard` passa a mostrar a `DashboardPage`.

**Tech Stack:** Flutter 3.47.1 / Dart ^3.11, flutter_bloc 9.1.1, rxdart ^0.28.0 (já no `pubspec.yaml`), go_router 17.5.0, next_widgets_service 4.2.1 (`NextSnack`).

**Spec:** `docs/specs/008-dashboard-de-horas.md`

## Global Constraints

- Um critério de aceite por vez. O teste vermelho é escrito e rodado pelo coordenador antes do despacho; o implementador faz GREEN + REFACTOR e não altera o teste sem declarar.
- Gates, todos zerados, ao fim de cada task: `flutter analyze` · `dart run custom_lint` · `flutter test` (sem linhas `Warning:`) · `dart format --output=none --set-exit-if-changed lib test`.
- Nome de teste começa com o ID: `CA-NN: …`, descrevendo comportamento; testes em inglês, em `test/` sem subpastas. Toque em widget que pode estar fora da tela vem depois de `tester.ensureVisible`.
- Nenhuma cor, fonte, raio ou sombra literal em widget novo: `Theme.of(context)`, `AppSpacing`, `AppRadii`, `AppShadows` (`lib/core/theme/app_tokens.dart`). Nada de `TextStyle(...)` literal.
- Ícones: `Icons.*_outlined` do SDK. Alvos de toque ≥ 40×40.
- Todo texto visível de interface entra nos três ARBs (`lib/l10n/app_{pt,en,es}.arb`, referência pt; placeholders declarados no `app_pt.arb` com `@chave`) e se regenera com `flutter gen-l10n`. Os títulos dos certificados fictícios são dados, em pt. Avisos com `NextSnack.showNextSnack`.
- Comentários de código de produção sem vocabulário de processo (nada de "spec", "CA-", "RF-").
- Commits: Conventional Commits em pt, `git add` seletivo, **sem** `Co-Authored-By`, sem push.

## Review Focus

- **Horas acima da meta** (o aluno passou das 200 h): a barra para em 100%, os números continuam reais ("210 horas") — teste na Task 1.
- **Duas instâncias do repositório** (abrir o app de novo): cada uma começa dos mesmos dados iniciais, e mexer numa não afeta a outra — teste na Task 1.
- **Quem assina depois de um `add`** (o Perfil abre depois do upload): recebe o estado já com o certificado novo, não o inicial — teste na Task 1.
- **Título de certificado longo numa tela estreita** (320dp, ou 360dp com texto a 1,5×): quebra linha, não estoura — teste na Task 4.
- **O Dashboard atualiza sozinho** quando o repositório muda, sem trocar de aba — teste na Task 3.

---

### Task 1: Domínio e repositório de horas em memória (CA-01, CA-02, CA-03, CA-04, CA-05 — regra pura)

**Files:**
- Create: `lib/features/hours/domain/hours.dart`
- Create: `lib/features/hours/data/hours_repository.dart`
- Test: `test/hours_repository_test.dart`

**Interfaces:**
- Produces:
  - `enum HourCategory { complementary, extension }`
  - `class ApprovedCertificate { const ApprovedCertificate({required String id, required String title, required HourCategory category, required int hours, required DateTime approvedAt}); }`
  - `class CategoryProgress { const CategoryProgress({required HourCategory category, required int hours, required int goal}); double get ratio; }` — `ratio` = `hours / goal` limitado a `[0, 1]`.
  - `class HoursSummary { const HoursSummary({required int totalHours, required int certificates, required int goalPercent}); }`
  - `class HoursSnapshot { const HoursSnapshot({required List<CategoryProgress> progress, required List<ApprovedCertificate> recent, required HoursSummary summary}); CategoryProgress of(HourCategory category); }`
  - `abstract class HoursRepository { Stream<HoursSnapshot> watch(); Future<void> add(ApprovedCertificate certificate); void dispose(); }`
  - `class InMemoryHoursRepository implements HoursRepository` — metas 200/100, horas-base 98/30, três certificados iniciais.

- [ ] **Step 1: Escrever o teste que falha** — `test/hours_repository_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';

import 'package:uni_cronos/features/hours/data/hours_repository.dart';
import 'package:uni_cronos/features/hours/domain/hours.dart';

void main() {
  late InMemoryHoursRepository repository;

  setUp(() => repository = InMemoryHoursRepository());
  tearDown(() => repository.dispose());

  test('CA-01: the initial data is 130 of 200 complementary hours and 45 of '
      '100 extension hours', () async {
    final snapshot = await repository.watch().first;

    final complementary = snapshot.of(HourCategory.complementary);
    final extension = snapshot.of(HourCategory.extension);
    expect((complementary.hours, complementary.goal), (130, 200));
    expect((extension.hours, extension.goal), (45, 100));
    expect(complementary.ratio, closeTo(0.65, 1e-9));
    expect(extension.ratio, closeTo(0.45, 1e-9));
  });

  test('CA-02: the recent list is newest first', () async {
    final snapshot = await repository.watch().first;

    expect(
      [
        for (final c in snapshot.recent) (c.title, c.hours, c.category),
      ],
      [
        (
          'Workshop de Tecnologia Comunitária',
          15,
          HourCategory.extension,
        ),
        ('Seminário Avançado de Python', 8, HourCategory.complementary),
        ('University Game Jam 2024', 24, HourCategory.complementary),
      ],
    );
  });

  test('CA-04: the summary is 175 hours, 3 certificates and 58% of the '
      'goal', () async {
    final summary = (await repository.watch().first).summary;

    expect(
      (summary.totalHours, summary.certificates, summary.goalPercent),
      (175, 3, 58),
    );
  });

  test('CA-03: adding a certificate adds its hours and puts it first, for '
      'current and later listeners', () async {
    await repository.add(
      ApprovedCertificate(
        id: 'new',
        title: 'Certificado Game Jam',
        category: HourCategory.complementary,
        hours: 10,
        approvedAt: DateTime(2026, 10, 1),
      ),
    );

    final snapshot = await repository.watch().first;
    expect(snapshot.of(HourCategory.complementary).hours, 140);
    expect(snapshot.recent.first.title, 'Certificado Game Jam');
    expect(snapshot.summary.certificates, 4);
  });

  test('CA-05: the progress ratio never goes past 1.0', () {
    const over = CategoryProgress(
      category: HourCategory.complementary,
      hours: 210,
      goal: 200,
    );

    expect(over.ratio, 1.0);
    expect(over.hours, 210);
  });

  test('CA-01: every repository starts from the same initial data', () async {
    await repository.add(
      ApprovedCertificate(
        id: 'new',
        title: 'Outro',
        category: HourCategory.extension,
        hours: 5,
        approvedAt: DateTime(2026, 10, 1),
      ),
    );

    final fresh = InMemoryHoursRepository();
    addTearDown(fresh.dispose);
    final snapshot = await fresh.watch().first;
    expect(snapshot.of(HourCategory.extension).hours, 45);
    expect(snapshot.recent, hasLength(3));
  });
}
```

- [ ] **Step 2: Rodar e ver falhar**

Run: `flutter test test/hours_repository_test.dart`
Expected: FAIL de compilação — arquivos de `lib/features/hours/` não existem.

- [ ] **Step 3: Implementação mínima**

`lib/features/hours/domain/hours.dart`:

```dart
/// The two kinds of hours a student must complete.
enum HourCategory { complementary, extension }

/// A certificate whose hours already count.
class ApprovedCertificate {
  const ApprovedCertificate({
    required this.id,
    required this.title,
    required this.category,
    required this.hours,
    required this.approvedAt,
  });

  final String id;
  final String title;
  final HourCategory category;
  final int hours;
  final DateTime approvedAt;
}

/// How far a category is from its goal.
class CategoryProgress {
  const CategoryProgress({
    required this.category,
    required this.hours,
    required this.goal,
  });

  final HourCategory category;
  final int hours;
  final int goal;

  /// Share of the goal reached, capped at 1.0 — hours above the goal still
  /// count in [hours].
  double get ratio => (hours / goal).clamp(0.0, 1.0);
}

/// Totals across both categories.
class HoursSummary {
  const HoursSummary({
    required this.totalHours,
    required this.certificates,
    required this.goalPercent,
  });

  final int totalHours;
  final int certificates;

  /// Percent of the combined goal, rounded down.
  final int goalPercent;
}

/// Everything the screens show about hours, at one moment.
class HoursSnapshot {
  const HoursSnapshot({
    required this.progress,
    required this.recent,
    required this.summary,
  });

  final List<CategoryProgress> progress;

  /// Approved certificates, newest first.
  final List<ApprovedCertificate> recent;
  final HoursSummary summary;

  CategoryProgress of(HourCategory category) =>
      progress.firstWhere((p) => p.category == category);
}
```

`lib/features/hours/data/hours_repository.dart`:

```dart
import 'package:rxdart/rxdart.dart';

import '../domain/hours.dart';

/// Where the student's hours come from.
abstract class HoursRepository {
  /// The current hours, and every change after that.
  Stream<HoursSnapshot> watch();

  Future<void> add(ApprovedCertificate certificate);

  void dispose();
}

/// The prototype's hours, in memory: every instance starts from the same
/// fictitious history.
class InMemoryHoursRepository implements HoursRepository {
  InMemoryHoursRepository() : _certificates = _initialCertificates() {
    _subject = BehaviorSubject.seeded(_snapshot());
  }

  static const _goals = {
    HourCategory.complementary: 200,
    HourCategory.extension: 100,
  };

  /// Hours earned before the certificates below.
  static const _baseHours = {
    HourCategory.complementary: 98,
    HourCategory.extension: 30,
  };

  static List<ApprovedCertificate> _initialCertificates() => [
    ApprovedCertificate(
      id: 'community-tech-workshop',
      title: 'Workshop de Tecnologia Comunitária',
      category: HourCategory.extension,
      hours: 15,
      approvedAt: DateTime(2026, 9, 20),
    ),
    ApprovedCertificate(
      id: 'advanced-python-seminar',
      title: 'Seminário Avançado de Python',
      category: HourCategory.complementary,
      hours: 8,
      approvedAt: DateTime(2026, 9, 12),
    ),
    ApprovedCertificate(
      id: 'university-game-jam-2024',
      title: 'University Game Jam 2024',
      category: HourCategory.complementary,
      hours: 24,
      approvedAt: DateTime(2026, 8, 30),
    ),
  ];

  final List<ApprovedCertificate> _certificates;
  late final BehaviorSubject<HoursSnapshot> _subject;

  @override
  Stream<HoursSnapshot> watch() => _subject.stream;

  @override
  Future<void> add(ApprovedCertificate certificate) async {
    _certificates.add(certificate);
    _subject.add(_snapshot());
  }

  @override
  void dispose() => _subject.close();

  HoursSnapshot _snapshot() {
    final recent = [..._certificates]
      ..sort((a, b) => b.approvedAt.compareTo(a.approvedAt));
    final progress = [
      for (final category in HourCategory.values)
        CategoryProgress(
          category: category,
          hours:
              _baseHours[category]! +
              _certificates
                  .where((c) => c.category == category)
                  .fold(0, (sum, c) => sum + c.hours),
          goal: _goals[category]!,
        ),
    ];
    final totalHours = progress.fold(0, (sum, p) => sum + p.hours);
    final totalGoal = progress.fold(0, (sum, p) => sum + p.goal);
    return HoursSnapshot(
      progress: progress,
      recent: recent,
      summary: HoursSummary(
        totalHours: totalHours,
        certificates: _certificates.length,
        goalPercent: totalHours * 100 ~/ totalGoal,
      ),
    );
  }
}
```

- [ ] **Step 4: Rodar e ver passar**

Run: `flutter test test/hours_repository_test.dart`
Expected: PASS (6 testes).

- [ ] **Step 5: Gates e commit**

```bash
dart format lib test && flutter analyze && dart run custom_lint && flutter test
git add lib/features/hours/ test/hours_repository_test.dart
git commit -m "feat: guarda as horas do aluno num repositório em memória"
```

---

### Task 2: Aba Dashboard com o progresso por categoria (CA-01)

**Files:**
- Create: `lib/features/hours/presentation/dashboard_cubit.dart`
- Create: `lib/features/hours/presentation/hour_category_labels.dart`
- Create: `lib/features/hours/presentation/dashboard_page.dart`
- Modify: `lib/app/app_providers.dart` (`RepositoryProvider<HoursRepository>`, injeção)
- Modify: `lib/app/app_router.dart` (aba `/dashboard` mostra `DashboardPage`)
- Modify: ARBs + gerados
- Modify: `test/app_harness.dart` (`hoursRepository`)
- Test: `test/dashboard_page_test.dart`

**Interfaces:**
- Consumes: `HoursRepository`, `InMemoryHoursRepository`, tipos de `hours.dart` (Task 1).
- Produces: `class DashboardCubit extends Cubit<HoursSnapshot?>` (`DashboardCubit(HoursRepository)`; assina `watch()`; cancela no `close`); `DashboardPage()`; `extension HourCategoryLabels on HourCategory { String title(AppLocalizations l10n); String subtitle(AppLocalizations l10n); IconData get icon; }`; `AppProviders({..., HoursRepository? hoursRepository})`; harness `pumpRoutedApp(..., HoursRepository? hoursRepository)`.

- [ ] **Step 1: Harness** — em `test/app_harness.dart`: parâmetro `HoursRepository? hoursRepository` no `pumpRoutedApp`, repassado como `AppProviders(hoursRepository: hoursRepository, ...)`; import de `package:uni_cronos/features/hours/data/hours_repository.dart`.

- [ ] **Step 2: Escrever o teste que falha** — `test/dashboard_page_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_harness.dart';

void main() {
  testWidgets('CA-01: the dashboard shows 130 of 200 complementary hours and '
      '45 of 100 extension hours, with bars at 0.65 and 0.45', (tester) async {
    await pumpRoutedApp(tester);

    expect(find.text('Progresso acadêmico'), findsOneWidget);
    expect(find.text('Horas Complementares'), findsWidgets);
    expect(find.text('Atividades extracurriculares'), findsOneWidget);
    expect(find.text('130 horas'), findsOneWidget);
    expect(find.text('200 no total'), findsOneWidget);
    expect(find.text('Horas de Extensão'), findsWidgets);
    expect(find.text('Envolvimento com a comunidade'), findsOneWidget);
    expect(find.text('45 horas'), findsOneWidget);
    expect(find.text('100 no total'), findsOneWidget);

    final bars = tester
        .widgetList<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator),
        )
        .map((bar) => bar.value!)
        .toList();
    expect(bars, hasLength(2));
    expect(bars[0], closeTo(0.65, 1e-9));
    expect(bars[1], closeTo(0.45, 1e-9));
  });
}
```

- [ ] **Step 3: Rodar e ver falhar**

Run: `flutter test test/dashboard_page_test.dart`
Expected: FAIL de compilação — `No named parameter with the name 'hoursRepository'`.

- [ ] **Step 4: Textos** — nos três ARBs, depois de `"comingSoon"`, na mesma posição:

| chave | pt | en | es |
|---|---|---|---|
| `dashboardTitle` | Progresso acadêmico | Academic progress | Progreso académico |
| `hoursComplementaryTitle` | Horas Complementares | Complementary Hours | Horas Complementarias |
| `hoursComplementarySubtitle` | Atividades extracurriculares | Extracurricular activities | Actividades extracurriculares |
| `hoursExtensionTitle` | Horas de Extensão | Extension Hours | Horas de Extensión |
| `hoursExtensionSubtitle` | Envolvimento com a comunidade | Community engagement | Participación comunitaria |
| `hoursAccumulated` | {hours} horas | {hours} hours | {hours} horas |
| `hoursGoalTotal` | {goal} no total | {goal} total | {goal} en total |

No `app_pt.arb`, declarar os placeholders logo depois de cada chave com placeholder:

```json
  "hoursAccumulated": "{hours} horas",
  "@hoursAccumulated": {
    "placeholders": { "hours": { "type": "int" } }
  },
  "hoursGoalTotal": "{goal} no total",
  "@hoursGoalTotal": {
    "placeholders": { "goal": { "type": "int" } }
  },
```

Run: `flutter gen-l10n`

- [ ] **Step 5: Rótulos por categoria** — `lib/features/hours/presentation/hour_category_labels.dart`:

```dart
import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../domain/hours.dart';

/// How each category of hours is named and drawn.
extension HourCategoryLabels on HourCategory {
  String title(AppLocalizations l10n) => switch (this) {
    HourCategory.complementary => l10n.hoursComplementaryTitle,
    HourCategory.extension => l10n.hoursExtensionTitle,
  };

  String subtitle(AppLocalizations l10n) => switch (this) {
    HourCategory.complementary => l10n.hoursComplementarySubtitle,
    HourCategory.extension => l10n.hoursExtensionSubtitle,
  };

  IconData get icon => switch (this) {
    HourCategory.complementary => Icons.workspace_premium_outlined,
    HourCategory.extension => Icons.volunteer_activism_outlined,
  };
}
```

- [ ] **Step 6: Cubit** — `lib/features/hours/presentation/dashboard_cubit.dart`:

```dart
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/hours_repository.dart';
import '../domain/hours.dart';

/// The hours the dashboard shows; null until the first snapshot arrives.
class DashboardCubit extends Cubit<HoursSnapshot?> {
  DashboardCubit(HoursRepository repository) : super(null) {
    _subscription = repository.watch().listen(emit);
  }

  late final StreamSubscription<HoursSnapshot> _subscription;

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
```

- [ ] **Step 7: Página** — `lib/features/hours/presentation/dashboard_page.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../data/hours_repository.dart';
import '../domain/hours.dart';
import 'dashboard_cubit.dart';
import 'hour_category_labels.dart';

/// The student's hours: progress per category.
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DashboardCubit(context.read<HoursRepository>()),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final snapshot = context.watch<DashboardCubit>().state;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenGutter),
      children: [
        Text(
          l10n.dashboardTitle,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: AppSpacing.xl),
        if (snapshot != null) ...[
          for (final progress in snapshot.progress) ...[
            _ProgressCard(progress: progress),
            const SizedBox(height: AppSpacing.lg),
          ],
        ],
      ],
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.progress});

  final CategoryProgress progress;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final category = progress.category;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadii.md),
        boxShadow: AppShadows.sm,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    category.title(l10n),
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                Icon(category.icon, color: cs.primary),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              category.subtitle(l10n),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.pill),
              child: LinearProgressIndicator(
                value: progress.ratio,
                minHeight: AppSpacing.sm,
                backgroundColor: cs.surfaceContainer,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: AppSpacing.sm,
              children: [
                Text(
                  l10n.hoursAccumulated(progress.hours),
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  l10n.hoursGoalTotal(progress.goal),
                  style: theme.textTheme.labelLarge,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 8: Providers e rota** — em `lib/app/app_providers.dart`: campo `final HoursRepository? hoursRepository;` (construtor continua `const`) e trocar o `MultiBlocProvider` por:

```dart
    return RepositoryProvider<HoursRepository>(
      create: (_) => hoursRepository ?? InMemoryHoursRepository(),
      dispose: (repository) => repository.dispose(),
      child: MultiBlocProvider(
        providers: [ /* os mesmos de hoje */ ],
        child: child,
      ),
    );
```

Em `lib/app/app_router.dart`, o branch do Dashboard sai do laço de abas provisórias e vira o primeiro branch, explícito:

```dart
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.dashboard,
                  builder: (context, state) => const DashboardPage(),
                ),
              ],
            ),
```

(o laço continua para `upload`, `activities` e `profile`).

- [ ] **Step 9: Rodar e ver passar**

Run: `flutter test test/dashboard_page_test.dart test/app_shell_test.dart`
Expected: PASS.

- [ ] **Step 10: Gates e commit**

```bash
dart format lib test && flutter analyze && dart run custom_lint && flutter test
git add lib/features/hours/presentation/ lib/app/app_providers.dart lib/app/app_router.dart lib/l10n/ test/app_harness.dart test/dashboard_page_test.dart
git commit -m "feat: mostra o progresso de horas na aba Dashboard"
```

---

### Task 3: Lista "Aprovados recentemente" que se atualiza sozinha (CA-02, CA-03)

**Files:**
- Modify: `lib/features/hours/presentation/dashboard_page.dart`
- Modify: ARBs + gerados
- Test: `test/dashboard_page_test.dart`

**Interfaces:**
- Consumes: `DashboardPage`, `HourCategoryLabels` (Task 2); `HoursRepository.add` (Task 1).

- [ ] **Step 1: Escrever os testes que falham** — acrescentar a `test/dashboard_page_test.dart` (imports extras: `package:flutter_bloc/flutter_bloc.dart`, `package:uni_cronos/features/hours/data/hours_repository.dart`, `package:uni_cronos/features/hours/domain/hours.dart`, `package:uni_cronos/features/hours/presentation/dashboard_page.dart`):

```dart
  testWidgets('CA-02: the recent list shows the three approved certificates, '
      'newest first', (tester) async {
    await pumpRoutedApp(tester);

    expect(find.text('Aprovados recentemente'), findsOneWidget);
    final titles = [
      'Workshop de Tecnologia Comunitária',
      'Seminário Avançado de Python',
      'University Game Jam 2024',
    ];
    final tops = [
      for (final title in titles) tester.getTopLeft(find.text(title)).dy,
    ];
    expect(tops, orderedEquals([...tops]..sort()));
    for (final hours in ['+15 h', '+8 h', '+24 h']) {
      expect(find.text(hours), findsOneWidget, reason: hours);
    }
    expect(find.text('Aprovado'), findsNWidgets(3));
  });

  testWidgets('CA-03: a certificate added to the repository shows up at once, '
      'with the new total', (tester) async {
    await pumpRoutedApp(tester);

    await tester
        .element(find.byType(DashboardPage))
        .read<HoursRepository>()
        .add(
          ApprovedCertificate(
            id: 'new',
            title: 'Certificado Game Jam',
            category: HourCategory.complementary,
            hours: 10,
            approvedAt: DateTime(2026, 10, 1),
          ),
        );
    await tester.pumpAndSettle();

    expect(find.text('140 horas'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Certificado Game Jam')).dy,
      lessThan(
        tester.getTopLeft(find.text('Workshop de Tecnologia Comunitária')).dy,
      ),
    );
  });
```

- [ ] **Step 2: Rodar e ver falhar**

Run: `flutter test test/dashboard_page_test.dart`
Expected: FAIL — `Found 0 widgets with text "Aprovados recentemente"` e `"Certificado Game Jam"`.

- [ ] **Step 3: Textos** — nos três ARBs, depois de `"hoursGoalTotal"`:

| chave | pt | en | es |
|---|---|---|---|
| `dashboardRecentTitle` | Aprovados recentemente | Recently approved | Aprobados recientemente |
| `dashboardSeeAll` | Ver todos | See all | Ver todos |
| `certificateHours` | +{hours} h | +{hours} h | +{hours} h |
| `certificateApproved` | Aprovado | Approved | Aprobado |

com `@certificateHours` (placeholder `hours`, `int`) no `app_pt.arb`. `flutter gen-l10n`.

- [ ] **Step 4: Implementação** — em `dashboard_page.dart`, acrescentar ao fim da lista do `if (snapshot != null) ...[ ... ]`, depois do `for` dos cards, a seção e os itens:

```dart
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.dashboardRecentTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(l10n.dashboardSeeAll),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final certificate in snapshot.recent) ...[
              _CertificateTile(certificate: certificate),
              const SizedBox(height: AppSpacing.md),
            ],
```

e o item:

```dart
class _CertificateTile extends StatelessWidget {
  const _CertificateTile({required this.certificate});

  final ApprovedCertificate certificate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadii.md),
        boxShadow: AppShadows.sm,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: cs.surfaceContainer,
              child: Icon(certificate.category.icon, color: cs.primary),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(certificate.title, style: theme.textTheme.titleMedium),
                  Text(
                    certificate.category.title(l10n),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  l10n.certificateHours(certificate.hours),
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.primary,
                  ),
                ),
                Text(
                  l10n.certificateApproved,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

O CA-03 passa porque o `DashboardCubit` já assina o `watch()` (Task 2); o teste trava esse comportamento.

- [ ] **Step 5: Rodar e ver passar**

Run: `flutter test test/dashboard_page_test.dart`
Expected: PASS (3 testes).

- [ ] **Step 6: Gates e commit**

```bash
dart format lib test && flutter analyze && dart run custom_lint && flutter test
git add lib/features/hours/presentation/dashboard_page.dart lib/l10n/ test/dashboard_page_test.dart
git commit -m "feat: lista os certificados aprovados recentemente no Dashboard"
```

---

### Task 4: "Ver todos" avisa "Disponível em breve"; telas estreitas (CA-06)

**Files:**
- Modify: `lib/features/hours/presentation/dashboard_page.dart`
- Test: `test/dashboard_page_test.dart`

- [ ] **Step 1: Escrever os testes que falham** — acrescentar a `test/dashboard_page_test.dart`:

```dart
  testWidgets('CA-06: Ver todos says Disponível em breve', (tester) async {
    await pumpRoutedApp(tester);

    await tester.ensureVisible(find.text('Ver todos'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ver todos'));
    await tester.pump();

    expect(find.text('Disponível em breve'), findsOneWidget);
  });

  for (final (width, scale) in [(320.0, 1.0), (360.0, 1.5)]) {
    testWidgets('CA-02: the dashboard fits a ${width.toInt()}dp screen at '
        '${scale}x text without overflowing', (tester) async {
      tester.view.physicalSize = Size(width, 760);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await pumpRoutedApp(tester);
      await tester.scrollUntilVisible(
        find.text('University Game Jam 2024'),
        200,
        scrollable: find.descendant(
          of: find.byType(DashboardPage),
          matching: find.byType(Scrollable),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  }
```

- [ ] **Step 2: Rodar e ver falhar**

Run: `flutter test test/dashboard_page_test.dart`
Expected: FAIL — `Found 0 widgets with text "Disponível em breve"` (os de layout podem já passar — guardas; declarar).

- [ ] **Step 3: Implementação mínima** — em `dashboard_page.dart` (import `package:next_widgets_service/next_widgets_service.dart`), o "Ver todos" passa a:

```dart
                TextButton(
                  onPressed: () => NextSnack.showNextSnack(
                    context,
                    message: l10n.comingSoon,
                  ),
                  child: Text(l10n.dashboardSeeAll),
                ),
```

Se algum teste de layout acusar estouro, corrigir na raiz (texto que quebra linha, `Expanded`, `Wrap`) — nunca reduzindo o texto.

- [ ] **Step 4: Rodar e ver passar**

Run: `flutter test test/dashboard_page_test.dart`
Expected: PASS (6 testes), sem linhas `Warning:`.

- [ ] **Step 5: Gates e commit**

```bash
dart format lib test && flutter analyze && dart run custom_lint && flutter test
git add lib/features/hours/presentation/dashboard_page.dart test/dashboard_page_test.dart
git commit -m "feat: avisa que a lista completa de certificados chega em breve"
```

---

### Task 5: Fechar a spec 008

**Files:**
- Modify: `docs/specs/008-dashboard-de-horas.md` (status, decisões)
- Modify: `docs/architecture.md`, `docs/conventions.md` (via `/destilar 008`)

- [ ] **Step 1: Gates finais** — os quatro, com os números reais.
- [ ] **Step 2: Verificação manual no web** — 390×844 e 360dp com texto "Grande": entrar → Dashboard com os dois cards e a lista; "Ver todos" → aviso; troca de aba e volta mantém a rolagem; textos em en/es pelo menu do avatar.
- [ ] **Step 3: Decisões durante a implementação** — no mínimo: `BehaviorSubject` do `rxdart` (dependência que já existia) para entregar o estado atual a quem assina; `HoursRepository.dispose()` acrescentado ao contrato (o `RepositoryProvider` fecha o stream); datas fictícias dos três certificados iniciais (20/09, 12/09 e 30/08/2026) para fixar a ordem; CA-03 no widget nasceu verde (o Cubit já assinava o stream) e é travado pelo teste de unidade da Task 1; títulos dos certificados fictícios ficam em pt (são dados, não interface). Marcar `status: implementada`.
- [ ] **Step 4: Destilar** — `/destilar 008`: `docs/architecture.md` ganha "Horas" (repositório em memória, metas e horas-base, o `watch()` que entrega o atual, quem usa).
- [ ] **Step 5: Commit**

```bash
git add docs/specs/008-dashboard-de-horas.md docs/architecture.md docs/conventions.md
git commit -m "docs: fecha a spec do Dashboard de Horas e descreve as horas"
```

---

## Pendências levadas adiante

- **009 (upload):**
  - **Limite da lista "Aprovados recentemente":** hoje ela mostra todos os
    certificados, e o "Ver todos" sugere uma prévia. Decidir o limite (3 a 5)
    e criar um CA para ele.
  - **Datas iguais:** desempatar pela ordem de inserção.
  - **Ids repetidos:** decidir o que `add()` faz com um id que já existe.
  - **`add()` depois de `dispose()`:** hoje altera a lista antes de lançar.
    Proteger esse caso.
  - **Listas do snapshot:** passar a entregá-las com `List.unmodifiable`.
- **Erro no stream:** o `DashboardCubit` assina `watch()` sem `onError`.
  Acrescentar `onError: addError` quando houver uma fonte que possa falhar
  (009/010).
- **Leitor de tela:**
  - **Card:** a barra já anuncia "130 de 200 horas", e "130 horas" e "200 no
    total" são lidos de novo. Excluí-los da semântica.
  - **Item da lista:** são quatro paradas. Juntá-las num só nó com
    `MergeSemantics`.
- **Título do card com texto muito grande:** em 320dp com "Grande", ou a 1,5×,
  "Complementares" ainda quebra no meio da palavra. Nenhum leiaute com
  `titleLarge` evita isso, porque o Flutter não hifeniza.
- **Testes (opcional):**
  - **Títulos dos cards:** os testes os procuram com `findsWidgets`, que também
    acha o texto da categoria na lista. Prender os títulos aos cards.
  - **Fonte do teste de quebra de linha:** é carregada por caminho relativo.
    Usar `rootBundle`.
