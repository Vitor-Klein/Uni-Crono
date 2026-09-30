# Casca de navegação — Plano de implementação

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Trocar a home do template pela casca do protótipo — app bar com a marca e o avatar, barra inferior com Dashboard, Enviar, Atividades e Perfil — com o estado de notificações num Cubit compartilhado.

**Architecture:** `StatefulShellRoute.indexedStack` do go_router com um branch por aba e um `AppShell` (Scaffold + app bar + `NavigationBar`). O `redirect` vira função pura testável. O estado "notificações ativadas" sai da `HomePage` para um `NotificationsCubit` provido no `AppProviders`, sobre uma interface `NotificationsPreference` (adaptador do `PushService` em produção, falso nos testes). As abas mostram só o título até as specs 008–010.

**Tech Stack:** Flutter 3.47.1 / Dart ^3.11, go_router 17.5.0, flutter_bloc 9.1.1, next_widgets_service 4.2.1, package_info_plus.

**Spec:** `docs/specs/006-casca-de-navegacao.md`

## Global Constraints

- Um critério de aceite por vez: teste vermelho com a saída real → implementação mínima → refactor → gates.
- Gates, todos zerados, ao fim de cada task: `flutter analyze` · `dart run custom_lint` · `flutter test` · `dart format --output=none --set-exit-if-changed lib test`.
- Nome de teste começa com o ID: `CA-NN: …`, descrevendo comportamento; testes em inglês, em `test/` sem subpastas.
- Nenhuma cor, fonte, raio ou sombra literal em widget novo: `Theme.of(context)`, `AppSpacing`, `AppRadii`, `AppShadows` (`lib/core/theme/app_tokens.dart`).
- Ícones: `Icons.*_outlined` do SDK.
- Todo texto visível entra nos três ARBs (`lib/l10n/app_{pt,en,es}.arb`, referência pt) e se regenera com `flutter gen-l10n`.
- Comentários de código de produção sem vocabulário de processo (nada de "spec", "CA-", "RF-").
- Commits: Conventional Commits em pt, `git add` seletivo, **sem** `Co-Authored-By`, sem push.
- Antes de codar rotas e testes de widget, consultar as skills `flutter-setup-declarative-routing` e `flutter-add-widget-test`; seguir o código deste plano quando divergirem, e anotar a divergência.

## Review Focus

- **Firebase indisponível** (web com init falho, testes): o modal "Mais" precisa abrir mesmo assim — Task 1 fixa o fallback do Remote Config.
- **Abrir uma aba pela URL** (web, `/activities` digitado): a casca abre com Atividades selecionada — teste na Task 3.
- **Tocar na aba já selecionada**: continua nela, sem erro — teste na Task 3.
- **Toque duplo rápido no switch de notificações**: nenhuma gravação duplicada do mesmo valor — teste na Task 6.
- **Voltar do Android numa aba que não é a inicial**: o comportamento padrão do `StatefulShellRoute` (volta dentro da aba; na raiz, sai do app) fica como está — só verificação manual na Task 9.

---

### Task 1: Remote Config cai nos padrões sem Firebase

**Files:**
- Modify: `lib/core/config/remote_config_service.dart:42`
- Test: `test/remote_config_service_test.dart`

**Interfaces:**
- Produces: `RemoteConfigService.get(String key)` nunca lança; sem Firebase devolve `RemoteConfigService.defaults[key]` (ou `''`).

- [ ] **Step 1: Escrever o teste que falha** — acrescentar ao `main()` de `test/remote_config_service_test.dart`:

```dart
  test('CA-04: without Firebase, get falls back to the defaults', () {
    TestWidgetsFlutterBinding.ensureInitialized();

    expect(RemoteConfigService.get(RemoteConfigKeys.termsUrl), isEmpty);
    expect(RemoteConfigService.get(RemoteConfigKeys.privacyPolicyUrl), isEmpty);
  });
```

- [ ] **Step 2: Rodar e ver falhar**

Run: `flutter test test/remote_config_service_test.dart`
Expected: FAIL com exceção do Firebase (ex.: `[core/no-app] No Firebase App '[DEFAULT]' has been created`).

- [ ] **Step 3: Implementação mínima** — trocar a linha 42:

```dart
  /// Without a Firebase app (init failed, or tests) there is no remote value:
  /// fall back to the defaults instead of throwing inside the UI.
  static String get(String key) {
    try {
      return _rc.getString(key).trim();
    } catch (_) {
      return (defaults[key] as String?) ?? '';
    }
  }
```

- [ ] **Step 4: Rodar e ver passar**

Run: `flutter test test/remote_config_service_test.dart`
Expected: PASS (2 testes).

- [ ] **Step 5: Gates e commit**

```bash
dart format lib test && flutter analyze && dart run custom_lint && flutter test
git add lib/core/config/remote_config_service.dart test/remote_config_service_test.dart
git commit -m "fix: usa os padrões do Remote Config quando o Firebase não está disponível"
```

---

