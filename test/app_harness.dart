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
String currentPath() => GoRouter.of(
  AppRouter.navigatorKey.currentContext!,
).routerDelegate.currentConfiguration.uri.path;

/// A label of the bottom navigation bar.
Finder navLabel(String text) =>
    find.descendant(of: find.byType(NavigationBar), matching: find.text(text));
