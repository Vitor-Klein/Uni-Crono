import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_harness.dart';

void main() {
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
}