### Task 2: `redirect` como função pura e rota do Dashboard (CA-06)

**Files:**
- Modify: `lib/core/navigation/app_routes.dart`
- Modify: `lib/app/app_router.dart:26-41`
- Test: `test/app_router_redirect_test.dart`

**Interfaces:**
- Produces: `AppRoutes.dashboard = '/dashboard'`, `AppRoutes.upload = '/upload'`, `AppRoutes.activities = '/activities'`, `AppRoutes.profile = '/profile'`; `AppRouter.resolveRedirect({required String location, required bool enforceUpgradeGate, required bool shouldBlock}) → String?`.

- [ ] **Step 1: Escrever o teste que falha** — `test/app_router_redirect_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';

import 'package:uni_cronos/app/app_router.dart';
import 'package:uni_cronos/core/navigation/app_routes.dart';

void main() {
  test('CA-06: once the upgrade gate releases, /upgrade-required goes to '
      '/dashboard', () {
    expect(
      AppRouter.resolveRedirect(
        location: AppRoutes.upgradeRequired,
        enforceUpgradeGate: true,
        shouldBlock: false,
      ),
      AppRoutes.dashboard,
    );
  });

  test('CA-06: a blocking gate still sends everything but the splash to '
      '/upgrade-required', () {
    expect(
      AppRouter.resolveRedirect(
        location: AppRoutes.dashboard,
        enforceUpgradeGate: true,
        shouldBlock: true,
      ),
      AppRoutes.upgradeRequired,
    );
    expect(
      AppRouter.resolveRedirect(
        location: AppRoutes.splash,
        enforceUpgradeGate: true,
        shouldBlock: true,
      ),
      isNull,
    );
  });
}
```

- [ ] **Step 2: Rodar e ver falhar**

Run: `flutter test test/app_router_redirect_test.dart`
Expected: FAIL de compilação — `Member not found: 'resolveRedirect'` / `'dashboard'`.

- [ ] **Step 3: Implementação mínima**

`lib/core/navigation/app_routes.dart` (mantém `home` até a Task 3):

```dart
abstract final class AppRoutes {
  static const splash = '/splash';
  static const home = '/home';
  static const dashboard = '/dashboard';
  static const upload = '/upload';
  static const activities = '/activities';
  static const profile = '/profile';
  static const upgradeRequired = '/upgrade-required';
  static const webview = '/webview';
}
```

`lib/app/app_router.dart` — trocar o corpo do `redirect:` por uma chamada e acrescentar o método estático:

```dart
      redirect: (context, state) => resolveRedirect(
        location: state.matchedLocation,
        enforceUpgradeGate: enforceUpgradeGate,
        shouldBlock: upgradeGate.shouldBlock,
      ),
```

```dart
  /// Where to send [location], or null to stay. The splash always completes
  /// its run, with or without a pending gate — explicit decision, validated
  /// in device QA.
  static String? resolveRedirect({
    required String location,
    required bool enforceUpgradeGate,
    required bool shouldBlock,
  }) {
    if (!enforceUpgradeGate) return null;
    if (location == AppRoutes.splash) return null;

    if (shouldBlock) {
      return location == AppRoutes.upgradeRequired
          ? null
          : AppRoutes.upgradeRequired;
    }
    return location == AppRoutes.upgradeRequired ? AppRoutes.dashboard : null;
  }
```

- [ ] **Step 4: Rodar e ver passar**

Run: `flutter test test/app_router_redirect_test.dart`
Expected: PASS (2 testes).

- [ ] **Step 5: Gates e commit**

```bash
dart format lib test && flutter analyze && dart run custom_lint && flutter test
git add lib/core/navigation/app_routes.dart lib/app/app_router.dart test/app_router_redirect_test.dart
git commit -m "refactor: extrai o redirect para uma função pura e aponta a liberação para o Dashboard"
```

Nota: até a Task 3, `/dashboard` ainda não tem rota — só é alcançado quando a trava de atualização libera, o que não acontece no fluxo normal.

---

### Task 3: Casca com as quatro abas; splash abre o Dashboard (CA-01)

**Files:**
- Create: `lib/app/shell/app_shell.dart`
- Create: `lib/app/shell/tab_placeholder_page.dart`
- Create: `test/app_harness.dart`
- Modify: `lib/app/app_router.dart` (rotas; `splashDuration`)
- Modify: `lib/app/app.dart:18-56` (`splashDuration`; rota do `debugHome`)
- Modify: `lib/features/splash/presentation/splash_screen.dart`
- Modify: `lib/core/navigation/app_routes.dart` (sai `home`)
- Modify: `lib/l10n/app_pt.arb`, `app_en.arb`, `app_es.arb` + gerados
- Test: `test/app_shell_test.dart`

