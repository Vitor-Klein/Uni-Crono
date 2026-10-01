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
}
