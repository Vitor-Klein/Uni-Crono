# Login e sessão — Plano de implementação

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Tela de login simulado (Figma "Login e Instituição") que valida o formato, salva a sessão no aparelho e protege a casca: sem sessão, tudo leva ao login.

**Architecture:** `lib/features/auth/` com `Session`/`Institution` (domínio), `SessionRepository` sobre `SharedPreferences` (dados) e `SessionCubit` + `LoginPage` (apresentação). A sessão é lida **antes do `runApp`** (no `AppBootstrap`) e entra como estado inicial do `SessionCubit` — assim o `redirect` nunca vê um "sem sessão" que é só "ainda não carregou". O `redirect` puro ganha `signedIn`; o `GoRouter` escuta a trava de atualização **e** o `SessionCubit`.

**Tech Stack:** Flutter 3.47.1 / Dart ^3.11, go_router 17.5.0, flutter_bloc 9.1.1, shared_preferences, next_widgets_service 4.2.1 (`NextSnack`).

**Spec:** `docs/specs/007-login-e-sessao.md`

## Global Constraints

- Um critério de aceite por vez: teste vermelho com a saída real → implementação mínima → refactor → gates. O teste vermelho é escrito e rodado pelo coordenador antes do despacho; o implementador faz GREEN + REFACTOR e não altera o teste sem declarar.
- Gates, todos zerados, ao fim de cada task: `flutter analyze` · `dart run custom_lint` · `flutter test` · `dart format --output=none --set-exit-if-changed lib test`.
- Nome de teste começa com o ID: `CA-NN: …`, descrevendo comportamento; testes em inglês, em `test/` sem subpastas.
- Nenhuma cor, fonte, raio ou sombra literal em widget novo: `Theme.of(context)`, `AppSpacing`, `AppRadii` (`lib/core/theme/app_tokens.dart`). Nada de `TextStyle(...)` literal (lint `no_textstyle_literal`).
- Ícones: `Icons.*_outlined` do SDK. `IconButton` com `tooltip` (lint `require_icon_button_accessible_label`). Alvos de toque ≥ 40×40.
- Todo texto visível entra nos três ARBs (`lib/l10n/app_{pt,en,es}.arb`, referência pt) e se regenera com `flutter gen-l10n` (lint `no_hardcoded_user_text`). Avisos com `NextSnack.showNextSnack` (lint `prefer_next_snack`). Rotas por `AppRoutes` (lint `no_hardcoded_routes`).
- **SECURITY.md:** a senha nunca é salva, passada adiante nem registrada em log; e-mail também não vai para log.
- Comentários de código de produção sem vocabulário de processo (nada de "spec", "CA-", "RF-").
- Commits: Conventional Commits em pt, `git add` seletivo, **sem** `Co-Authored-By`, sem push.

## Review Focus

- **Deep link sem sessão** (web, `/activities` digitado sem ter entrado): vai para o login — teste na Task 3.
- **Sessão salva pela metade** (só o e-mail, ou só a instituição, depois de uma gravação interrompida): conta como "sem sessão", não quebra — teste na Task 1.
- **E-mail com espaços antes/depois** (colado do e-mail da universidade): aceito e salvo sem os espaços — teste na Task 6.
- **"Concluído" no teclado depois da senha:** entra, como o botão — teste na Task 6.
- **Senha em lugar nenhum:** depois de entrar, nenhuma preferência salva contém a senha — teste na Task 6.

---

### Task 1: Sessão e instituições no domínio, repositório sobre `SharedPreferences`

**Files:**
- Create: `lib/features/auth/domain/session.dart`
- Create: `lib/features/auth/domain/institution.dart`
- Create: `lib/features/auth/data/session_repository.dart`
- Test: `test/session_repository_test.dart`

**Interfaces:**
- Produces: `class Session { const Session({required String email, required String institutionId}); final String email; final String institutionId; }` com `==`/`hashCode` por valor; `class Institution { const Institution({required String id, required String name}); }`; `abstract final class Institutions { static const List<Institution> all; }` (`utfpr` UTFPR, `ufpr` UFPR, `pucpr` PUCPR, `uel` UEL); `abstract class SessionRepository { Future<Session?> load(); Future<void> save(Session session); Future<void> clear(); }`; `class SharedPrefsSessionRepository implements SessionRepository` (const; `static const emailKey = 'session_email'`, `static const institutionKey = 'session_institution'`).

