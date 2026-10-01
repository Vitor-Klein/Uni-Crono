import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uni_cronos/features/hours/data/hours_repository.dart';
import 'package:uni_cronos/features/hours/domain/hours.dart';
import 'package:uni_cronos/features/hours/presentation/dashboard_page.dart';

import 'app_harness.dart';

void main() {
  // The title font, so line breaks follow real glyph widths.
  setUpAll(() async {
    final bytes = File('assets/fonts/Montserrat-Medium.ttf').readAsBytesSync();
    await (FontLoader(
      'Montserrat',
    )..addFont(Future.value(ByteData.sublistView(bytes)))).load();
  });

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

  testWidgets('CA-01: the hours sit at the left and the goal at the right end '
      'of each card', (tester) async {
    await pumpRoutedApp(tester);

    final barRight = tester
        .getTopRight(find.byType(LinearProgressIndicator).first)
        .dx;
    final barLeft = tester
        .getTopLeft(find.byType(LinearProgressIndicator).first)
        .dx;
    expect(
      tester.getTopRight(find.text('200 no total')).dx,
      closeTo(barRight, 1),
    );
    expect(tester.getTopLeft(find.text('130 horas')).dx, closeTo(barLeft, 1));
  });

  testWidgets('CA-01: screen readers announce each bar with its category and '
      'its hours', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpRoutedApp(tester);

    final bars = find.byType(LinearProgressIndicator);
    final complementary = tester.getSemantics(bars.at(0));
    final extension = tester.getSemantics(bars.at(1));
    expect(complementary.label, contains('Horas Complementares'));
    expect(complementary.value, '130 de 200 horas');
    expect(extension.label, contains('Horas de Extensão'));
    expect(extension.value, '45 de 100 horas');
    semantics.dispose();
  });

  testWidgets('CA-02: the recent list shows the three approved certificates, '
      'newest first', (tester) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
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
    for (final (title, hours, category) in [
      ('Workshop de Tecnologia Comunitária', '+15 h', 'Horas de Extensão'),
      ('Seminário Avançado de Python', '+8 h', 'Horas Complementares'),
      ('University Game Jam 2024', '+24 h', 'Horas Complementares'),
    ]) {
      final tile = find
          .ancestor(of: find.text(title), matching: find.byType(DecoratedBox))
          .first;
      for (final text in [hours, category, 'Aprovado']) {
        expect(
          find.descendant(of: tile, matching: find.text(text)),
          findsOneWidget,
          reason: '$title: $text',
        );
      }
    }
  });

  testWidgets('CA-03: a certificate added to the repository shows up at once, '
      'with the new total', (tester) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
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

  testWidgets('CA-06: Ver todos says Disponível em breve', (tester) async {
    await pumpRoutedApp(tester);

    await tester.scrollUntilVisible(
      find.text('Ver todos'),
      200,
      scrollable: find.descendant(
        of: find.byType(DashboardPage),
        matching: find.byType(Scrollable),
      ),
    );
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

  for (final (code, word) in [
    ('pt', 'Complementares'),
    ('es', 'Complementarias'),
  ]) {
    testWidgets('CA-01: the card title keeps "$word" whole on a 360dp screen '
        'at 1.15x text', (tester) async {
      tester.view.physicalSize = const Size(360, 760);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 1.15;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await pumpRoutedApp(tester, prefs: {'preferred_locale': code});

      final title = tester.renderObject<RenderParagraph>(
        find.textContaining(word).first,
      );
      final text = title.text.toPlainText();
      final start = text.indexOf(word);
      final boxes = title.getBoxesForSelection(
        TextSelection(baseOffset: start, extentOffset: start + word.length),
      );
      expect(boxes.map((box) => box.top).toSet(), hasLength(1));
    });
  }
}
