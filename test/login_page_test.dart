import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  Future<void> fillIn(
    WidgetTester tester, {
    String email = 'ana.souza@alunos.utfpr.edu.br',
  }) async {
    await tester.tap(find.text('Selecione sua universidade…'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('UTFPR').last);
    await tester.pumpAndSettle();
    await tester.enterText(emailField(), email);
    await tester.enterText(
      find.byWidgetPredicate((w) => w is EditableText && w.obscureText),
      'x',
    );
  }

  testWidgets('CA-04: valid institution, e-mail and password sign in, save '
      'the session and open /dashboard', (tester) async {
    await pumpRoutedApp(tester, signedIn: false);
    await fillIn(tester);

    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(currentPath(), AppRoutes.dashboard);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('session_email'), 'ana.souza@alunos.utfpr.edu.br');
    expect(prefs.getString('session_institution'), 'utfpr');
  });

  testWidgets('CA-04: the password is saved nowhere', (tester) async {
    await pumpRoutedApp(tester, signedIn: false);
    await fillIn(tester);

    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    for (final key in prefs.getKeys()) {
      expect(key.toLowerCase(), isNot(contains('password')), reason: key);
      expect(prefs.get(key), isNot('x'), reason: key);
    }
  });

  testWidgets('CA-04: spaces around the e-mail are dropped', (tester) async {
    await pumpRoutedApp(tester, signedIn: false);
    await fillIn(tester, email: '  ana.souza@alunos.utfpr.edu.br  ');

    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('session_email'), 'ana.souza@alunos.utfpr.edu.br');
  });

  testWidgets('CA-04: pressing done on the keyboard after the password signs '
      'in', (tester) async {
    await pumpRoutedApp(tester, signedIn: false);
    await fillIn(tester);

    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(currentPath(), AppRoutes.dashboard);
  });
}