- [ ] **Step 1: Escrever o teste que falha** — `test/session_repository_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:uni_cronos/features/auth/data/session_repository.dart';
import 'package:uni_cronos/features/auth/domain/institution.dart';
import 'package:uni_cronos/features/auth/domain/session.dart';

void main() {
  const repository = SharedPrefsSessionRepository();
  const session = Session(
    email: 'ana.souza@alunos.utfpr.edu.br',
    institutionId: 'utfpr',
  );

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('CA-04: a saved session is stored under the session keys and loads '
      'back', () async {
    await repository.save(session);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('session_email'), session.email);
    expect(prefs.getString('session_institution'), 'utfpr');
    expect(await repository.load(), session);
  });

  test('CA-05: with nothing saved there is no session', () async {
    expect(await repository.load(), isNull);
  });

  test('CA-05: a half-saved session counts as no session', () async {
    SharedPreferences.setMockInitialValues({'session_email': session.email});
    expect(await repository.load(), isNull);

    SharedPreferences.setMockInitialValues({'session_institution': 'utfpr'});
    expect(await repository.load(), isNull);
  });

  test('CA-07: clearing removes the session', () async {
    await repository.save(session);

    await repository.clear();

    expect(await repository.load(), isNull);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.containsKey('session_email'), isFalse);
    expect(prefs.containsKey('session_institution'), isFalse);
  });

  test('CA-04: the institutions are UTFPR, UFPR, PUCPR and UEL', () {
    expect(
      [for (final i in Institutions.all) (i.id, i.name)],
      [('utfpr', 'UTFPR'), ('ufpr', 'UFPR'), ('pucpr', 'PUCPR'), ('uel', 'UEL')],
    );
  });
}
```

- [ ] **Step 2: Rodar e ver falhar**

Run: `flutter test test/session_repository_test.dart`
Expected: FAIL de compilação — arquivos de `lib/features/auth/` não existem.

- [ ] **Step 3: Implementação mínima**

`lib/features/auth/domain/session.dart`:

```dart
import 'package:flutter/foundation.dart';

/// Who is signed in on this device. The password is never part of it.
@immutable
class Session {
  const Session({required this.email, required this.institutionId});

  final String email;
  final String institutionId;

  @override
  bool operator ==(Object other) =>
      other is Session &&
      other.email == email &&
      other.institutionId == institutionId;

  @override
  int get hashCode => Object.hash(email, institutionId);
}
```

`lib/features/auth/domain/institution.dart`:

```dart
/// A university the student can sign in with.
class Institution {
  const Institution({required this.id, required this.name});

  final String id;
  final String name;
}

/// The universities the prototype offers.
abstract final class Institutions {
  static const all = [
    Institution(id: 'utfpr', name: 'UTFPR'),
    Institution(id: 'ufpr', name: 'UFPR'),
    Institution(id: 'pucpr', name: 'PUCPR'),
    Institution(id: 'uel', name: 'UEL'),
  ];
}
```

`lib/features/auth/data/session_repository.dart`:

```dart
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/session.dart';

/// Where the session of this device is kept.
abstract class SessionRepository {
  Future<Session?> load();
  Future<void> save(Session session);
  Future<void> clear();
}

/// Keeps the session in the device preferences. Only the e-mail and the
/// institution are stored; a session missing either one is no session.
class SharedPrefsSessionRepository implements SessionRepository {
  const SharedPrefsSessionRepository();

  static const emailKey = 'session_email';
  static const institutionKey = 'session_institution';

  @override
  Future<Session?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(emailKey);
    final institutionId = prefs.getString(institutionKey);
    if (email == null || email.isEmpty) return null;
    if (institutionId == null || institutionId.isEmpty) return null;
    return Session(email: email, institutionId: institutionId);
  }

  @override
  Future<void> save(Session session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(emailKey, session.email);
    await prefs.setString(institutionKey, session.institutionId);
  }

  @override
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(emailKey);
    await prefs.remove(institutionKey);
  }
}
```

- [ ] **Step 4: Rodar e ver passar**

Run: `flutter test test/session_repository_test.dart`
Expected: PASS (5 testes).

- [ ] **Step 5: Gates e commit**

```bash
dart format lib test && flutter analyze && dart run custom_lint && flutter test
git add lib/features/auth/ test/session_repository_test.dart
git commit -m "feat: guarda a sessão do aluno no aparelho"
```

---

### Task 2: `SessionCubit`

**Files:**
- Create: `lib/features/auth/presentation/session_cubit.dart`
- Test: `test/session_cubit_test.dart`

**Interfaces:**
- Consumes: `Session`, `SessionRepository` (Task 1).
- Produces: `class SessionCubit extends Cubit<Session?>` — `SessionCubit(SessionRepository repository, {Session? initial})`; `Future<void> signIn({required String institutionId, required String email})` (salva e emite a sessão); `Future<void> signOut()` (limpa e emite `null`).

