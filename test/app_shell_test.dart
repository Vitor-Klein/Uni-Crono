import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:uni_cronos/app/app_router.dart';
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

    GoRouter.of(
      AppRouter.navigatorKey.currentContext!,
    ).go(AppRoutes.activities);
    await tester.pumpAndSettle();

    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      2,
    );
  });
}
