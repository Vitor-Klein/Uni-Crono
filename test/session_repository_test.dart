import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:uni_cronos/features/auth/data/session_repository.dart';
import 'package:uni_cronos/features/auth/domain/institution.dart';
import 'package:uni_cronos/features/auth/domain/session.dart';

void main() {
  const repository = SharedPrefsSessionRepository();
  const session = Session(
    email: 'ana.souza@alunos.utfpr.edu.br',
    institutionId: 'utfpr',
  );

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('CA-04: a saved session is stored under the session keys and loads '
      'back', () async {
    await repository.save(session);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('session_email'), session.email);
    expect(prefs.getString('session_institution'), 'utfpr');
    expect(await repository.load(), session);
  });

  test('CA-05: with nothing saved there is no session', () async {
    expect(await repository.load(), isNull);
  });

  test('CA-05: a half-saved session counts as no session', () async {
    SharedPreferences.setMockInitialValues({'session_email': session.email});
    expect(await repository.load(), isNull);

    SharedPreferences.setMockInitialValues({'session_institution': 'utfpr'});
    expect(await repository.load(), isNull);
  });

  test('CA-07: clearing removes the session', () async {
    await repository.save(session);

    await repository.clear();

    expect(await repository.load(), isNull);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.containsKey('session_email'), isFalse);
    expect(prefs.containsKey('session_institution'), isFalse);
  });

  test('CA-04: the institutions are UTFPR, UFPR, PUCPR and UEL', () {
    expect(
      [for (final i in Institutions.all) (i.id, i.name)],
      [
        ('utfpr', 'UTFPR'),
        ('ufpr', 'UFPR'),
        ('pucpr', 'PUCPR'),
        ('uel', 'UEL'),
      ],
    );
  });

  test('CA-05: a saved session with an unknown institution, a malformed or an '
      'empty e-mail counts as no session', () async {
    for (final saved in <Map<String, Object>>[
      {'session_email': session.email, 'session_institution': 'foo'},
      {'session_email': 'not-an-email', 'session_institution': 'utfpr'},
      {'session_email': '', 'session_institution': 'utfpr'},
    ]) {
      SharedPreferences.setMockInitialValues(saved);
      expect(await repository.load(), isNull, reason: '$saved');
    }
  });
}
