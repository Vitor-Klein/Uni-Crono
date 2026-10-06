import 'package:flutter_test/flutter_test.dart';

import 'package:uni_cronos/features/auth/data/auth_gateway.dart';
import 'package:uni_cronos/features/auth/domain/session.dart';
import 'package:uni_cronos/features/auth/presentation/session_cubit.dart';

import 'app_harness.dart';

void main() {
  test('CA-01: starts from the session the account server still holds', () {
    final cubit = SessionCubit(FakeAuthGateway(signedIn: demoSession));
    addTearDown(cubit.close);

    expect(cubit.state, demoSession);
  });

  test('CA-01: the right e-mail and password sign in with the user id, the '
      'e-mail and the institution of the account', () async {
    final cubit = SessionCubit(FakeAuthGateway());
    addTearDown(cubit.close);

    await cubit.signIn(
      email: demoSession.email,
      password: demoPassword,
      institutionId: 'utfpr',
    );

    expect(cubit.state, demoSession);
    expect(cubit.state!.userId, 'user-ana');
    expect(cubit.state!.institutionId, 'utfpr');
  });

  test('CA-02: a wrong password fails with InvalidCredentials and stays '
      'signed out', () async {
    final cubit = SessionCubit(FakeAuthGateway());
    addTearDown(cubit.close);

    await expectLater(
      cubit.signIn(
        email: demoSession.email,
        password: 'errada',
        institutionId: 'utfpr',
      ),
      throwsA(isA<InvalidCredentials>()),
    );
    expect(cubit.state, isNull);
  });

  test(
    'CA-03: without network, signing in fails with NetworkFailure',
    () async {
      final cubit = SessionCubit(FakeAuthGateway()..offline = true);
      addTearDown(cubit.close);

      await expectLater(
        cubit.signIn(
          email: demoSession.email,
          password: demoPassword,
          institutionId: 'utfpr',
        ),
        throwsA(isA<NetworkFailure>()),
      );
      expect(cubit.state, isNull);
    },
  );

  test('CA-01: an account of another institution fails with '
      'WrongInstitution, is signed out on the server and never shows up as '
      'signed in', () async {
    final auth = FakeAuthGateway();
    final cubit = SessionCubit(auth);
    addTearDown(cubit.close);
    final states = <Object?>[];
    final sub = cubit.stream.listen(states.add);
    addTearDown(sub.cancel);

    await expectLater(
      cubit.signIn(
        email: demoSession.email,
        password: demoPassword,
        institutionId: 'ufpr',
      ),
      throwsA(isA<WrongInstitution>()),
    );
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state, isNull);
    expect(auth.current, isNull);
    expect(states.whereType<Session>(), isEmpty);
  });

  test('CA-11: signing out ends the session on the server', () async {
    final auth = FakeAuthGateway(signedIn: demoSession);
    final cubit = SessionCubit(auth);
    addTearDown(cubit.close);

    await cubit.signOut();

    expect(cubit.state, isNull);
    expect(auth.current, isNull);
  });

  test('CA-11: a session that expires on the server signs the student '
      'out', () async {
    final auth = FakeAuthGateway(signedIn: demoSession);
    final cubit = SessionCubit(auth);
    addTearDown(cubit.close);

    auth.expire();
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state, isNull);
  });
}
