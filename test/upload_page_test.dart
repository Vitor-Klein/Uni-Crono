import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:uni_cronos/core/navigation/app_routes.dart';
import 'package:uni_cronos/features/hours/domain/hours.dart';
import 'package:uni_cronos/features/upload/data/certificate_launcher.dart';
import 'package:uni_cronos/features/upload/domain/certificate_file_rules.dart';

import 'app_harness.dart';

final _pending = UnreadableCertificate(
  file: pickedFile('certificado-game-jam.pdf', 180 * 1024),
  title: 'Certificado Game Jam',
);

Finder _field(String label) => find.descendant(
  of: find.byWidgetPredicate(
    (w) => w is Semantics && w.properties.label == label,
  ),
  matching: find.byType(EditableText),
);

Finder get _send => find.widgetWithText(FilledButton, 'Enviar certificado');

bool _enabled(WidgetTester tester, Finder button) =>
    tester.widget<ButtonStyleButton>(button).onPressed != null;

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _openUpload(
  WidgetTester tester, {
  FakeCertificatePicker? picker,
  FakeCertificateLauncher? launcher,
  FakeHoursRepository? hours,
}) async {
  await pumpRoutedApp(
    tester,
    picker: picker,
    launcher: launcher,
    hoursRepository: hours,
  );
  await tester.tap(navLabel('Enviar'));
  await tester.pumpAndSettle();
}

Future<void> _choose(WidgetTester tester) =>
    _tap(tester, find.widgetWithText(OutlinedButton, 'Procurar arquivos'));

