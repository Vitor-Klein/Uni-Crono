import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:uni_cronos/features/hours/domain/hours.dart';
import 'package:uni_cronos/features/hours/presentation/dashboard_page.dart';
import 'package:uni_cronos/features/profile/presentation/profile_page.dart';

import 'app_harness.dart';

Future<void> _openProfile(WidgetTester tester) async {
  tester.view.physicalSize = const Size(800, 2000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await pumpRoutedApp(tester);
  await tester.tap(navLabel('Perfil'));
  await tester.pumpAndSettle();
}

Finder _inProfile(Finder finder) =>
    find.descendant(of: find.byType(ProfilePage), matching: finder);

void main() {
  group('profile', () {
    testWidgets('CA-07: the large avatar shows the initials and the card '
        'shows who the student is', (tester) async {
      await _openProfile(tester);

      expect(_inProfile(find.text('AS')), findsOneWidget);
      expect(_inProfile(find.text('Ana Souza')), findsOneWidget);
      expect(
        _inProfile(find.text('UTFPR · Engenharia de Software · 5º período')),
        findsOneWidget,
      );
    });

    testWidgets('CA-08: each summary item has its icon next to its value', (
      tester,
    ) async {
      await _openProfile(tester);

      for (final (icon, value) in [
        (Icons.schedule_outlined, '175 h'),
        (Icons.description_outlined, '5'),
        (Icons.flag_outlined, '74%'),
      ]) {
        expect(_inProfile(find.byIcon(icon)), findsOneWidget, reason: value);
        expect(
          (tester.getCenter(_inProfile(find.byIcon(icon))).dx -
                  tester.getCenter(_inProfile(find.text(value))).dx)
              .abs(),
          lessThan(1),
          reason: '$value sits under its icon',
        );
      }
    });

    testWidgets('CA-09: the preference rows show a chevron and Sair does not', (
      tester,
    ) async {
      await _openProfile(tester);

      for (final title in ['Notificações', 'Idioma', 'Acessibilidade']) {
        expect(
          find.descendant(
            of: find.widgetWithText(ListTile, title),
            matching: find.byIcon(Icons.chevron_right_outlined),
          ),
          findsOneWidget,
          reason: title,
        );
      }
      expect(
        find.descendant(
          of: find.widgetWithText(ListTile, 'Sair'),
          matching: find.byIcon(Icons.chevron_right_outlined),
        ),
        findsNothing,
      );
    });

    for (final (width, scale) in [(320.0, 1.0), (360.0, 1.5)]) {
      testWidgets('CA-10: the profile fits a ${width.toInt()}dp screen at '
          '${scale}x text without overflowing', (tester) async {
        tester.view.physicalSize = Size(width, 2000);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

        await pumpRoutedApp(tester);
        await tester.tap(navLabel('Perfil'));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('CA-13: no card of the profile is filled with the yellow', (
      tester,
    ) async {
      await _openProfile(tester);
      final yellow = Theme.of(
        tester.element(find.byType(ProfilePage)),
      ).colorScheme.primaryContainer;

      final fills = tester
          .widgetList<DecoratedBox>(_inProfile(find.byType(DecoratedBox)))
          .map((box) => box.decoration)
          .whereType<BoxDecoration>()
          .where((d) => d.borderRadius != null)
          .map((d) => d.color);
      expect(fills, isNot(contains(yellow)));
    });
  });

  group('dashboard', () {
    testWidgets('CA-12: each category card shows the share of its goal', (
      tester,
    ) async {
      await pumpRoutedApp(tester);

      Finder inDashboard(Finder f) =>
          find.descendant(of: find.byType(DashboardPage), matching: f);
      expect(inDashboard(find.text('100%')), findsOneWidget);
      expect(inDashboard(find.text('22%')), findsOneWidget);
    });

    testWidgets('CA-12: past the goal the share stays at 100%', (tester) async {
      await pumpRoutedApp(
        tester,
        hoursRepository: FakeHoursRepository([
          ApprovedCertificate(
            id: 'big',
            title: 'Intercâmbio',
            category: HourCategory.complementary,
            hours: 250,
            approvedAt: DateTime(2026, 9, 1),
          ),
        ]),
      );

      expect(
        find.descendant(
          of: find.byType(DashboardPage),
          matching: find.text('100%'),
        ),
        findsOneWidget,
      );
    });
  });

  group('more menu', () {
    testWidgets('CA-14: the More menu lists Mensagens and Configurações and '
        'ends with the app name and version', (tester) async {
      await pumpRoutedApp(tester);

      await tester.tap(find.bySemanticsLabel('Abrir menu'));
      await tester.pumpAndSettle();

      expect(find.text('MENSAGENS'), findsOneWidget);
      expect(find.text('CONFIGURAÇÕES'), findsOneWidget);
      expect(find.text('UNI CRONOS'), findsOneWidget);
      expect(find.text('v1.0.0+1'), findsOneWidget);

      await tester.tap(find.text('CONFIGURAÇÕES'));
      await tester.pumpAndSettle();

      expect(find.text('NOTIFICAÇÕES'), findsOneWidget);
    });
  });
}
