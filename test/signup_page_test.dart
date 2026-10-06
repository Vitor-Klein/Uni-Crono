import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:uni_cronos/core/navigation/app_routes.dart';

import 'app_harness.dart';

Finder _field(String label) => find.descendant(
  of: find.byWidgetPredicate(
    (w) => w is Semantics && w.properties.label == label,
  ),
  matching: find.byType(EditableText),
);

Future<void> _openSignUp(WidgetTester tester, {FakeAuthGateway? auth}) async {
  await pumpRoutedApp(tester, auth: auth ?? FakeAuthGateway());
  await tester.ensureVisible(find.text('Criar conta'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Criar conta'));
  await tester.pumpAndSettle();
}

Future<void> _submit(WidgetTester tester) async {
  final button = find.widgetWithText(FilledButton, 'Criar conta');
  await tester.ensureVisible(button);
  await tester.pumpAndSettle();
  await tester.tap(button);
  await tester.pumpAndSettle();
}

Future<void> _fillIn(
  WidgetTester tester, {
  String email = 'bia.lima@alunos.utfpr.edu.br',
  String term = '3',
  String password = 'senha-forte',
}) async {
  await tester.enterText(_field('Nome completo'), 'Bia Lima');
  await tester.tap(find.byType(DropdownButtonFormField<String>));
  await tester.pumpAndSettle();
  await tester.tap(find.text('UTFPR').last);
  await tester.pumpAndSettle();
  await tester.enterText(_field('Curso'), 'Ciência da Computação');
  await tester.enterText(_field('Período'), term);
  await tester.enterText(_field('E-mail acadêmico'), email);
  await tester.enterText(_field('Senha'), password);
}

void main() {
  testWidgets('CA-10: Criar conta on the login opens /signup, and Entrar '
      'goes back to /login', (tester) async {
    await _openSignUp(tester);

    expect(currentPath(), AppRoutes.signup);
    expect(find.byType(NavigationBar), findsNothing);

    final back = find.widgetWithText(TextButton, 'Entrar');
    await tester.ensureVisible(back);
    await tester.pumpAndSettle();
    await tester.tap(back);
    await tester.pumpAndSettle();

    expect(currentPath(), AppRoutes.login);
  });

  testWidgets('CA-04: Criar conta with everything empty shows the error of '
      'each field', (tester) async {
    await _openSignUp(tester);

    await _submit(tester);

    for (final error in [
      'Informe seu nome',
      'Escolha sua instituição',
      'Informe seu curso',
      'Informe um período de 1 a 12',
      'Informe seu e-mail acadêmico',
      'Informe sua senha',
    ]) {
      expect(find.text(error), findsOneWidget, reason: error);
    }
    expect(currentPath(), AppRoutes.signup);
  });

  testWidgets('CA-04: a 7-character password says Use 8 caracteres ou '
      'mais', (tester) async {
    await _openSignUp(tester);
    await _fillIn(tester, password: '1234567');

    await _submit(tester);

    expect(find.text('Use 8 caracteres ou mais'), findsOneWidget);
    expect(currentPath(), AppRoutes.signup);
  });

  for (final term in ['0', '13', 'x']) {
    testWidgets('CA-04: term "$term" says Informe um período de 1 a 12', (
      tester,
    ) async {
      final auth = FakeAuthGateway();
      await _openSignUp(tester, auth: auth);
      await _fillIn(tester, term: term);

      await _submit(tester);

      expect(find.text('Informe um período de 1 a 12'), findsOneWidget);
      expect(auth.signUps, isEmpty);
    });
  }

  testWidgets('CA-05: valid data create the account with the profile and '
      'open /dashboard', (tester) async {
    final auth = FakeAuthGateway();
    await _openSignUp(tester, auth: auth);
    await _fillIn(tester);

    await _submit(tester);

    expect(currentPath(), AppRoutes.dashboard);
    final data = auth.signUps.single;
    expect(
      (data.fullName, data.institutionId, data.course, data.term, data.email),
      (
        'Bia Lima',
        'utfpr',
        'Ciência da Computação',
        3,
        'bia.lima@alunos.utfpr.edu.br',
      ),
    );
    expect(data.password, 'senha-forte');
  });

  testWidgets('CA-06: an e-mail that already has an account says Este e-mail '
      'já tem conta', (tester) async {
    await _openSignUp(tester);
    await _fillIn(tester, email: demoSession.email);

    await _submit(tester);

    expect(find.text('Este e-mail já tem conta'), findsOneWidget);
    expect(currentPath(), AppRoutes.signup);
  });

  testWidgets('CA-05: without network, Criar conta says Sem conexão. Tente de '
      'novo.', (tester) async {
    await _openSignUp(tester, auth: FakeAuthGateway()..offline = true);
    await _fillIn(tester);

    await _submit(tester);

    expect(find.text('Sem conexão. Tente de novo.'), findsOneWidget);
  });

  for (final (width, scale) in [(320.0, 1.0), (360.0, 1.5)]) {
    testWidgets('CA-04: the sign-up form fits a ${width.toInt()}dp screen at '
        '${scale}x text without overflowing', (tester) async {
      tester.view.physicalSize = Size(width, 760);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await _openSignUp(tester);
      await _submit(tester);

      expect(find.text('Informe sua senha'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
