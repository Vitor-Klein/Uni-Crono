import 'package:flutter/material.dart';
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
  testWidgets('CA-01: the title stands alone, with no icon badge, in the '
      'headline size', (tester) async {
    await _openHub(tester);

    final title = find.text('Hub de Oportunidades');
    expect(_inHub(find.byIcon(Icons.explore_outlined)), findsNothing);
    final theme = Theme.of(tester.element(title));
    expect(
      tester.widget<Text>(title).style?.fontSize,
      theme.textTheme.headlineSmall!.fontSize,
    );
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