**Interfaces:**
- Consumes: `AppRoutes.dashboard/upload/activities/profile` (Task 2).
- Produces: `MyApp({Duration splashDuration = const Duration(seconds: 3), ...})`; `AppRouter.build({required bool enforceUpgradeGate, required UpgradeGateController upgradeGate, Duration splashDuration = const Duration(seconds: 3)})`; `SplashScreen({Duration duration = const Duration(seconds: 3)})`; `AppShell({required StatefulNavigationShell navigationShell})`; `TabPlaceholderPage({required String title})` com `key` = caminho da aba; harness `pumpRoutedApp(tester, {prefs})`, `currentPath()`, `navLabel(text)`; l10n `navDashboard`, `navUpload`, `navActivities`, `navProfile`.

- [ ] **Step 1: Escrever o harness de teste** — `test/app_harness.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:uni_cronos/app/app.dart';
import 'package:uni_cronos/app/app_providers.dart';
import 'package:uni_cronos/app/app_router.dart';

/// Pumps the real app — splash, router and shell — with [prefs] stored and
/// no splash wait, and settles on the first screen after the splash.
Future<void> pumpRoutedApp(
  WidgetTester tester, {
  Map<String, Object> prefs = const {},
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  PackageInfo.setMockInitialValues(
    appName: 'Uni Cronos',
    packageName: 'uni_cronos',
    version: '1.0.0',
    buildNumber: '1',
    buildSignature: '',
  );
  await tester.pumpWidget(
    const AppProviders(
      child: MyApp(enforceUpgradeGate: false, splashDuration: Duration.zero),
    ),
  );
  await tester.pumpAndSettle();
}

/// The path the router is on.
String currentPath() => GoRouter.of(AppRouter.navigatorKey.currentContext!)
    .routerDelegate
    .currentConfiguration
    .uri
    .path;

/// A label of the bottom navigation bar.
Finder navLabel(String text) =>
    find.descendant(of: find.byType(NavigationBar), matching: find.text(text));
```

- [ ] **Step 2: Escrever o teste que falha** — `test/app_shell_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:uni_cronos/core/navigation/app_routes.dart';

import 'app_harness.dart';

void main() {
  testWidgets('CA-01: after the splash the app opens on the dashboard tab, '
      'with the four destinations in pt', (tester) async {
    await pumpRoutedApp(tester);

    expect(currentPath(), AppRoutes.dashboard);
    for (final label in ['Dashboard', 'Enviar', 'Atividades', 'Perfil']) {
      expect(navLabel(label), findsOneWidget, reason: label);
    }
  });
}
```

- [ ] **Step 3: Rodar e ver falhar**

Run: `flutter test test/app_shell_test.dart`
Expected: FAIL de compilação — `No named parameter with the name 'splashDuration'`.

- [ ] **Step 4: Textos** — acrescentar aos três ARBs (depois de `"settingsLanguageSemantics"`), manter a mesma posição nos três:

`app_pt.arb`:
```json
  "navDashboard": "Dashboard",
  "navUpload": "Enviar",
  "navActivities": "Atividades",
  "navProfile": "Perfil",
```
`app_en.arb`:
```json
  "navDashboard": "Dashboard",
  "navUpload": "Upload",
  "navActivities": "Activities",
  "navProfile": "Profile",
```
`app_es.arb`:
```json
  "navDashboard": "Panel",
  "navUpload": "Subir",
  "navActivities": "Actividades",
  "navProfile": "Perfil",
```

Run: `flutter gen-l10n`

- [ ] **Step 5: Splash com duração injetável** — `lib/features/splash/presentation/splash_screen.dart`:

```dart
class SplashScreen extends StatefulWidget {
  const SplashScreen({this.duration = const Duration(seconds: 3), super.key});

  /// How long the splash stays before opening the app.
  final Duration duration;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}
```

e no `initState`: `await Future.delayed(widget.duration);` e `context.go(AppRoutes.dashboard);`.

- [ ] **Step 6: Página provisória das abas** — `lib/app/shell/tab_placeholder_page.dart`:

```dart
import 'package:flutter/material.dart';

import '../../core/theme/app_tokens.dart';

/// Body of a tab whose screen is not built yet: just the tab title.
class TabPlaceholderPage extends StatelessWidget {
  const TabPlaceholderPage({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenGutter),
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
      ],
    );
  }
}
```

- [ ] **Step 7: A casca** — `lib/app/shell/app_shell.dart` (sem app bar e sem troca de aba ainda — Tasks 4 e 7):

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';

