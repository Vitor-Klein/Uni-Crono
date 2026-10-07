import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:uni_cronos/features/opportunities/presentation/opportunities_page.dart';

import 'app_harness.dart';

Future<void> _openHub(WidgetTester tester) async {
  tester.view.physicalSize = const Size(800, 3000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await pumpRoutedApp(tester);
  await tester.tap(navLabel('Atividades'));
  await tester.pumpAndSettle();
}

Finder _inHub(Finder finder) =>
    find.descendant(of: find.byType(OpportunitiesPage), matching: finder);

void main() {
  // The title font, so line breaks follow real glyph widths.
  setUpAll(() async {
    final bytes = File('assets/fonts/Montserrat-Bold.ttf').readAsBytesSync();
    await (FontLoader(
      'Montserrat',
    )..addFont(Future.value(ByteData.sublistView(bytes)))).load();
  });

  testWidgets('CA-01: the title stands alone, with no icon badge, large and '
      'bold, to draw the eye', (tester) async {
    await _openHub(tester);

    final title = find.text('Hub de Oportunidades');
    expect(_inHub(find.byIcon(Icons.explore_outlined)), findsNothing);
    final theme = Theme.of(tester.element(title));
    final style = tester.widget<Text>(title).style;
    expect(style?.fontSize, theme.textTheme.headlineLarge!.fontSize);
    expect(style?.fontWeight, FontWeight.w700);
  });

  testWidgets('CA-01: on a 360dp phone the title breaks as "Hub de" over a '
      'whole "Oportunidades"', (tester) async {
    tester.view.physicalSize = const Size(360, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpRoutedApp(tester);
    await tester.tap(navLabel('Atividades'));
    await tester.pumpAndSettle();

    final paragraph = tester.renderObject<RenderParagraph>(
      find.text('Hub de Oportunidades'),
    );
    const word = 'Oportunidades';
    final start = paragraph.text.toPlainText().indexOf(word);
    final wordTops = paragraph
        .getBoxesForSelection(
          TextSelection(baseOffset: start, extentOffset: start + word.length),
        )
        .map((box) => box.top)
        .toSet();
    final firstTop = paragraph
        .getBoxesForSelection(
          const TextSelection(baseOffset: 0, extentOffset: 3),
        )
        .first
        .top;
    expect(wordTops, hasLength(1), reason: 'the word stays whole');
    expect(wordTops.single, greaterThan(firstTop), reason: 'on its own line');
  });

  testWidgets('CA-02: the search is a pill-shaped field with the magnifier', (
    tester,
  ) async {
    await _openHub(tester);

    final field = tester.widget<TextField>(_inHub(find.byType(TextField)));
    final border = field.decoration!.border;
    expect(border, isA<OutlineInputBorder>());
    expect(
      (border! as OutlineInputBorder).borderRadius,
      BorderRadius.circular(9999),
    );
    expect(
      find.descendant(
        of: _inHub(find.byType(TextField)),
        matching: find.byIcon(Icons.search_outlined),
      ),
      findsOneWidget,
    );
  });

  testWidgets('CA-03: the hours of each card sit in a pill with the clock', (
    tester,
  ) async {
    await _openHub(tester);

    final hours = find.text('20 h').first;
    final pill = find.ancestor(
      of: hours,
      matching: find.byKey(const ValueKey('hub-hours-pill')),
    );
    expect(pill, findsOneWidget);
    expect(
      find.descendant(of: pill, matching: find.byIcon(Icons.schedule_outlined)),
      findsOneWidget,
    );
  });
}
