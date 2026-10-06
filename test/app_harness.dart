import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:uni_cronos/app/app.dart';
import 'package:uni_cronos/app/app_providers.dart';
import 'package:uni_cronos/app/app_router.dart';
import 'package:uni_cronos/features/auth/data/auth_gateway.dart';
import 'package:uni_cronos/features/auth/domain/session.dart';
import 'package:uni_cronos/features/auth/domain/sign_up_data.dart';
import 'package:uni_cronos/features/hours/data/hours_repository.dart';
import 'package:uni_cronos/features/notifications/data/notifications_preference.dart';

/// An in-memory notifications preference that records every write and can be
/// told to fail them.
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

/// The fictitious student every signed-in test uses.
const demoSession = Session(
  userId: 'user-ana',
  email: 'ana.souza@alunos.utfpr.edu.br',
  institutionId: 'utfpr',
);

/// The password of [demoSession] in [FakeAuthGateway].
const demoPassword = 'senha-certa';

/// An account server in memory: it knows [demoSession], can be told to be
/// offline, and records every sign-up.
class FakeAuthGateway implements AuthGateway {
  FakeAuthGateway({Session? signedIn}) : _current = signedIn;

  Session? _current;
  bool offline = false;
  final signUps = <SignUpData>[];
  final _accounts = <String, (String, Session)>{
    demoSession.email: (demoPassword, demoSession),
  };
  final _changes = StreamController<Session?>.broadcast();

  /// Pretends the session expired on the server and could not be renewed.
  void expire() {
    _current = null;
    _changes.add(null);
  }

  @override
  Session? get current => _current;

  @override
  Stream<Session?> changes() => _changes.stream;

  @override
  Future<Session> signIn({
    required String email,
    required String password,
  }) async {
    if (offline) throw const NetworkFailure();
    final account = _accounts[email];
    if (account == null || account.$1 != password) {
      throw const InvalidCredentials();
    }
    return _signedIn(account.$2);
  }

  @override
  Future<Session> signUp(SignUpData data) async {
    if (offline) throw const NetworkFailure();
    if (_accounts.containsKey(data.email)) {
      throw const EmailAlreadyRegistered();
    }
    signUps.add(data);
    final session = Session(
      userId: 'user-${signUps.length}',
      email: data.email,
      institutionId: data.institutionId,
    );
    _accounts[data.email] = (data.password, session);
    return _signedIn(session);
  }

  @override
  Future<void> signOut() async {
    _current = null;
    _changes.add(null);
  }

  Session _signedIn(Session session) {
    _current = session;
    _changes.add(session);
    return session;
  }
}

/// Pumps the real app — splash, router and shell — with [prefs] stored and
/// no splash wait, and settles on the first screen after the splash. Signed
/// in as [demoSession] unless [signedIn] is false or [auth] says otherwise.
Future<void> pumpRoutedApp(
  WidgetTester tester, {
  Map<String, Object> prefs = const {},
  NotificationsPreference? notifications,
  bool signedIn = true,
  FakeAuthGateway? auth,
  HoursRepository? hoursRepository,
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
    AppProviders(
      authGateway:
          auth ?? FakeAuthGateway(signedIn: signedIn ? demoSession : null),
      hoursRepository: hoursRepository,
      notificationsPreference: notifications ?? FakeNotificationsPreference(),
      child: const MyApp(
        enforceUpgradeGate: false,
        splashDuration: Duration.zero,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// The path the router is on.
String currentPath() => GoRouter.of(
  AppRouter.navigatorKey.currentContext!,
).routerDelegate.currentConfiguration.uri.path;

/// A label of the bottom navigation bar.
Finder navLabel(String text) =>
    find.descendant(of: find.byType(NavigationBar), matching: find.text(text));