/// Frame of the signed-in app: the current tab and the bottom navigation.
class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        backgroundColor: cs.surfaceContainerLowest,
        indicatorColor: cs.primaryContainer,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            label: l10n.navDashboard,
          ),
          NavigationDestination(
            icon: const Icon(Icons.upload_file_outlined),
            label: l10n.navUpload,
          ),
          NavigationDestination(
            icon: const Icon(Icons.explore_outlined),
            label: l10n.navActivities,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            label: l10n.navProfile,
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 8: Rotas** — em `lib/app/app_router.dart`: acrescentar o parâmetro `Duration splashDuration = const Duration(seconds: 3)` a `build`; passar `SplashScreen(duration: splashDuration)`; **trocar** o `GoRoute(path: AppRoutes.home, …)` por:

```dart
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) =>
              AppShell(navigationShell: navigationShell),
          branches: [
            for (final (path, title) in <(String, String Function(AppLocalizations))>[
              (AppRoutes.dashboard, (l) => l.navDashboard),
              (AppRoutes.upload, (l) => l.navUpload),
              (AppRoutes.activities, (l) => l.navActivities),
              (AppRoutes.profile, (l) => l.navProfile),
            ])
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: path,
                    builder: (context, state) => TabPlaceholderPage(
                      key: ValueKey(path),
                      title: title(AppLocalizations.of(context)!),
                    ),
                  ),
                ],
              ),
          ],
        ),
```

Imports: `../l10n/app_localizations.dart`, `shell/app_shell.dart`, `shell/tab_placeholder_page.dart`; remover o import de `home_page.dart`. Remover `static const home` de `AppRoutes`.

- [ ] **Step 9: `MyApp`** — em `lib/app/app.dart`: campo `final Duration splashDuration;` com padrão `const Duration(seconds: 3)` no construtor; passar `splashDuration: widget.splashDuration` ao `AppRouter.build`; no ramo do `debugHome`, trocar `AppRoutes.home` por `AppRoutes.dashboard` (as duas ocorrências).

- [ ] **Step 10: Rodar e ver passar**

Run: `flutter test test/app_shell_test.dart`
Expected: PASS.

- [ ] **Step 11: Gates e commit**

`lib/features/home/presentation/home_page.dart` fica sem rota até a Task 7 (é lá que as funções dela mudam de dono).

```bash
dart format lib test && flutter analyze && dart run custom_lint && flutter test
git add lib/app/shell/ lib/app/app_router.dart lib/app/app.dart lib/core/navigation/app_routes.dart lib/features/splash/presentation/splash_screen.dart lib/l10n/ test/app_harness.dart test/app_shell_test.dart
git commit -m "feat: abre o app na casca com as quatro abas do protótipo"
```

---

### Task 4: Trocar de aba pela barra inferior (CA-02)

**Files:**
- Modify: `lib/app/shell/app_shell.dart`
- Test: `test/app_shell_test.dart`

**Interfaces:**
- Consumes: harness da Task 3.

- [ ] **Step 1: Escrever os testes que falham** — acrescentar a `test/app_shell_test.dart`:

```dart
  testWidgets('CA-02: each destination opens its tab and becomes selected', (
    tester,
  ) async {
    await pumpRoutedApp(tester);

    final expectations = {
      'Enviar': (AppRoutes.upload, 1),
      'Atividades': (AppRoutes.activities, 2),
      'Perfil': (AppRoutes.profile, 3),
      'Dashboard': (AppRoutes.dashboard, 0),
    };
    for (final MapEntry(key: label, value: (path, index))
        in expectations.entries) {
      await tester.tap(navLabel(label));
      await tester.pumpAndSettle();

      expect(currentPath(), path, reason: label);
      expect(
        tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
        index,
        reason: label,
      );
    }
  });

  testWidgets('CA-02: tapping the selected tab keeps it open', (tester) async {
    await pumpRoutedApp(tester);

    await tester.tap(navLabel('Dashboard'));
    await tester.pumpAndSettle();

    expect(currentPath(), AppRoutes.dashboard);
  });

  testWidgets('CA-02: opening a tab path directly selects that tab', (
    tester,
  ) async {
    await pumpRoutedApp(tester);

    GoRouter.of(AppRouter.navigatorKey.currentContext!).go(AppRoutes.activities);
    await tester.pumpAndSettle();

    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      2,
    );
  });
```

(Imports extras: `package:go_router/go_router.dart`, `package:uni_cronos/app/app_router.dart`.)

- [ ] **Step 2: Rodar e ver falhar**

Run: `flutter test test/app_shell_test.dart --plain-name "CA-02"`
Expected: o primeiro FAIL (`Expected: '/upload' Actual: '/dashboard'`); os outros dois já passam (a rota direta vem do go_router) — declarar isso no fechamento.

- [ ] **Step 3: Implementação mínima** — no `NavigationBar` de `AppShell`:

```dart
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
```

- [ ] **Step 4: Rodar e ver passar**

Run: `flutter test test/app_shell_test.dart`
Expected: PASS (4 testes).

- [ ] **Step 5: Gates e commit**

```bash
dart format lib test && flutter analyze && dart run custom_lint && flutter test
git add lib/app/shell/app_shell.dart test/app_shell_test.dart
git commit -m "feat: troca de aba pela barra inferior"
```

---

### Task 5: Cada aba guarda seu estado (CA-03)

**Files:**
- Test: `test/app_shell_test.dart`

A casca já usa `StatefulShellRoute.indexedStack` (contrato da spec), então o teste nasce verde. A prova de que ele vale é a mutação do Step 3. As abas ainda não rolam (só o título), então o teste verifica o que garante a rolagem: a página da aba deixada continua montada, fora do palco — e com ela o seu `ScrollController`. A spec 010 acrescenta o teste de rolagem real quando o Hub existir.

- [ ] **Step 1: Escrever o teste** — acrescentar a `test/app_shell_test.dart`:

```dart
  testWidgets('CA-03: leaving a tab keeps its page alive offstage', (
    tester,
  ) async {
    await pumpRoutedApp(tester);
    await tester.tap(navLabel('Atividades'));
    await tester.pumpAndSettle();
    final activitiesState = tester.state(
      find.descendant(
        of: find.byKey(const ValueKey(AppRoutes.activities)),
        matching: find.byType(Scrollable),
      ),
    );

    await tester.tap(navLabel('Dashboard'));
    await tester.pumpAndSettle();

    final offstage = find.descendant(
      of: find.byKey(const ValueKey(AppRoutes.activities), skipOffstage: false),
      matching: find.byType(Scrollable, skipOffstage: false),
    );
    expect(offstage, findsOneWidget);
    expect(identical(tester.state(offstage), activitiesState), isTrue);
  });
```

- [ ] **Step 2: Rodar e ver passar (nasce verde)**

Run: `flutter test test/app_shell_test.dart --plain-name "CA-03"`
Expected: PASS.

- [ ] **Step 3: Validar por mutação** — trocar temporariamente `StatefulShellRoute.indexedStack(` por:

```dart
        StatefulShellRoute(
          navigatorContainerBuilder: (context, shell, children) =>
              children[shell.currentIndex],
```

Run: `flutter test test/app_shell_test.dart --plain-name "CA-03"`
Expected: FAIL. Desfazer a mutação (`git diff lib/` vazio) e rodar de novo: PASS.

- [ ] **Step 4: Gates e commit**

```bash
dart format lib test && flutter analyze && dart run custom_lint && flutter test
git add test/app_shell_test.dart
git commit -m "test: garante que cada aba da casca guarda seu estado"
```

---

### Task 6: `NotificationsCubit` (base do CA-05)

**Files:**
- Create: `lib/features/notifications/data/notifications_preference.dart`
- Create: `lib/features/notifications/presentation/notifications_cubit.dart`
- Test: `test/notifications_cubit_test.dart`

**Interfaces:**
- Produces:
  - `abstract class NotificationsPreference { Future<bool> isEnabled(); Future<void> setEnabled(bool enabled); }`
  - `class PushNotificationsPreference implements NotificationsPreference` (const; delega a `PushService.I`).
  - `class NotificationsCubit extends Cubit<bool>` — `NotificationsCubit(NotificationsPreference preference)`; carrega o valor salvo ao nascer; `Future<bool> setEnabled(bool enabled)` → `true` se gravou, `false` se falhou (e reverte o estado).

- [ ] **Step 1: Escrever os testes que falham** — `test/notifications_cubit_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';

import 'package:uni_cronos/features/notifications/data/notifications_preference.dart';
import 'package:uni_cronos/features/notifications/presentation/notifications_cubit.dart';

class FakeNotificationsPreference implements NotificationsPreference {
  FakeNotificationsPreference({this.enabled = true, this.failWrites = false});

  bool enabled;
  bool failWrites;
  final writes = <bool>[];

  @override
  Future<bool> isEnabled() async => enabled;

  @override
  Future<void> setEnabled(bool value) async {
    writes.add(value);
    if (failWrites) throw Exception('write failed');
    enabled = value;
  }
}

void main() {
  test('CA-05: starts from the saved preference', () async {
    final cubit = NotificationsCubit(
      FakeNotificationsPreference(enabled: false),
    );
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state, isFalse);
  });

  test('CA-05: turning off saves false and reports success', () async {
    final preference = FakeNotificationsPreference();
    final cubit = NotificationsCubit(preference);
    await Future<void>.delayed(Duration.zero);

    final saved = await cubit.setEnabled(false);

    expect(saved, isTrue);
    expect(cubit.state, isFalse);
    expect(preference.writes, [false]);
  });

  test('CA-05: a failed save reverts the value and reports failure', () async {
    final preference = FakeNotificationsPreference(failWrites: true);
    final cubit = NotificationsCubit(preference);
    await Future<void>.delayed(Duration.zero);

    final saved = await cubit.setEnabled(false);

    expect(saved, isFalse);
    expect(cubit.state, isTrue);
  });

  test('CA-05: setting the current value writes nothing', () async {
    final preference = FakeNotificationsPreference();
    final cubit = NotificationsCubit(preference);
    await Future<void>.delayed(Duration.zero);

    await Future.wait([cubit.setEnabled(true), cubit.setEnabled(true)]);

    expect(preference.writes, isEmpty);
  });
}
```

- [ ] **Step 2: Rodar e ver falhar**

Run: `flutter test test/notifications_cubit_test.dart`
Expected: FAIL de compilação — arquivos não existem.

- [ ] **Step 3: Implementação mínima**

`lib/features/notifications/data/notifications_preference.dart`:

```dart
import 'push_service.dart';

/// Where the "notifications enabled" choice is read from and saved to.
abstract class NotificationsPreference {
  Future<bool> isEnabled();
  Future<void> setEnabled(bool enabled);
}

/// The app's preference: the push service's own store and topic setup.
class PushNotificationsPreference implements NotificationsPreference {
  const PushNotificationsPreference();

  @override
  Future<bool> isEnabled() => PushService.I.isNotificationsEnabled();

  @override
  Future<void> setEnabled(bool enabled) =>
      PushService.I.setNotificationsEnabled(enabled);
}
```

`lib/features/notifications/presentation/notifications_cubit.dart`:

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/notifications_preference.dart';

/// The single owner of "notifications enabled". Starts optimistic (true)
/// until the saved value loads.
class NotificationsCubit extends Cubit<bool> {
  NotificationsCubit(this._preference) : super(true) {
    _load();
  }

  final NotificationsPreference _preference;

  Future<void> _load() async {
    try {
      final enabled = await _preference.isEnabled();
      if (!isClosed) emit(enabled);
    } catch (e) {
      debugPrint('Error loading notification settings: $e');
    }
  }

  /// Switches optimistically and saves. Returns whether it was saved; on
  /// failure the previous value comes back, so the UI never shows a value
  /// that does not exist in storage.
  Future<bool> setEnabled(bool enabled) async {
    if (state == enabled) return true;
    final previous = state;
    emit(enabled);
    try {
      await _preference.setEnabled(enabled);
      return true;
    } catch (e) {
      debugPrint('Error updating notification settings: $e');
      if (!isClosed) emit(previous);
      return false;
    }
  }
}
```

- [ ] **Step 4: Rodar e ver passar**

Run: `flutter test test/notifications_cubit_test.dart`
Expected: PASS (4 testes).

- [ ] **Step 5: Gates e commit**

```bash
dart format lib test && flutter analyze && dart run custom_lint && flutter test
git add lib/features/notifications/data/notifications_preference.dart lib/features/notifications/presentation/notifications_cubit.dart test/notifications_cubit_test.dart
git commit -m "feat: centraliza o estado de notificações num Cubit"
```

---

### Task 7: App bar com a marca e o avatar que abre o modal "Mais" (CA-04)

**Files:**
- Create: `lib/app/app_info.dart`
- Create: `lib/app/shell/shell_app_bar.dart`
- Create: `lib/features/profile/domain/demo_student.dart`
- Modify: `lib/app/shell/app_shell.dart` (app bar)
- Modify: `lib/app/app_providers.dart` (`NotificationsCubit`, injeção)
- Modify: `lib/app/app.dart` (`title: kAppName`)
- Delete: `lib/features/home/presentation/home_page.dart`
- Modify: ARBs + gerados (`shellMenuSemantics`)
- Modify: `test/app_harness.dart` (preferência falsa)
- Test: `test/app_shell_test.dart`

**Interfaces:**
- Consumes: `NotificationsCubit`, `NotificationsPreference` (Task 6); `showHomeMoreModal(context, {required bool notificationsEnabled, required VoidCallback onNotificationsTap, required String appNameLabel, required String appVersionLabel})` (existente).
- Produces: `const kAppName = 'Uni Cronos'`; `DemoStudent.name`, `DemoStudent.initials`; `AppProviders({required Widget child, NotificationsPreference? notificationsPreference})`; harness `pumpRoutedApp(tester, {prefs, NotificationsPreference? notifications})` e `FakeNotificationsPreference` movida para `test/app_harness.dart`.

- [ ] **Step 1: Mover a preferência falsa para o harness** — recortar a classe `FakeNotificationsPreference` de `test/notifications_cubit_test.dart` para `test/app_harness.dart` (com o import de `notifications_preference.dart`) e importar `app_harness.dart` no teste do Cubit. Acrescentar ao `pumpRoutedApp` o parâmetro `NotificationsPreference? notifications` e passar `AppProviders(notificationsPreference: notifications ?? FakeNotificationsPreference(), child: …)` (sem `const`).

- [ ] **Step 2: Escrever o teste que falha** — acrescentar a `test/app_shell_test.dart`:

```dart
  testWidgets('CA-04: the app bar shows the brand, and the avatar opens the '
      'More modal', (tester) async {
    await pumpRoutedApp(tester);

    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('Uni Cronos')),
      findsOneWidget,
    );

    await tester.tap(find.text('AS'));
    await tester.pumpAndSettle();

    expect(find.text('MENSAGENS'), findsOneWidget);
    expect(find.text('CONFIGURAÇÕES'), findsOneWidget);
  });
