import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:uni_cronos/core/navigation/app_routes.dart';

import 'app_harness.dart';

Finder emailField() =>
    find.widgetWithText(TextFormField, 'aluno@universidade.edu.br');

void main() {
  testWidgets('CA-02: signing in with everything empty shows the three '
      'field errors and stays on /login', (tester) async {
    await pumpRoutedApp(tester, signedIn: false);

    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(find.text('Escolha sua instituição'), findsOneWidget);
    expect(find.text('Informe seu e-mail acadêmico'), findsOneWidget);
    expect(find.text('Informe sua senha'), findsOneWidget);
    expect(currentPath(), AppRoutes.login);
  });

  testWidgets('CA-03: an e-mail without a valid format shows E-mail '
      'inválido', (tester) async {
    await pumpRoutedApp(tester, signedIn: false);

    await tester.enterText(emailField(), 'ana@');
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(find.text('E-mail inválido'), findsOneWidget);
  });

  testWidgets('CA-02: screen readers announce each field with its label', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pumpRoutedApp(tester, signedIn: false);

    final fields = <String, Finder>{
      'Instituição': find.byType(DropdownButtonFormField<String>),
      'E-mail acadêmico': find.byWidgetPredicate(
        (w) => w is EditableText && !w.obscureText,
      ),
      'Senha': find.byWidgetPredicate(
        (w) => w is EditableText && w.obscureText,
      ),
    };
    for (final MapEntry(key: label, value: field) in fields.entries) {
      expect(tester.getSemantics(field).label, contains(label), reason: label);
    }
    semantics.dispose();
  });
}