void main() {
  group('rules', () {
    test('CA-04: the title from the file name', () {
      expect(
        titleFromFileName('certificado-game-jam.pdf'),
        'Certificado Game Jam',
      );
      expect(titleFromFileName('semana_academica.PDF'), 'Semana Academica');
    });

    test('CA-02: only a PDF of at most 10 MB is accepted', () {
      expect(isAcceptedCertificate(pickedFile('a.pdf', 180 * 1024)), isTrue);
      expect(
        isAcceptedCertificate(pickedFile('a.PDF', 10 * 1024 * 1024)),
        isTrue,
      );
      expect(
        isAcceptedCertificate(pickedFile('a.pdf', 10 * 1024 * 1024 + 1)),
        isFalse,
      );
      expect(isAcceptedCertificate(pickedFile('a.docx', 1024)), isFalse);
      expect(isAcceptedCertificate(pickedFile('a.png', 1024)), isFalse);
      expect(
        isAcceptedCertificate(pickedFile('a.pdf', 1024, pdf: false)),
        isFalse,
      );
    });
  });

  testWidgets('CA-01: choosing certificado-game-jam.pdf of 180 KB shows its '
      'name and size and enables Enviar certificado', (tester) async {
    final picker = FakeCertificatePicker(
      pickedFile('certificado-game-jam.pdf', 180 * 1024),
    );
    await _openUpload(tester, picker: picker);
    expect(find.text('Lançar certificado'), findsOneWidget);
    expect(_enabled(tester, _send), isFalse);

    await _choose(tester);

    expect(find.text('certificado-game-jam.pdf'), findsOneWidget);
    expect(find.text('180 KB'), findsOneWidget);
    expect(_enabled(tester, _send), isTrue);
  });

  for (final (name, size, pdf) in [
    ('certificado.docx', 1024, true),
    ('certificado.png', 1024, true),
    ('certificado.pdf', 11 * 1024 * 1024, true),
    ('certificado.pdf', 1024, false),
  ]) {
    testWidgets('CA-02: $name of $size bytes (pdf bytes: $pdf) says Use um '
        'PDF de até 10 MB and keeps Enviar certificado off', (tester) async {
      final launcher = FakeCertificateLauncher();
      await _openUpload(
        tester,
        picker: FakeCertificatePicker(pickedFile(name, size, pdf: pdf)),
        launcher: launcher,
      );

      await _choose(tester);

      expect(find.text('Use um PDF de até 10 MB'), findsOneWidget);
      expect(_enabled(tester, _send), isFalse);
      expect(launcher.launched, isEmpty);
    });
  }

  testWidgets('CA-03: sending says Lendo certificado…, then opens /dashboard '
      'with the hours launched and the Upload tab empty', (tester) async {
    final launcher = FakeCertificateLauncher()..gate = Completer<void>();
    final hours = FakeHoursRepository(demoCertificates());
    await _openUpload(
      tester,
      picker: FakeCertificatePicker(
        pickedFile('certificado-game-jam.pdf', 180 * 1024),
      ),
      launcher: launcher,
      hours: hours,
    );
    await _choose(tester);
    final refreshesBefore = hours.refreshes;

    await tester.tap(_send);
    await tester.pump();

    expect(find.text('Lendo certificado…'), findsOneWidget);
    expect(
      _enabled(tester, find.widgetWithText(TextButton, 'Cancelar')),
      isFalse,
    );

    launcher.gate!.complete();
    await tester.pumpAndSettle();

    expect(currentPath(), AppRoutes.dashboard);
    expect(
      find.text('Certificado lançado: +10 h em Horas Complementares'),
      findsOneWidget,
    );
    expect(hours.refreshes, refreshesBefore + 1);

    await tester.tap(navLabel('Enviar'));
    await tester.pumpAndSettle();
    expect(currentPath(), AppRoutes.upload);
    expect(find.text('certificado-game-jam.pdf'), findsNothing);
    expect(_enabled(tester, _send), isFalse);
  });

  Future<FakeCertificateLauncher> openManual(WidgetTester tester) async {
    final launcher = FakeCertificateLauncher()..failure = Unreadable(_pending);
    await _openUpload(
      tester,
      picker: FakeCertificatePicker(
        pickedFile('certificado-game-jam.pdf', 180 * 1024),
      ),
      launcher: launcher,
    );
    await _choose(tester);
    await _tap(tester, _send);
    return launcher;
  }

  testWidgets('CA-04: when the reader finds no hours, /upload/manual asks for '
      'the data, with the title of the file name', (tester) async {
    await openManual(tester);

    expect(currentPath(), '${AppRoutes.upload}/manual');
    expect(
      find.text(
        'Não encontramos as horas neste certificado. Informe os dados.',
      ),
      findsOneWidget,
    );
    expect(find.text('Certificado Game Jam'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  for (final hours in ['', '0', '1000']) {
    testWidgets('CA-04a: hours "$hours" say Informe as horas (1 a 999)', (
      tester,
    ) async {
      final launcher = await openManual(tester);
      await tester.enterText(_field('Carga horária (h)'), hours);

      await _tap(tester, find.widgetWithText(FilledButton, 'Lançar'));

      expect(find.text('Informe as horas (1 a 999)'), findsOneWidget);
      expect(launcher.manual, isEmpty);
    });
  }

  testWidgets('CA-04b: 12 h of Horas de Extensão launch and open /dashboard; '
      'the Upload tab is back at /upload', (tester) async {
    final launcher = await openManual(tester);
    await tester.enterText(_field('Carga horária (h)'), '12');
    await _tap(tester, find.byType(DropdownButtonFormField<HourCategory>));
    await tester.tap(find.text('Horas de Extensão').last);
    await tester.pumpAndSettle();

    await _tap(tester, find.widgetWithText(FilledButton, 'Lançar'));

    expect(currentPath(), AppRoutes.dashboard);
    expect(
      find.text('Certificado lançado: +12 h em Horas de Extensão'),
      findsOneWidget,
    );
    expect(launcher.manual.single, (
      'certificado-game-jam.pdf',
      'Certificado Game Jam',
      HourCategory.extension,
      12,
    ));

    await tester.tap(navLabel('Enviar'));
    await tester.pumpAndSettle();
    expect(currentPath(), AppRoutes.upload);
  });

  testWidgets('CA-04c: Cancelar on the form goes back to /upload with the file '
      'still chosen and nothing launched', (tester) async {
    final launcher = await openManual(tester);

    await _tap(tester, find.widgetWithText(TextButton, 'Cancelar'));

    expect(launcher.manual, isEmpty);
    expect(currentPath(), AppRoutes.upload);
    expect(find.text('certificado-game-jam.pdf'), findsOneWidget);
  });

  for (final (failure, message) in [
    (const Duplicate(), 'Este certificado já foi lançado'),
    (
      const ReaderUnavailable(),
      'Não foi possível ler o certificado. Tente de novo.',
    ),
  ]) {
    testWidgets('CA-05/06: ${failure.runtimeType} says "$message" and keeps '
        'the file', (tester) async {
      await _openUpload(
        tester,
        picker: FakeCertificatePicker(
          pickedFile('certificado-game-jam.pdf', 180 * 1024),
        ),
        launcher: FakeCertificateLauncher()..failure = failure,
      );
      await _choose(tester);

      await _tap(tester, _send);

      expect(find.text(message), findsOneWidget);
      expect(currentPath(), AppRoutes.upload);
      expect(find.text('certificado-game-jam.pdf'), findsOneWidget);
    });
  }

  testWidgets('CA-07: Cancelar on /upload clears the file', (tester) async {
    await _openUpload(
      tester,
      picker: FakeCertificatePicker(
        pickedFile('certificado-game-jam.pdf', 180 * 1024),
      ),
    );
    await _choose(tester);

    await _tap(tester, find.widgetWithText(TextButton, 'Cancelar'));

    expect(find.text('certificado-game-jam.pdf'), findsNothing);
    expect(_enabled(tester, _send), isFalse);
  });

  for (final (width, scale) in [(320.0, 1.0), (360.0, 1.5)]) {
    testWidgets(
      'CA-01: the upload screen and the form fit a ${width.toInt()}dp '
      'screen at ${scale}x text without overflowing',
      (tester) async {
        tester.view.physicalSize = Size(width, 760);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

        await openManual(tester);
        expect(tester.takeException(), isNull);
        await _tap(tester, find.widgetWithText(TextButton, 'Cancelar'));
        expect(tester.takeException(), isNull);
      },
    );
  }
}