```

- [ ] **Step 3: Rodar e ver falhar**

Run: `flutter test test/app_shell_test.dart --plain-name "CA-04"`
Expected: FAIL de compilação (`notificationsPreference` não existe em `AppProviders`).

- [ ] **Step 4: Textos** — nos três ARBs, depois de `"navProfile"`:

pt `"shellMenuSemantics": "Abrir menu"`, en `"shellMenuSemantics": "Open menu"`, es `"shellMenuSemantics": "Abrir menú"`. Run: `flutter gen-l10n`.

- [ ] **Step 5: Implementação mínima**

`lib/app/app_info.dart`:

```dart
/// The brand name, as the user sees it.
const kAppName = 'Uni Cronos';
```

`lib/features/profile/domain/demo_student.dart`:

```dart
/// The fictitious student of the prototype.
abstract final class DemoStudent {
  static const name = 'Ana Souza';
  static const initials = 'AS';
}
```

`lib/app/shell/shell_app_bar.dart` (o toque em Notificações entra na Task 8):

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/theme/app_tokens.dart';
import '../../features/home/presentation/home_more_modal.dart';
import '../../features/notifications/presentation/notifications_cubit.dart';
import '../../features/profile/domain/demo_student.dart';
import '../../l10n/app_localizations.dart';
import '../app_info.dart';

/// App bar of the shell: the brand, and the student's avatar, which opens the
/// More modal (messages, settings, share/legal, app version).
class ShellAppBar extends StatefulWidget implements PreferredSizeWidget {
  const ShellAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<ShellAppBar> createState() => _ShellAppBarState();
}

class _ShellAppBarState extends State<ShellAppBar> {
  // Empty until the bundle finishes loading: preferable to a hardcoded value
  // that could lie about the installed version.
  String _versionLabel = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (!mounted) return;
      setState(() => _versionLabel = 'v${info.version}+${info.buildNumber}');
    } catch (e) {
      debugPrint('Error loading package info: $e');
    }
  }

  void _openMore() {
    showHomeMoreModal(
      context,
      notificationsEnabled: context.read<NotificationsCubit>().state,
      onNotificationsTap: () {},
      appNameLabel: kAppName,
      appVersionLabel: _versionLabel,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return AppBar(
      backgroundColor: cs.surface,
      scrolledUnderElevation: 0,
      title: Text(
        kAppName,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: cs.primary,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.lg),
          child: Semantics(
            button: true,
            label: AppLocalizations.of(context)!.shellMenuSemantics,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: _openMore,
              child: CircleAvatar(
                radius: 18,
                backgroundColor: cs.primaryContainer,
                child: Text(
                  DemoStudent.initials,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onPrimaryContainer,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
```

