import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:uni_cronos/app/app.dart';
import 'package:uni_cronos/app/app_providers.dart';
import 'package:uni_cronos/app/app_router.dart';
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

/// Pumps the real app — splash, router and shell — with [prefs] stored and
/// no splash wait, and settles on the first screen after the splash.
Future<void> pumpRoutedApp(
  WidgetTester tester, {
  Map<String, Object> prefs = const {},
  NotificationsPreference? notifications,
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