- [ ] **Step 1: Escrever o teste que falha** — `test/session_cubit_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';

import 'package:uni_cronos/features/auth/data/session_repository.dart';
import 'package:uni_cronos/features/auth/domain/session.dart';
import 'package:uni_cronos/features/auth/presentation/session_cubit.dart';

class _MemorySessionRepository implements SessionRepository {
  Session? stored;

  @override
  Future<Session?> load() async => stored;

  @override
  Future<void> save(Session session) async => stored = session;

  @override
  Future<void> clear() async => stored = null;
}

void main() {
  const session = Session(
    email: 'ana.souza@alunos.utfpr.edu.br',
    institutionId: 'utfpr',
  );

  test('CA-05: starts from the session it is given', () {
    final cubit = SessionCubit(_MemorySessionRepository(), initial: session);
    addTearDown(cubit.close);

    expect(cubit.state, session);
  });

  test('CA-04: signing in saves the session and emits it', () async {
    final repository = _MemorySessionRepository();
    final cubit = SessionCubit(repository);
    addTearDown(cubit.close);

    await cubit.signIn(institutionId: 'utfpr', email: session.email);

    expect(cubit.state, session);
    expect(repository.stored, session);
  });

  test('CA-07: signing out clears the session and emits null', () async {
    final repository = _MemorySessionRepository()..stored = session;
    final cubit = SessionCubit(repository, initial: session);
    addTearDown(cubit.close);

    await cubit.signOut();

    expect(cubit.state, isNull);
    expect(repository.stored, isNull);
  });
}
```

- [ ] **Step 2: Rodar e ver falhar**

Run: `flutter test test/session_cubit_test.dart`
Expected: FAIL de compilação — `session_cubit.dart` não existe.

- [ ] **Step 3: Implementação mínima** — `lib/features/auth/presentation/session_cubit.dart`:

```dart
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/session_repository.dart';
import '../domain/session.dart';

/// Who is signed in: the session, or null. Starts from the session read
/// before the app ran, so "not loaded yet" never looks like "signed out".
class SessionCubit extends Cubit<Session?> {
  SessionCubit(this._repository, {Session? initial}) : super(initial);

  final SessionRepository _repository;

  Future<void> signIn({
    required String institutionId,
    required String email,
  }) async {
    final session = Session(email: email, institutionId: institutionId);
    await _repository.save(session);
    emit(session);
  }

  Future<void> signOut() async {
    await _repository.clear();
    emit(null);
  }
}
```

- [ ] **Step 4: Rodar e ver passar**

Run: `flutter test test/session_cubit_test.dart`
Expected: PASS (3 testes).

- [ ] **Step 5: Gates e commit**

```bash
dart format lib test && flutter analyze && dart run custom_lint && flutter test
git add lib/features/auth/presentation/session_cubit.dart test/session_cubit_test.dart
git commit -m "feat: controla a sessão com um Cubit"
```

---

### Task 3: `redirect` com sessão (CA-01, CA-06, CA-09 — regra pura)

**Files:**
- Modify: `lib/core/navigation/app_routes.dart` (acrescenta `login`)
- Modify: `lib/app/app_router.dart` (`resolveRedirect` e a chamada dele)
- Modify: `test/app_router_redirect_test.dart`

**Interfaces:**
- Produces: `AppRoutes.login = '/login'`; `AppRouter.resolveRedirect({required String location, required bool enforceUpgradeGate, required bool shouldBlock, required bool signedIn}) → String?`.

- [ ] **Step 1: Escrever os testes que falham** — em `test/app_router_redirect_test.dart`: **acrescentar `signedIn: true,`** a todas as chamadas existentes de `resolveRedirect` (declarado: a assinatura ganha um parâmetro obrigatório; o comportamento que esses testes verificam não muda) e acrescentar ao `main()`:

```dart
  test('CA-01: without a session, every shell path goes to /login', () {
    for (final path in [
      AppRoutes.dashboard,
      AppRoutes.upload,
      AppRoutes.activities,
      AppRoutes.profile,
    ]) {
      expect(
        AppRouter.resolveRedirect(
          location: path,
          enforceUpgradeGate: true,
          shouldBlock: false,
          signedIn: false,
        ),
        AppRoutes.login,
        reason: path,
      );
    }
  });

  test('CA-01: without a session, the splash and /login stay where they '
      'are', () {
    for (final path in [AppRoutes.splash, AppRoutes.login]) {
      expect(
        AppRouter.resolveRedirect(
          location: path,
          enforceUpgradeGate: true,
          shouldBlock: false,
          signedIn: false,
        ),
        isNull,
        reason: path,
      );
    }
  });

  test('CA-06: with a session, /login goes to /dashboard', () {
    expect(
      AppRouter.resolveRedirect(
        location: AppRoutes.login,
        enforceUpgradeGate: true,
        shouldBlock: false,
        signedIn: true,
      ),
      AppRoutes.dashboard,
    );
  });

  test('CA-09: a blocking gate wins over the session, signed in or not', () {
    for (final signedIn in [true, false]) {
      expect(
        AppRouter.resolveRedirect(
          location: AppRoutes.login,
          enforceUpgradeGate: true,
          shouldBlock: true,
          signedIn: signedIn,
        ),
        AppRoutes.upgradeRequired,
        reason: 'signedIn: $signedIn',
      );
    }
  });

  test('CA-09: when the gate releases without a session, /upgrade-required '
      'goes to /login', () {
    expect(
      AppRouter.resolveRedirect(
        location: AppRoutes.upgradeRequired,
        enforceUpgradeGate: true,
        shouldBlock: false,
        signedIn: false,
      ),
      AppRoutes.login,
    );
  });
```

