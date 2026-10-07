import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:uni_cronos/core/navigation/app_routes.dart';
import 'package:uni_cronos/features/hours/domain/hours.dart';
import 'package:uni_cronos/features/profile/domain/student_profile.dart';

import 'app_harness.dart';

Future<void> _openProfile(
  WidgetTester tester, {
  FakeAuthGateway? auth,
  FakeHoursRepository? hours,
  FakeProfileRepository? profile,
}) async {
  tester.view.physicalSize = const Size(800, 2000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await pumpRoutedApp(
    tester,
    auth: auth,
    hoursRepository: hours,
    profile: profile,
  );
  await tester.tap(navLabel('Perfil'));
  await tester.pumpAndSettle();
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  test('CA-06: the initials are the first letters of the first and the last '
      'name', () {
    expect(demoProfile.initials, 'AS');
    const single = StudentProfile(
      fullName: '  maria  ',
      email: 'm@b.co',
      institutionId: 'utfpr',
      course: 'x',
      term: 1,
    );
    expect(single.initials, 'M');
  });

  testWidgets('CA-06: the profile shows the student card and the summary of '
      'the hours', (tester) async {
    await _openProfile(tester);

    expect(find.text('Ana Souza'), findsOneWidget);
    expect(find.text('ana.souza@alunos.utfpr.edu.br'), findsOneWidget);
    expect(
      find.text('UTFPR · Engenharia de Software · 5º período'),
      findsOneWidget,
    );
    expect(find.text('175 h'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(find.text('58%'), findsOneWidget);
  });

  testWidgets('CA-06: the profile card shows the initials of the '
      'profile', (tester) async {
    await _openProfile(
      tester,
      profile: FakeProfileRepository(
        const StudentProfile(
          fullName: 'Bia de Lima',
          email: 'bia@b.co',
          institutionId: 'utfpr',
          course: 'Engenharia de Software',
          term: 5,
        ),
      ),
    );

    expect(find.text('BL'), findsWidgets);
  });

  testWidgets('CA-07: a new certificate of 10 h adds to the summary without '
      'reloading the screen', (tester) async {
    final hours = FakeHoursRepository(demoCertificates());
    await _openProfile(tester, hours: hours);

    await hours.add(
      ApprovedCertificate(
        id: 'new',
        title: 'Certificado Game Jam',
        category: HourCategory.complementary,
        hours: 10,
        approvedAt: DateTime(2026, 10, 6),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('185 h'), findsOneWidget);
    expect(find.text('6'), findsOneWidget);
  });

  testWidgets('CA-08: Idioma opens the language sheet and English switches '
      'the app', (tester) async {
    await _openProfile(tester);

    await _tap(tester, find.text('Idioma'));
    await _tap(tester, find.text('English'));

    expect(navLabel('Profile'), findsOneWidget);
  });

  testWidgets('CA-08: Acessibilidade opens the sheet with Tema', (
    tester,
  ) async {
    await _openProfile(tester);

    await _tap(tester, find.text('Acessibilidade'));

    expect(find.text('Tema'), findsOneWidget);
  });

  testWidgets('CA-08: Notificações opens the notifications sheet', (
    tester,
  ) async {
    await _openProfile(tester);

    await _tap(tester, find.text('Notificações'));

    expect(find.text('NOTIFICAÇÕES'), findsOneWidget);
  });

  testWidgets('CA-09: Sair, then Sair on the dialog, signs out and goes to '
      '/login', (tester) async {
    final auth = FakeAuthGateway(signedIn: demoSession);
    await _openProfile(tester, auth: auth);

    await _tap(tester, find.widgetWithText(ListTile, 'Sair'));
    expect(find.text('Sair da conta?'), findsOneWidget);
    await _tap(
      tester,
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(TextButton, 'Sair'),
      ),
    );

    expect(currentPath(), AppRoutes.login);
    expect(auth.current, isNull);
  });

  testWidgets('CA-09: Cancelar on the dialog stays on the profile', (
    tester,
  ) async {
    final auth = FakeAuthGateway(signedIn: demoSession);
    await _openProfile(tester, auth: auth);

    await _tap(tester, find.widgetWithText(ListTile, 'Sair'));
    await _tap(tester, find.text('Cancelar'));

    expect(currentPath(), AppRoutes.profile);
    expect(auth.current, demoSession);
  });

  testWidgets('CA-06: a failed profile load says so, and Tentar de novo loads '
      'again', (tester) async {
    final profile = FakeProfileRepository()..fail = true;
    await _openProfile(tester, profile: profile);

    expect(find.text('Não foi possível carregar seu perfil'), findsOneWidget);

    profile.fail = false;
    await _tap(tester, find.text('Tentar de novo'));

    expect(find.text('Ana Souza'), findsOneWidget);
  });

  for (final (width, scale) in [(320.0, 1.0), (360.0, 1.5)]) {
    testWidgets('CA-06: the profile fits a ${width.toInt()}dp screen at '
        '${scale}x text without overflowing', (tester) async {
      tester.view.physicalSize = Size(width, 2000);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await pumpRoutedApp(tester);
      await tester.tap(navLabel('Perfil'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  }
}