Em `AppShell`: `appBar: const ShellAppBar(),` no `Scaffold`.

Em `lib/app/app_providers.dart`: campo `final NotificationsPreference? notificationsPreference;` no construtor (continua `const`) e, na lista de providers:

```dart
        BlocProvider(
          create: (_) => NotificationsCubit(
            notificationsPreference ?? const PushNotificationsPreference(),
          ),
        ),
```

Em `lib/app/app.dart`: `title: kAppName,` (import `app_info.dart`).

Apagar `lib/features/home/presentation/home_page.dart` (`git rm`).

- [ ] **Step 6: Rodar e ver passar**

Run: `flutter test test/app_shell_test.dart test/notifications_cubit_test.dart`
Expected: PASS.

- [ ] **Step 7: Gates e commit**

```bash
dart format lib test && flutter analyze && dart run custom_lint && flutter test
git add lib/app/app_info.dart lib/app/shell/ lib/app/app_providers.dart lib/app/app.dart lib/features/profile/domain/demo_student.dart lib/l10n/ test/app_harness.dart test/app_shell_test.dart test/notifications_cubit_test.dart
git rm lib/features/home/presentation/home_page.dart
git commit -m "feat: mostra a marca e o avatar na casca, com o modal Mais no avatar"
```

---

### Task 8: Notificações pelo modal "Mais" (CA-05)