- [ ] **Step 2: Rodar e ver falhar**

Run: `flutter test test/app_router_redirect_test.dart`
Expected: FAIL de compilação — `No named parameter with the name 'signedIn'` / `Member not found: 'login'`.

- [ ] **Step 3: Implementação mínima**

`lib/core/navigation/app_routes.dart`: acrescentar `static const login = '/login';` logo depois de `splash`.

`lib/app/app_router.dart` — substituir `resolveRedirect` inteiro:

```dart
  /// Where to send [location], or null to stay. Order: the splash always
  /// completes its run; a blocking upgrade gate wins over everything; without
  /// a session only /login is reachable; with one, /login goes to the
  /// dashboard.
  static String? resolveRedirect({
    required String location,
    required bool enforceUpgradeGate,
    required bool shouldBlock,
    required bool signedIn,
  }) {
    if (location == AppRoutes.splash) return null;

    if (enforceUpgradeGate) {
      if (shouldBlock) {
        return location == AppRoutes.upgradeRequired
            ? null
            : AppRoutes.upgradeRequired;
      }
      if (location == AppRoutes.upgradeRequired) {
        return signedIn ? AppRoutes.dashboard : AppRoutes.login;
      }
    }

    if (!signedIn) {
      return location == AppRoutes.login ? null : AppRoutes.login;
    }
    return location == AppRoutes.login ? AppRoutes.dashboard : null;
  }
```

e, na chamada dentro de `build`, passar provisoriamente `signedIn: true,` (a Task 4 liga ao `SessionCubit`).

- [ ] **Step 4: Rodar e ver passar**

Run: `flutter test test/app_router_redirect_test.dart`
Expected: PASS (todos).

- [ ] **Step 5: Gates e commit**

```bash
dart format lib test && flutter analyze && dart run custom_lint && flutter test
git add lib/core/navigation/app_routes.dart lib/app/app_router.dart test/app_router_redirect_test.dart
git commit -m "feat: leva ao login quem não tem sessão, no redirect"
```

---

### Task 4: Sessão ligada ao app — carregada antes do `runApp`, escutada pelo router (CA-01, CA-05, CA-07)

**Files:**
- Create: `lib/core/navigation/stream_listenable.dart`
- Create: `lib/features/auth/presentation/login_page.dart` (só a marca; o formulário é a Task 5)
- Modify: `lib/app/app_router.dart` (rota `/login`; `session`; `refreshListenable`)
- Modify: `lib/app/app.dart` (`_buildRouter` passa o `SessionCubit`)
- Modify: `lib/app/app_providers.dart` (`SessionCubit`)
- Modify: `lib/app/app_bootstrap.dart` (carrega a sessão)
- Modify: `lib/main.dart` (`initialSession`)
- Modify: `test/app_harness.dart` (`signedIn`, sessão pré-carregada)
- Test: `test/session_routing_test.dart`

**Interfaces:**
- Consumes: `SessionCubit`, `SharedPrefsSessionRepository` (Tasks 1–2); `resolveRedirect(..., signedIn:)` (Task 3).
- Produces: `AppRouter.build({required bool enforceUpgradeGate, required UpgradeGateController upgradeGate, required SessionCubit session, Duration splashDuration = const Duration(seconds: 3)})`; `AppProviders({required Widget child, NotificationsPreference? notificationsPreference, SessionRepository? sessionRepository, Session? initialSession})`; `AppBootstrapResult.session` (`Session?`); `LoginPage()`; `StreamListenable(Stream<Object?>)`; harness `pumpRoutedApp(tester, {prefs, notifications, bool signedIn = true})` e `const demoSessionPrefs`.

- [ ] **Step 1: Harness** — em `test/app_harness.dart`:

```dart
/// Saved session of the fictitious student, so tests start signed in.
const demoSessionPrefs = <String, Object>{
  SharedPrefsSessionRepository.emailKey: 'ana.souza@alunos.utfpr.edu.br',
  SharedPrefsSessionRepository.institutionKey: 'utfpr',
};
```

e no `pumpRoutedApp`: novo parâmetro `bool signedIn = true`; `SharedPreferences.setMockInitialValues({if (signedIn) ...demoSessionPrefs, ...prefs});`; logo depois `final session = await const SharedPrefsSessionRepository().load();` e `AppProviders(initialSession: session, notificationsPreference: …, child: const MyApp(...))`. Import de `package:uni_cronos/features/auth/data/session_repository.dart`.

