import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:uni_cronos/app/app_router.dart';
import 'package:uni_cronos/app/shell/app_shell.dart';
import 'package:uni_cronos/app/shell/shell_app_bar.dart';
import 'package:uni_cronos/core/navigation/app_routes.dart';
import 'package:uni_cronos/features/opportunities/presentation/opportunities_page.dart';

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

  testWidgets('CA-03: leaving a tab keeps its page alive offstage', (
    tester,
  ) async {
    await pumpRoutedApp(tester);
    await tester.tap(navLabel('Atividades'));
    await tester.pumpAndSettle();
    // The first Scrollable is the page's list (the search field has its own).
    final activitiesState = tester.state(
      find
          .descendant(
            of: find.byType(OpportunitiesPage),
            matching: find.byType(Scrollable),
          )
          .first,
    );

    await tester.tap(navLabel('Dashboard'));
    await tester.pumpAndSettle();

    final offstage = find
        .descendant(
          of: find.byType(OpportunitiesPage, skipOffstage: false),
          matching: find.byType(Scrollable, skipOffstage: false),
        )
        .first;
    expect(offstage, findsOneWidget);
    expect(identical(tester.state(offstage), activitiesState), isTrue);
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

  testWidgets('CA-04: the app bar shows the brand, and the avatar opens the '
      'More modal', (tester) async {
    await pumpRoutedApp(tester);

    expect(
      find.descendant(
        of: find.byType(ShellAppBar),
        matching: find.text('Uni Cronos'),
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('AS'));
    await tester.pumpAndSettle();

    expect(find.text('MENSAGENS'), findsOneWidget);
    expect(find.text('CONFIGURAÇÕES'), findsOneWidget);
  });

  testWidgets('CA-04: the shell app bar has no back button', (tester) async {
    await pumpRoutedApp(tester);

    expect(
      find.descendant(
        of: find.byType(ShellAppBar),
        matching: find.byType(IconButton),
      ),
      findsNothing,
    );
  });

  testWidgets('CA-05: the More modal shows the saved notifications choice on '
      'first open', (tester) async {
    await pumpRoutedApp(
      tester,
      notifications: FakeNotificationsPreference(enabled: false),
    );

    await tester.tap(find.text('AS'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('CONFIGURAÇÕES'));
    await tester.pumpAndSettle();

    expect(find.text('Desativado'), findsOneWidget);
  });

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

  testWidgets('CA-01: the shell opens with the app fade transition, which '
      'honours reduced animations', (tester) async {
    await pumpRoutedApp(tester);

    final route = ModalRoute.of(tester.element(find.byType(AppShell)))!;
    expect(route.settings, isA<CustomTransitionPage<dynamic>>());
  });

  for (final (code, label) in [('en', 'Upload'), ('es', 'Subir')]) {
    testWidgets('CA-01: in $code the second destination reads $label', (
      tester,
    ) async {
      await pumpRoutedApp(tester, prefs: {'preferred_locale': code});

      expect(navLabel(label), findsOneWidget);
      expect(
        tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
        0,
      );
    });
  }

  testWidgets('CA-02: the selected destination label is primary, the others '
      'onSurfaceVariant', (tester) async {
    await pumpRoutedApp(tester);

    final cs = Theme.of(tester.element(find.byType(AppShell))).colorScheme;
    final labelStyle = tester
        .widget<NavigationBar>(find.byType(NavigationBar))
        .labelTextStyle!;
    expect(labelStyle.resolve({WidgetState.selected})!.color, cs.primary);
    expect(labelStyle.resolve({})!.color, cs.onSurfaceVariant);
  });

  testWidgets('CA-04: the avatar is a 48dp target announced only as the menu '
      'button', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpRoutedApp(tester);

    final avatar = find.bySemanticsLabel('Abrir menu');
    expect(avatar, findsOneWidget);
    final size = tester.getSize(avatar);
    expect(size.width, greaterThanOrEqualTo(kMinInteractiveDimension));
    expect(size.height, greaterThanOrEqualTo(kMinInteractiveDimension));
    semantics.dispose();
  });

  testWidgets('CA-04: screen readers can open the More modal from the avatar', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pumpRoutedApp(tester);

    final avatar = find.bySemanticsLabel('Abrir menu');
    expect(
      tester
          .getSemantics(avatar)
          .getSemanticsData()
          .hasAction(SemanticsAction.tap),
      isTrue,
    );
    tester.semantics.tap(find.semantics.byLabel('Abrir menu'));
    await tester.pumpAndSettle();

    expect(find.text('MENSAGENS'), findsOneWidget);
    semantics.dispose();
  });
}
