import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:uni_cronos/core/navigation/app_routes.dart';
import 'package:uni_cronos/features/auth/presentation/login_page.dart';
import 'package:uni_cronos/features/auth/presentation/session_cubit.dart';

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
    String institution = 'UTFPR',
    String email = 'ana.souza@alunos.utfpr.edu.br',
    String password = demoPassword,
  }) async {
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text(institution).last);
    await tester.pumpAndSettle();
    await tester.enterText(emailField(), email);
    await tester.enterText(
      find.byWidgetPredicate((w) => w is EditableText && w.obscureText),
      password,
    );
  }

  SessionCubit sessionOf(WidgetTester tester) =>
      tester.element(find.byType(LoginPage)).read<SessionCubit>();

  testWidgets('CA-01: UTFPR, the e-mail and the right password open '
      '/dashboard with the session of the account', (tester) async {
    await pumpRoutedApp(tester, signedIn: false);
    final session = sessionOf(tester);
    await fillIn(tester);

    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(currentPath(), AppRoutes.dashboard);
    expect(session.state, demoSession);
  });

  testWidgets('CA-02: a wrong password says E-mail ou senha incorretos and '
      'stays on /login', (tester) async {
    await pumpRoutedApp(tester, signedIn: false);
    await fillIn(tester, password: 'errada');

    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(find.text('E-mail ou senha incorretos'), findsOneWidget);
    expect(currentPath(), AppRoutes.login);
  });

  testWidgets('CA-02: the password is saved nowhere', (tester) async {
    await pumpRoutedApp(tester, signedIn: false);
    await fillIn(tester);

    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    for (final key in prefs.getKeys()) {
      expect(key.toLowerCase(), isNot(contains('password')), reason: key);
      expect(prefs.get(key), isNot(demoPassword), reason: key);
    }
  });

  testWidgets('CA-03: without network, signing in says Sem conexão. Tente de '
      'novo.', (tester) async {
    await pumpRoutedApp(tester, auth: FakeAuthGateway()..offline = true);
    await fillIn(tester);

    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(find.text('Sem conexão. Tente de novo.'), findsOneWidget);
    expect(currentPath(), AppRoutes.login);
  });

  testWidgets('CA-01: an account of another institution does not sign in and '
      'says so', (tester) async {
    await pumpRoutedApp(tester, signedIn: false);
    final session = sessionOf(tester);
    await fillIn(tester, institution: 'UFPR');

    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(find.text('Esta conta é de outra instituição'), findsOneWidget);
    expect(currentPath(), AppRoutes.login);
    expect(session.state, isNull);
  });

  testWidgets('CA-01: spaces around the e-mail are dropped', (tester) async {
    await pumpRoutedApp(tester, signedIn: false);
    await fillIn(tester, email: '  ana.souza@alunos.utfpr.edu.br  ');

    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(currentPath(), AppRoutes.dashboard);
  });

  testWidgets('CA-01: pressing done on the keyboard after the password signs '
      'in', (tester) async {
    await pumpRoutedApp(tester, signedIn: false);
    await fillIn(tester);

    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(currentPath(), AppRoutes.dashboard);
  });

  testWidgets('CA-08: Esqueci? says Disponível em breve', (tester) async {
    await pumpRoutedApp(tester, signedIn: false);

    await tester.ensureVisible(find.text('Esqueci?'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Esqueci?'));
    await tester.pump();

    expect(find.text('Disponível em breve'), findsOneWidget);
  });

  for (final (width, scale) in [(320.0, 1.0), (360.0, 1.5)]) {
    testWidgets('CA-02: the login form fits a ${width.toInt()}dp screen at '
        '${scale}x text without overflowing', (tester) async {
      tester.view.physicalSize = Size(width, 760);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await pumpRoutedApp(tester, signedIn: false);
      await tester.ensureVisible(find.text('Entrar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(find.text('Informe sua senha'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('CA-02: a corrected field clears its error', (tester) async {
    await pumpRoutedApp(tester, signedIn: false);
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();
    expect(find.text('Informe seu e-mail acadêmico'), findsOneWidget);

    await tester.enterText(
      find.byWidgetPredicate((w) => w is EditableText && !w.obscureText),
      'ana.souza@alunos.utfpr.edu.br',
    );
    await tester.pumpAndSettle();

    expect(find.text('Informe seu e-mail acadêmico'), findsNothing);
  });
}