**Files:**
- Create: `lib/features/notifications/presentation/open_notifications_sheet.dart`
- Modify: `lib/app/shell/shell_app_bar.dart` (`onNotificationsTap`)
- Test: `test/app_shell_test.dart`

**Interfaces:**
- Consumes: `NotificationsCubit.setEnabled` (Task 6); `showNotificationsSheet(context, {required bool enabled, required Future<bool> Function(bool) onChanged})` (existente).
- Produces: `void openNotificationsSheet(BuildContext context)` — reutilizado pelo Perfil (spec 010).

- [ ] **Step 1: Escrever os testes que falham** — acrescentar a `test/app_shell_test.dart`:

```dart
  Future<void> openNotifications(WidgetTester tester) async {
    await tester.tap(find.text('AS'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('CONFIGURAÇÕES'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('NOTIFICAÇÕES'));
    await tester.pumpAndSettle();
  }

  testWidgets('CA-05: turning notifications off from the More modal saves '
      'false and shows Desativado', (tester) async {
    final preference = FakeNotificationsPreference();
    await pumpRoutedApp(tester, notifications: preference);
    await openNotifications(tester);

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(preference.writes, [false]);
    expect(find.text('Desativado'), findsOneWidget);
  });

  testWidgets('CA-05: when saving fails, the value goes back and the error '
      'is shown', (tester) async {
    final preference = FakeNotificationsPreference(failWrites: true);
    await pumpRoutedApp(tester, notifications: preference);
    await openNotifications(tester);

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(find.text('Ativado'), findsOneWidget);
    expect(
      find.text('Não foi possível atualizar as configurações de notificação.'),
      findsOneWidget,
    );
  });
```

