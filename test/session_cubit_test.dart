import 'package:flutter_test/flutter_test.dart';

import 'package:uni_cronos/features/auth/data/session_repository.dart';
import 'package:uni_cronos/features/auth/domain/session.dart';
import 'package:uni_cronos/features/auth/presentation/session_cubit.dart';

class _MemorySessionRepository implements SessionRepository {
  Session? stored;

  @override
  Future<Session?> load() async => stored;

  @override
  Future<void> save(Session session) async => stored = session;

  @override
  Future<void> clear() async => stored = null;
}

class _FailingSaveRepository extends _MemorySessionRepository {
  @override
  Future<void> save(Session session) async =>
      throw Exception('storage blocked');
}

void main() {
  const session = Session(
    email: 'ana.souza@alunos.utfpr.edu.br',
    institutionId: 'utfpr',
  );

  test('CA-05: starts from the session it is given', () {
    final cubit = SessionCubit(_MemorySessionRepository(), initial: session);
    addTearDown(cubit.close);

    expect(cubit.state, session);
  });

  test('CA-04: signing in saves the session and emits it', () async {
    final repository = _MemorySessionRepository();
    final cubit = SessionCubit(repository);
    addTearDown(cubit.close);

    await cubit.signIn(institutionId: 'utfpr', email: session.email);

    expect(cubit.state, session);
    expect(repository.stored, session);
  });

  test('CA-07: signing out clears the session and emits null', () async {
    final repository = _MemorySessionRepository()..stored = session;
    final cubit = SessionCubit(repository, initial: session);
    addTearDown(cubit.close);

    await cubit.signOut();

    expect(cubit.state, isNull);
    expect(repository.stored, isNull);
  });

  test('CA-10: when the session cannot be saved, signing in still signs in, '
      'for this run only', () async {
    final repository = _FailingSaveRepository();
    final cubit = SessionCubit(repository);
    addTearDown(cubit.close);

    await cubit.signIn(institutionId: 'utfpr', email: session.email);

    expect(cubit.state, session);
    expect(repository.stored, isNull);
  });
}
