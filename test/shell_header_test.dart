import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:uni_cronos/app/shell/shell_app_bar.dart';

import 'app_harness.dart';

Finder _inHeader(Finder finder) =>
    find.descendant(of: find.byType(ShellAppBar), matching: finder);

void main() {
  testWidgets('CA-01: on the dashboard the header shows the filled cap and '
      'the brand, and no greeting', (tester) async {
    await pumpRoutedApp(tester);

    expect(_inHeader(find.byIcon(Icons.school)), findsOneWidget);
    expect(_inHeader(find.text('Uni Cronos')), findsOneWidget);
    expect(_inHeader(find.textContaining('Olá')), findsNothing);
  });

  testWidgets('CA-11: the cap is painted in the dark brown of the scheme', (
    tester,
  ) async {
    await pumpRoutedApp(tester);

    final cap = tester.widget<Icon>(_inHeader(find.byIcon(Icons.school)));
    final cs = Theme.of(tester.element(find.byType(ShellAppBar))).colorScheme;
    expect(cap.color, cs.tertiary);
  });

  testWidgets('CA-15: the brand reads "Uni" in dark brown and "Cronos" in '
      'gold', (tester) async {
    await pumpRoutedApp(tester);

    final brand = tester.widget<Text>(_inHeader(find.text('Uni Cronos')));
    final cs = Theme.of(tester.element(find.byType(ShellAppBar))).colorScheme;
    final colors = <String, Color?>{};
    brand.textSpan!.visitChildren((span) {
      if (span is TextSpan && (span.text?.trim().isNotEmpty ?? false)) {
        colors[span.text!.trim()] = span.style?.color;
      }
      return true;
    });
    expect(colors, {'Uni': cs.tertiary, 'Cronos': cs.primaryFixedDim});
  });

  testWidgets(
    'CA-17: the top-right button is the nine-dot "more" icon, not the '
    "student's initials",
    (tester) async {
      await pumpRoutedApp(tester);

      expect(_inHeader(find.byIcon(Icons.apps_outlined)), findsOneWidget);
      expect(_inHeader(find.text('AS')), findsNothing);
    },
  );

  testWidgets('CA-16: the brand is set large and bold, in the headline size', (
    tester,
  ) async {
    await pumpRoutedApp(tester);

    final brand = tester.widget<Text>(_inHeader(find.text('Uni Cronos')));
    final theme = Theme.of(tester.element(find.byType(ShellAppBar)));
    final spans = <TextStyle?>[];
    brand.textSpan!.visitChildren((span) {
      if (span is TextSpan && span.text != null) spans.add(span.style);
      return true;
    });
    for (final style in spans) {
      expect(style?.fontSize, theme.textTheme.headlineSmall!.fontSize);
      expect(style?.fontWeight, FontWeight.w700);
    }
  });

  for (final tab in ['Enviar', 'Atividades']) {
    testWidgets('CA-04: on $tab the header shows the cap and the brand at the '
        'dashboard height', (tester) async {
      await pumpRoutedApp(tester);
      final dashboardHeight = tester.getSize(find.byType(ShellAppBar)).height;

      await tester.tap(navLabel(tab));
      await tester.pumpAndSettle();

      expect(_inHeader(find.byIcon(Icons.school)), findsOneWidget);
      expect(_inHeader(find.text('Uni Cronos')), findsOneWidget);
      expect(tester.getSize(find.byType(ShellAppBar)).height, dashboardHeight);
    });
  }

  testWidgets('CA-04: the profile has the same header, with the brand and the '
      'menu button', (tester) async {
    await pumpRoutedApp(tester);
    final dashboardHeight = tester.getSize(find.byType(ShellAppBar)).height;

    await tester.tap(navLabel('Perfil'));
    await tester.pumpAndSettle();

    expect(_inHeader(find.text('Uni Cronos')), findsOneWidget);
    expect(_inHeader(find.byIcon(Icons.apps_outlined)), findsOneWidget);
    expect(tester.getSize(find.byType(ShellAppBar)).height, dashboardHeight);
  });

  for (final tab in ['Dashboard', 'Enviar', 'Atividades']) {
    testWidgets(
      'CA-05: on $tab the menu button is a 48dp target that opens the '
      'More modal, and the header has no back button',
      (tester) async {
        await pumpRoutedApp(tester);
        await tester.tap(navLabel(tab));
        await tester.pumpAndSettle();

        final menu = find.bySemanticsLabel('Abrir menu');
        expect(tester.getSize(menu), const Size.square(48));
        expect(_inHeader(find.byType(IconButton)), findsNothing);
        expect(_inHeader(find.byType(BackButton)), findsNothing);

        await tester.tap(menu);
        await tester.pumpAndSettle();

        expect(find.text('MENSAGENS'), findsOneWidget);
      },
    );
  }

  testWidgets('CA-06: the header fits a 320dp screen at 1.5x text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await pumpRoutedApp(tester);

    expect(tester.takeException(), isNull);
  });
}
