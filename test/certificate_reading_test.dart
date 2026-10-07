import 'package:flutter_test/flutter_test.dart';

import 'package:uni_cronos/features/hours/domain/hours.dart';
import 'package:uni_cronos/features/upload/domain/certificate_reading.dart';

void main() {
  group('CA-02: hours', () {
    for (final (text, hours) in [
      ('carga horária de 20 horas', 20),
      ('Carga Horaria: 10h00', 10),
      ('com duração de 8h', 8),
      ('40 (quarenta) horas', 40),
      ('totalizando 12 hrs de atividades', 12),
      ('com 10h30 de duração', 10),
      ('Carga Horária Total: 260 horas.', 260),
    ]) {
      test('"$text" is $hours h', () => expect(findHours(text), hours));
    }

    test('the workload wins over clock times', () {
      expect(findHours('das 8h às 12h, com carga horária total de 4 horas'), 4);
    });

    test('clock times alone are no workload', () {
      expect(findHours('evento das 8h às 12h no auditório'), isNull);
      expect(findHours('início às 14h'), isNull);
    });

    for (final text in [
      'realizado em 12/03/2026',
      '1200 horas',
      'carga horária de 0 horas',
      '',
    ]) {
      test('"$text" has no hours (outside 1 to 999)', () {
        expect(findHours(text), isNull);
      });
    }
  });

  group('CA-02: category', () {
    for (final (text, category) in [
      (
        'participou do projeto de Extensão Horta Comunitária',
        HourCategory.extension,
      ),
      ('ação extensionista na comunidade', HourCategory.extension),
      ('PROJETO DE EXTENSAO', HourCategory.extension),
      ('participou da Semana Acadêmica', HourCategory.complementary),
    ]) {
      test('"$text" is ${category.name}', () {
        expect(classifyHours(text), category);
      });
    }
  });

  group('CA-02: title', () {
    test('the quoted name after "evento"', () {
      expect(
        findTitle(
          'Certificamos que Ana Souza participou do evento "Semana Acadêmica '
          'de Computação", com carga horária de 20 horas.',
          fileName: 'x.pdf',
        ),
        'Semana Acadêmica de Computação',
      );
    });

    test('curly quotes and line breaks', () {
      expect(
        findTitle(
          'concluiu o curso\n“Introdução ao\nPython”, realizado online',
          fileName: 'x.pdf',
        ),
        'Introdução ao Python',
      );
    });

    test('without quotes, up to the comma', () {
      expect(
        findTitle(
          'participou do Workshop de Robótica, realizado em março',
          fileName: 'x.pdf',
        ),
        'Workshop de Robótica',
      );
    });

    test('without a marker, the file name', () {
      expect(
        findTitle(
          'Certificado de participação. Carga horária: 10 horas.',
          fileName: 'certificado-game-jam.pdf',
        ),
        'Certificado Game Jam',
      );
    });

    test('at most 120 characters', () {
      expect(
        findTitle('participou do ${'a' * 300}', fileName: 'x.pdf').length,
        lessThanOrEqualTo(120),
      );
    });
  });

  group('CA-02: issuer', () {
    test('the institution when the text names it', () {
      expect(
        findIssuer('Universidade Tecnológica (UTFPR)', institution: 'UTFPR'),
        'UTFPR',
      );
      expect(findIssuer('emitido pela utfpr', institution: 'UTFPR'), 'UTFPR');
      expect(findIssuer('emitido pela UFPR', institution: 'UTFPR'), isNull);
    });
  });

  test('CA-03: an extension declaration of 260 hours reads in full', () {
    final reading = readCertificate(
      'participou ativamente das atividades vinculadas ao projeto de '
      'extensão universitária da UTFPR.\nCarga Horária Total: 260 horas.',
      fileName: 'declaracao-equipe.pdf',
      institution: 'UTFPR',
    );

    expect(
      (reading.hours, reading.category, reading.title, reading.issuer),
      (260, HourCategory.extension, 'Declaracao Equipe', 'UTFPR'),
    );
  });
}