- [ ] **Step 2: Rodar e ver falhar**

Run: `flutter test test/app_shell_test.dart --plain-name "CA-05"`
Expected: FAIL — `Found 0 widgets with text "NOTIFICAÇÕES"`… ou, se o item abrir, nenhuma folha aparece (o toque ainda é `() {}`): `Found 0 widgets with type "Switch"`.

- [ ] **Step 3: Implementação mínima** — `lib/features/notifications/presentation/open_notifications_sheet.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:next_widgets_service/next_widgets_service.dart';

import '../../../l10n/app_localizations.dart';
import 'notifications_cubit.dart';
import 'notifications_sheet.dart';

/// Opens the notifications sheet over [context], saving through the shared
/// [NotificationsCubit] and confirming (or reporting the failure) in a snack.
void openNotificationsSheet(BuildContext context) {
  final cubit = context.read<NotificationsCubit>();
  final l10n = AppLocalizations.of(context)!;
  showNotificationsSheet(
    context,
    enabled: cubit.state,
    onChanged: (enabled) async {
      final saved = await cubit.setEnabled(enabled);
      if (context.mounted) {
        NextSnack.showNextSnack(
          context,
          message: !saved
              ? l10n.notificationsUpdateError
              : enabled
              ? l10n.notificationsEnabledMessage
              : l10n.notificationsDisabledMessage,
        );
      }
      return cubit.state;
    },
  );
}
```

Em `ShellAppBar._openMore`: `onNotificationsTap: () => openNotificationsSheet(context),` (import do arquivo novo).

- [ ] **Step 4: Rodar e ver passar**

Run: `flutter test test/app_shell_test.dart`
Expected: PASS (todos).

- [ ] **Step 5: Gates e commit**

```bash
dart format lib test && flutter analyze && dart run custom_lint && flutter test
git add lib/features/notifications/presentation/open_notifications_sheet.dart lib/app/shell/shell_app_bar.dart test/app_shell_test.dart
git commit -m "feat: liga as notificações do modal Mais ao Cubit compartilhado"
```

---

### Task 9: Fechar a spec 006

**Files:**
- Modify: `docs/specs/006-casca-de-navegacao.md` (status, decisões)
- Modify: `docs/architecture.md` (via `/destilar 006`)

- [ ] **Step 1: Gates finais** — rodar os quatro e anotar os números reais.

```bash
flutter analyze && dart run custom_lint && flutter test && dart format --output=none --set-exit-if-changed lib test
```

- [ ] **Step 2: Verificação manual no web** — `flutter run -d web-server --web-port 8080`, 390×844: splash → Dashboard; as quatro abas; avatar → "Mais" → Configurações → Notificações; a aba ativa destacada; título da aba do navegador "Uni Cronos". No Android, se houver aparelho: voltar numa aba que não é a inicial.

- [ ] **Step 3: Decisões durante a implementação** — registrar na spec, no mínimo: correção do Remote Config sem Firebase (Task 1); CA-03 verificado por página viva fora do palco, com mutação (Task 5), rolagem real fica para a 010; testes do CA-02 que nasceram verdes (rota direta e aba já selecionada); indicador da barra em `primaryContainer`; `kAppName` e `DemoStudent`. Marcar `status: implementada`.

- [ ] **Step 4: Destilar** — `/destilar 006`: `docs/architecture.md` ganha a navegação (casca, abas, `resolveRedirect`, `AppRoutes`) e o estado de notificações (`NotificationsCubit`/`NotificationsPreference`, `openNotificationsSheet`).

- [ ] **Step 5: Commit**

```bash
git add docs/specs/006-casca-de-navegacao.md docs/architecture.md
git commit -m "docs: fecha a spec da casca de navegação e descreve a navegação"
```

---

## Pendências levadas para as próximas specs

Da revisão final (itens adiados, sem bloqueio para esta spec):

- **009:** testar o reset da aba ao tocar de novo — empilhar `/upload/review`,
  tocar em "Enviar" e esperar `/upload` (o `goBranch(initialLocation: true)`
  ainda não tem teste, porque não havia rota aninhada).
- **010:** ao reutilizar `openNotificationsSheet` no Perfil, passar um contexto
  que sobreviva ao modal/folha, e fazer a folha e as linhas de preferência
  escutarem o `NotificationsCubit` (`BlocBuilder`) em vez de receber uma cópia do
  valor ao abrir. O teste de rolagem real do CA-03 entra com o Hub.
- **Quando houver caller:** `RemoteConfigService.getBool/getInt/getDouble`
  ainda lançam exceção sem Firebase, ao contrário de `get`.