- [ ] **Step 2: Escrever os testes que falham** — `test/session_routing_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:uni_cronos/app/shell/app_shell.dart';
import 'package:uni_cronos/core/navigation/app_routes.dart';
import 'package:uni_cronos/features/auth/presentation/session_cubit.dart';

import 'app_harness.dart';

void main() {
  testWidgets('CA-01: without a saved session, after the splash the app is '
      'on /login with no bottom bar', (tester) async {
    await pumpRoutedApp(tester, signedIn: false);

    expect(currentPath(), AppRoutes.login);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('CA-05: with a saved session, after the splash the app is on '
      '/dashboard', (tester) async {
    await pumpRoutedApp(tester);

    expect(currentPath(), AppRoutes.dashboard);
  });

  testWidgets('CA-07: signing out clears the session and goes to /login', (
    tester,
  ) async {
    await pumpRoutedApp(tester);

    await tester
        .element(find.byType(AppShell))
        .read<SessionCubit>()
        .signOut();
    await tester.pumpAndSettle();

    expect(currentPath(), AppRoutes.login);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.containsKey('session_email'), isFalse);
  });
}
```

- [ ] **Step 3: Rodar e ver falhar**

Run: `flutter test test/session_routing_test.dart`
Expected: FAIL de compilação — `No named parameter with the name 'initialSession'`.

- [ ] **Step 4: `StreamListenable`** — `lib/core/navigation/stream_listenable.dart`:

```dart
import 'dart:async';

import 'package:flutter/foundation.dart';

/// Turns a stream into a [Listenable], so the router runs its redirect again
/// each time the stream emits.
class StreamListenable extends ChangeNotifier {
  StreamListenable(Stream<Object?> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<Object?> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
```

- [ ] **Step 5: Página de login provisória** — `lib/features/auth/presentation/login_page.dart`:

```dart
import 'package:flutter/material.dart';

import '../../../app/app_info.dart';
import '../../../core/theme/app_tokens.dart';

/// Sign-in screen of the prototype.
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screenGutter),
          children: [
            Text(
              kAppName,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 6: Router** — em `lib/app/app_router.dart`: parâmetro `required SessionCubit session` em `build`; trocar `refreshListenable: upgradeGate,` por `refreshListenable: Listenable.merge([upgradeGate, StreamListenable(session.stream)]),`; na chamada do `resolveRedirect`, `signedIn: session.state != null,`; acrescentar a rota, antes do `StatefulShellRoute`:

```dart
        GoRoute(
          path: AppRoutes.login,
          pageBuilder: (context, state) => AppTransitions.fade(
            context: context,
            state: state,
            child: const LoginPage(),
          ),
        ),
```

Imports: `../core/navigation/stream_listenable.dart`, `../features/auth/presentation/login_page.dart`, `../features/auth/presentation/session_cubit.dart`.

- [ ] **Step 7: `MyApp`** — em `lib/app/app.dart`, `_buildRouter` passa `session: context.read<SessionCubit>(),` ao `AppRouter.build` (import de `session_cubit.dart`; `flutter_bloc` já é importado).

- [ ] **Step 8: Providers** — em `lib/app/app_providers.dart`: campos `final SessionRepository? sessionRepository;` e `final Session? initialSession;` (construtor continua `const`; doc: "The session read before the app ran; null when nobody is signed in.") e o provider:

```dart
        BlocProvider(
          create: (_) => SessionCubit(
            sessionRepository ?? const SharedPrefsSessionRepository(),
            initial: initialSession,
          ),
        ),
```

- [ ] **Step 9: Bootstrap e `main`** — `AppBootstrapResult` ganha `final Session? session;` (obrigatório no construtor). Em `AppBootstrap.initialize()`, antes do `return`:

```dart
    Session? session;
    try {
      session = await const SharedPrefsSessionRepository().load();
    } catch (e) {
      // Never log the session itself: it holds personal data.
      debugPrint('Session load failed: ${e.runtimeType}');
    }
```

e `session: session` no `AppBootstrapResult`. Em `lib/main.dart`: `AppProviders(initialSession: bootstrap.session, child: …)` (sem `const`).

- [ ] **Step 10: Rodar e ver passar**

Run: `flutter test test/session_routing_test.dart test/app_shell_test.dart test/font_licenses_test.dart`
Expected: PASS (a casca continua abrindo no Dashboard porque o harness entra com sessão).

- [ ] **Step 11: Gates e commit**

```bash
dart format lib test && flutter analyze && dart run custom_lint && flutter test
git add lib/core/navigation/stream_listenable.dart lib/features/auth/presentation/login_page.dart lib/app/app_router.dart lib/app/app.dart lib/app/app_providers.dart lib/app/app_bootstrap.dart lib/main.dart test/app_harness.dart test/session_routing_test.dart
git commit -m "feat: protege a casca com a sessão carregada antes de abrir o app"
```

---

### Task 5: Formulário de login e validação por campo (CA-02, CA-03)

**Files:**
- Create: `lib/features/auth/domain/email_format.dart`
- Modify: `lib/features/auth/presentation/login_page.dart` (vira `StatefulWidget` com o formulário)
- Modify: `lib/l10n/app_pt.arb`, `app_en.arb`, `app_es.arb` + gerados
- Test: `test/login_page_test.dart`

**Interfaces:**
- Consumes: `Institutions.all` (Task 1); harness `pumpRoutedApp(signedIn: false)` (Task 4).
- Produces: `bool isValidEmail(String email)`; `LoginPage` com `_submit()` que só valida (a Task 6 liga a entrada); botões "Esqueci?" e "Solicitar acesso" com `onPressed: () {}` (a Task 7 liga o aviso).

- [ ] **Step 1: Escrever os testes que falham** — `test/login_page_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:uni_cronos/core/navigation/app_routes.dart';

