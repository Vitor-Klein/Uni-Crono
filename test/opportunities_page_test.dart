import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:uni_cronos/features/opportunities/domain/opportunity.dart';

import 'app_harness.dart';

Future<void> _openHub(
  WidgetTester tester, {
  FakeOpportunityRepository? opportunities,
  FakeLinkOpener? links,
}) async {
  tester.view.physicalSize = const Size(800, 4000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await pumpRoutedApp(tester, opportunities: opportunities, links: links);
  await tester.tap(navLabel('Atividades'));
  await tester.pumpAndSettle();
}

Finder _chip(String label) => find.widgetWithText(ChoiceChip, label);

Future<void> _search(WidgetTester tester, String text) async {
  await tester.enterText(
    find.descendant(
      of: find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.label == 'Buscar oportunidades',
      ),
      matching: find.byType(EditableText),
    ),
    text,
  );
  await tester.pumpAndSettle();
}

Set<String> _visibleTitles(WidgetTester tester) => {
  for (final o in demoOpportunities())
    if (find.text(o.title).evaluate().isNotEmpty) o.title,
};

void main() {
  group('rules', () {
    test('CA-03: the search ignores case and accents', () {
      final found = visibleOpportunities(
        demoOpportunities(),
        filter: OpportunityFilter.all,
        query: 'EXTENSAO',
      );
      // The horta has "Extensão" in its title; the robótica, in who offers it.
      expect(found.map((o) => o.id), ['horta', 'robotica']);
    });

    test('CA-01: the featured one comes first, then by start date', () {
      final ordered = visibleOpportunities(
        demoOpportunities(),
        filter: OpportunityFilter.all,
        query: '',
      );
      expect(ordered.map((o) => o.id), [
        'semana',
        'python',
        'horta',
        'mentoria',
        'robotica',
        'maratona',
      ]);
    });
  });

  testWidgets('CA-01: the hub lists the 6 opportunities, the featured '
      'Semana Acadêmica de Computação first', (tester) async {
    await _openHub(tester);

    expect(find.text('Hub de Oportunidades'), findsOneWidget);
    expect(_visibleTitles(tester), hasLength(6));
    final featuredTop = tester
        .getTopLeft(find.text('Semana Acadêmica de Computação'))
        .dy;
    for (final o in demoOpportunities().where((o) => !o.featured)) {
      expect(
        tester.getTopLeft(find.text(o.title)).dy,
        greaterThan(featuredTop),
        reason: o.title,
      );
    }
    expect(find.text('20 h'), findsWidgets);
  });

  testWidgets('CA-02: Cursos leaves only the courses; Extensão only the '
      'extension ones', (tester) async {
    await _openHub(tester);

    await tester.tap(_chip('Cursos'));
    await tester.pumpAndSettle();
    expect(_visibleTitles(tester), {
      'Introdução ao Python para Dados',
      'Oficina de Robótica nas Escolas',
      'Mentoria de Tecnologia Comunitária',
    });

    await tester.tap(_chip('Extensão'));
    await tester.pumpAndSettle();
    expect(_visibleTitles(tester), {
      'Projeto de Extensão Horta Comunitária',
      'Oficina de Robótica nas Escolas',
      'Mentoria de Tecnologia Comunitária',
    });
  });

  testWidgets('CA-03: searching python leaves only Introdução ao Python para '
      'Dados; zzz shows Nenhuma oportunidade encontrada', (tester) async {
    await _openHub(tester);

    await _search(tester, 'python');
    expect(_visibleTitles(tester), {'Introdução ao Python para Dados'});

    await _search(tester, 'zzz');
    expect(_visibleTitles(tester), isEmpty);
    expect(find.text('Nenhuma oportunidade encontrada'), findsOneWidget);
  });

  testWidgets('CA-03: filter and search apply together', (tester) async {
    await _openHub(tester);

    await tester.tap(_chip('Eventos'));
    await tester.pumpAndSettle();
    await _search(tester, 'python');

    expect(find.text('Nenhuma oportunidade encontrada'), findsOneWidget);
  });

  testWidgets('CA-04: Inscrever-se opens the https link of the opportunity; '
      'one without a link has no button', (tester) async {
    final links = FakeLinkOpener();
    await _openHub(tester, links: links);

    expect(find.widgetWithText(FilledButton, 'Inscrever-se'), findsOneWidget);
    expect(
      find.widgetWithText(OutlinedButton, 'Inscrever-se'),
      findsNWidgets(4),
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Inscrever-se'));
    await tester.pumpAndSettle();
    expect(links.opened, [Uri.parse('https://example.com/semana-academica')]);

    final horta = find.ancestor(
      of: find.text('Projeto de Extensão Horta Comunitária'),
      matching: find.byType(Card),
    );
    expect(
      find.descendant(of: horta, matching: find.text('Inscrever-se')),
      findsNothing,
    );
  });

  testWidgets('CA-05: a failed load shows the error, and Tentar de novo loads '
      'again', (tester) async {
    final opportunities = FakeOpportunityRepository()..fail = true;
    await _openHub(tester, opportunities: opportunities);

    expect(
      find.text('Não foi possível carregar as oportunidades'),
      findsOneWidget,
    );

    opportunities.fail = false;
    await tester.tap(find.text('Tentar de novo'));
    await tester.pumpAndSettle();

    expect(_visibleTitles(tester), hasLength(6));
  });

  for (final (width, scale) in [(320.0, 1.0), (360.0, 1.5)]) {
    testWidgets('CA-01: the hub fits a ${width.toInt()}dp screen at '
        '${scale}x text without overflowing', (tester) async {
      tester.view.physicalSize = Size(width, 4000);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await pumpRoutedApp(tester);
      await tester.tap(navLabel('Atividades'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  }
}