import 'app_harness.dart';

Finder emailField() =>
    find.widgetWithText(TextFormField, 'aluno@universidade.edu.br');

void main() {
  testWidgets('CA-02: signing in with everything empty shows the three '
      'field errors and stays on /login', (tester) async {
    await pumpRoutedApp(tester, signedIn: false);

    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(find.text('Escolha sua instituição'), findsOneWidget);
    expect(find.text('Informe seu e-mail acadêmico'), findsOneWidget);
    expect(find.text('Informe sua senha'), findsOneWidget);
    expect(currentPath(), AppRoutes.login);
  });

  testWidgets('CA-03: an e-mail without a valid format shows E-mail '
      'inválido', (tester) async {
    await pumpRoutedApp(tester, signedIn: false);

    await tester.enterText(emailField(), 'ana@');
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(find.text('E-mail inválido'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Rodar e ver falhar**

Run: `flutter test test/login_page_test.dart`
Expected: FAIL — `Found 0 widgets with text "Entrar"`.

- [ ] **Step 3: Textos** — nos três ARBs, depois de `"shellMenuSemantics"`, na mesma posição nos três:

| chave | pt | en | es |
|---|---|---|---|
| `loginSubtitle` | Acesse seus recursos acadêmicos. | Access your academic resources. | Accede a tus recursos académicos. |
| `loginInstitutionLabel` | Instituição | Institution | Institución |
| `loginInstitutionHint` | Selecione sua universidade… | Select your university… | Selecciona tu universidad… |
| `loginEmailLabel` | E-mail acadêmico | Academic e-mail | Correo académico |
| `loginEmailHint` | aluno@universidade.edu.br | student@university.edu | estudiante@universidad.edu |
| `loginPasswordLabel` | Senha | Password | Contraseña |
| `loginForgotPassword` | Esqueci? | Forgot? | ¿La olvidaste? |
| `loginShowPassword` | Mostrar senha | Show password | Mostrar contraseña |
| `loginHidePassword` | Ocultar senha | Hide password | Ocultar contraseña |
| `loginSubmit` | Entrar | Sign in | Entrar |
| `loginNewHere` | Novo por aqui? | New here? | ¿Eres nuevo? |
| `loginRequestAccess` | Solicitar acesso | Request access | Solicitar acceso |
| `loginInstitutionRequired` | Escolha sua instituição | Choose your institution | Elige tu institución |
| `loginEmailRequired` | Informe seu e-mail acadêmico | Enter your academic e-mail | Ingresa tu correo académico |
| `loginEmailInvalid` | E-mail inválido | Invalid e-mail | Correo inválido |
| `loginPasswordRequired` | Informe sua senha | Enter your password | Ingresa tu contraseña |

Run: `flutter gen-l10n`

- [ ] **Step 4: Formato de e-mail** — `lib/features/auth/domain/email_format.dart`:

```dart
final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

/// Whether [email] looks like an e-mail address. A format check only: it
/// says nothing about the address existing.
bool isValidEmail(String email) => _emailPattern.hasMatch(email);
```

- [ ] **Step 5: Formulário** — substituir `lib/features/auth/presentation/login_page.dart` por:

```dart
import 'package:flutter/material.dart';

import '../../../app/app_info.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/email_format.dart';
import '../domain/institution.dart';

/// Sign-in screen of the prototype: it checks the format of what is typed and
/// keeps the session on this device. No server is consulted.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? _institutionId;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
  }

  InputDecoration _decoration({String? hint}) => InputDecoration(
    hintText: hint,
    border: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppRadii.sm)),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenGutter),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.xxl),
                Center(
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: cs.primaryContainer,
                    child: Icon(
                      Icons.school_outlined,
                      color: cs.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  kAppName,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.loginSubtitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                _FieldLabel(l10n.loginInstitutionLabel),
                DropdownButtonFormField<String>(
                  initialValue: _institutionId,
                  hint: Text(l10n.loginInstitutionHint),
                  decoration: _decoration(),
                  items: [
                    for (final institution in Institutions.all)
                      DropdownMenuItem(
                        value: institution.id,
                        child: Text(institution.name),
                      ),
                  ],
                  onChanged: (id) => setState(() => _institutionId = id),
                  validator: (id) =>
                      id == null ? l10n.loginInstitutionRequired : null,
                ),
                const SizedBox(height: AppSpacing.lg),
                _FieldLabel(l10n.loginEmailLabel),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  textInputAction: TextInputAction.next,
                  decoration: _decoration(hint: l10n.loginEmailHint),
                  validator: (value) {
                    final email = value?.trim() ?? '';
                    if (email.isEmpty) return l10n.loginEmailRequired;
                    if (!isValidEmail(email)) return l10n.loginEmailInvalid;
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(child: _FieldLabel(l10n.loginPasswordLabel)),
                    TextButton(
                      onPressed: () {},
                      child: Text(l10n.loginForgotPassword),
                    ),
                  ],
                ),
                TextFormField(
                  controller: _password,
                  obscureText: _obscurePassword,
                  autofillHints: const [AutofillHints.password],
                  textInputAction: TextInputAction.done,
                  decoration: _decoration().copyWith(
                    suffixIcon: IconButton(
                      tooltip: _obscurePassword
                          ? l10n.loginShowPassword
                          : l10n.loginHidePassword,
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () => setState(
                        () => _obscurePassword = !_obscurePassword,
                      ),
                    ),
                  ),
                  validator: (value) =>
                      (value ?? '').isEmpty ? l10n.loginPasswordRequired : null,
                ),
                const SizedBox(height: AppSpacing.xl),
                FilledButton(onPressed: _submit, child: Text(l10n.loginSubmit)),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(l10n.loginNewHere, style: theme.textTheme.bodyMedium),
                    TextButton(
                      onPressed: () {},
                      child: Text(l10n.loginRequestAccess),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Text(text, style: Theme.of(context).textTheme.labelLarge),
    );
  }
}
```

- [ ] **Step 6: Rodar e ver passar**

Run: `flutter test test/login_page_test.dart`
Expected: PASS (2 testes).

- [ ] **Step 7: Gates e commit**

```bash
dart format lib test && flutter analyze && dart run custom_lint && flutter test
git add lib/features/auth/domain/email_format.dart lib/features/auth/presentation/login_page.dart lib/l10n/ test/login_page_test.dart
git commit -m "feat: monta o formulário de login com erro por campo"
```

---

### Task 6: Entrar salva a sessão e abre o Dashboard (CA-04)

**Files:**
- Modify: `lib/features/auth/presentation/login_page.dart` (`_submit` entra; senha envia pelo teclado)
- Test: `test/login_page_test.dart`

**Interfaces:**
- Consumes: `SessionCubit.signIn` (Task 2), `LoginPage` (Task 5).

- [ ] **Step 1: Escrever os testes que falham** — acrescentar a `test/login_page_test.dart` (imports extras: `package:shared_preferences/shared_preferences.dart`):

```dart
  Future<void> fillIn(
    WidgetTester tester, {
    String email = 'ana.souza@alunos.utfpr.edu.br',
  }) async {
    await tester.tap(find.text('Selecione sua universidade…'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('UTFPR').last);
    await tester.pumpAndSettle();
    await tester.enterText(emailField(), email);
    await tester.enterText(
      find.byWidgetPredicate(
        (w) => w is EditableText && w.obscureText,
      ),
      'x',
    );
  }

  testWidgets('CA-04: valid institution, e-mail and password sign in, save '
      'the session and open /dashboard', (tester) async {
    await pumpRoutedApp(tester, signedIn: false);
    await fillIn(tester);

    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(currentPath(), AppRoutes.dashboard);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('session_email'), 'ana.souza@alunos.utfpr.edu.br');
    expect(prefs.getString('session_institution'), 'utfpr');
  });

  testWidgets('CA-04: the password is saved nowhere', (tester) async {
    await pumpRoutedApp(tester, signedIn: false);
    await fillIn(tester);

    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    for (final key in prefs.getKeys()) {
      expect(key.toLowerCase(), isNot(contains('password')), reason: key);
      expect(prefs.get(key), isNot('x'), reason: key);
    }
  });

  testWidgets('CA-04: spaces around the e-mail are dropped', (tester) async {
    await pumpRoutedApp(tester, signedIn: false);
    await fillIn(tester, email: '  ana.souza@alunos.utfpr.edu.br  ');

    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('session_email'), 'ana.souza@alunos.utfpr.edu.br');
  });

  testWidgets('CA-04: pressing done on the keyboard after the password signs '
      'in', (tester) async {
    await pumpRoutedApp(tester, signedIn: false);
    await fillIn(tester);

    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(currentPath(), AppRoutes.dashboard);
  });
```

- [ ] **Step 2: Rodar e ver falhar**

Run: `flutter test test/login_page_test.dart --plain-name "CA-04"`
Expected: FAIL — `Expected: '/dashboard' Actual: '/login'` (o formulário valida mas não entra).

- [ ] **Step 3: Implementação mínima** — em `login_page.dart`: import de `package:flutter_bloc/flutter_bloc.dart` e `session_cubit.dart`; `_submit` passa a:

```dart
  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await context.read<SessionCubit>().signIn(
      institutionId: _institutionId!,
      email: _email.text.trim(),
    );
  }
```

e o campo de senha ganha `onFieldSubmitted: (_) => _submit(),`. A navegação acontece sozinha: o router escuta o `SessionCubit`.

- [ ] **Step 4: Rodar e ver passar**

Run: `flutter test test/login_page_test.dart`
Expected: PASS (6 testes).

- [ ] **Step 5: Gates e commit**

```bash
dart format lib test && flutter analyze && dart run custom_lint && flutter test
git add lib/features/auth/presentation/login_page.dart test/login_page_test.dart
git commit -m "feat: entra com o login simulado e abre o Dashboard"
```

---

### Task 7: "Esqueci?" e "Solicitar acesso" avisam "Disponível em breve" (CA-08)

**Files:**
- Modify: `lib/features/auth/presentation/login_page.dart`
- Modify: ARBs + gerados (`comingSoon`)
- Test: `test/login_page_test.dart`

- [ ] **Step 1: Escrever o teste que falha** — acrescentar a `test/login_page_test.dart`:

```dart
  for (final link in ['Esqueci?', 'Solicitar acesso']) {
    testWidgets('CA-08: $link says Disponível em breve', (tester) async {
      await pumpRoutedApp(tester, signedIn: false);

      await tester.tap(find.text(link));
      await tester.pump();

      expect(find.text('Disponível em breve'), findsOneWidget);
    });
  }
```

- [ ] **Step 2: Rodar e ver falhar**

Run: `flutter test test/login_page_test.dart --plain-name "CA-08"`
Expected: FAIL — `Found 0 widgets with text "Disponível em breve"`.

- [ ] **Step 3: Implementação mínima** — nos três ARBs, depois de `"loginPasswordRequired"`: pt `"comingSoon": "Disponível em breve"`, en `"comingSoon": "Coming soon"`, es `"comingSoon": "Disponible pronto"`; `flutter gen-l10n`. Em `login_page.dart` (import `package:next_widgets_service/next_widgets_service.dart`):

```dart
  void _comingSoon() {
    NextSnack.showNextSnack(
      context,
      message: AppLocalizations.of(context)!.comingSoon,
    );
  }
```

e os dois `TextButton` passam a `onPressed: _comingSoon`.

- [ ] **Step 4: Rodar e ver passar**

Run: `flutter test test/login_page_test.dart`
Expected: PASS (8 testes).

- [ ] **Step 5: Gates e commit**

```bash
dart format lib test && flutter analyze && dart run custom_lint && flutter test
git add lib/features/auth/presentation/login_page.dart lib/l10n/ test/login_page_test.dart
git commit -m "feat: avisa que recuperar senha e solicitar acesso chegam em breve"
```

---

### Task 8: Fechar a spec 007

**Files:**
- Modify: `docs/specs/007-login-e-sessao.md` (status, decisões)
- Modify: `docs/architecture.md`, `docs/conventions.md` (via `/destilar 007`)

- [ ] **Step 1: Gates finais** — os quatro, com os números reais.

- [ ] **Step 2: Verificação manual no web** — `flutter run -d web-server --web-port 8080`, 390×844, janela anônima: splash → login; erros por campo; entrar com UTFPR → Dashboard; recarregar a página continua no Dashboard (sessão salva); "Esqueci?" → aviso; o olho mostra/oculta a senha; textos em pt, en e es (via Configurações do avatar depois de entrar). "Sair" só chega com o Perfil (010).

- [ ] **Step 3: Decisões durante a implementação** — no mínimo: sessão lida antes do `runApp` e passada como estado inicial do `SessionCubit` (o contrato `Cubit<Session?>` não distingue "carregando" de "sem sessão"); `resolveRedirect` ganhou `signedIn` e os testes antigos receberam `signedIn: true`; harness entra com sessão por padrão (`demoSessionPrefs`); validação só no cliente — é UX de protótipo, não segurança (SECURITY.md exige validação no servidor quando houver autenticação real); o e-mail fica em texto nas preferências do aparelho (`localStorage` no web) — aceitável no protótipo, a rever com autenticação real; o olho da senha não tem teste próprio. Marcar `status: implementada`.

- [ ] **Step 4: Destilar** — `/destilar 007`: `docs/architecture.md` ganha a autenticação simulada (sessão, `redirect` completo, rota `/login` fora da casca) e `docs/conventions.md` o `signedIn`/`demoSessionPrefs` do harness.

- [ ] **Step 5: Commit**

```bash
git add docs/specs/007-login-e-sessao.md docs/architecture.md docs/conventions.md
git commit -m "docs: fecha a spec do login e descreve a sessão"
```
