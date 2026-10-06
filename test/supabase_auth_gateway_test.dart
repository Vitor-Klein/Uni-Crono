import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Session;

import 'package:uni_cronos/features/auth/data/auth_gateway.dart';
import 'package:uni_cronos/features/auth/data/supabase_auth_gateway.dart';
import 'package:uni_cronos/features/auth/domain/session.dart';
import 'package:uni_cronos/features/auth/domain/sign_up_data.dart';

/// A token the SDK can read: it only decodes the payload, never checks the
/// signature.
String _fakeJwt(String sub) {
  String part(Map<String, Object> json) =>
      base64Url.encode(utf8.encode(jsonEncode(json))).replaceAll('=', '');
  final exp = DateTime.now().add(const Duration(hours: 1));
  return '${part({'alg': 'HS256', 'typ': 'JWT'})}.'
      '${part({'sub': sub, 'exp': exp.millisecondsSinceEpoch ~/ 1000})}.sig';
}

Map<String, Object> _sessionJson({
  String id = 'user-ana',
  String email = 'ana.souza@alunos.utfpr.edu.br',
  String institutionId = 'utfpr',
}) => {
  'access_token': _fakeJwt(id),
  'token_type': 'bearer',
  'expires_in': 3600,
  'refresh_token': 'refresh',
  'user': {
    'id': id,
    'aud': 'authenticated',
    'role': 'authenticated',
    'email': email,
    'app_metadata': <String, Object>{},
    'user_metadata': {'institution_id': institutionId},
    'created_at': '2026-10-06T00:00:00Z',
  },
};

http.Response _json(int status, Object body) => http.Response(
  jsonEncode(body),
  status,
  headers: {
    'content-type': 'application/json',
    'x-supabase-api-version': '2024-01-01',
  },
);

void main() {
  late List<http.Request> requests;

  SupabaseAuthGateway gatewayAnswering(
    Future<http.Response> Function(http.Request request) answer,
  ) {
    requests = [];
    final client = SupabaseClient(
      'https://projeto.supabase.co',
      'sb_publishable_test',
      httpClient: MockClient((request) {
        requests.add(request);
        return answer(request);
      }),
      authOptions: const AuthClientOptions(
        autoRefreshToken: false,
        authFlowType: AuthFlowType.implicit,
      ),
    );
    addTearDown(client.dispose);
    return SupabaseAuthGateway(client);
  }

  const signUpData = SignUpData(
    fullName: 'Ana Souza',
    institutionId: 'utfpr',
    course: 'Engenharia de Software',
    term: 5,
    email: 'ana.souza@alunos.utfpr.edu.br',
    password: 'senha-certa',
  );

  test('CA-01: signing in returns the user id, the e-mail and the institution '
      'kept in the account', () async {
    final gateway = gatewayAnswering((_) async => _json(200, _sessionJson()));

    final session = await gateway.signIn(
      email: 'ana.souza@alunos.utfpr.edu.br',
      password: 'senha-certa',
    );

    expect(
      session,
      const Session(
        userId: 'user-ana',
        email: 'ana.souza@alunos.utfpr.edu.br',
        institutionId: 'utfpr',
      ),
    );
    expect(gateway.current, session);
    expect(requests.single.url.path, '/auth/v1/token');
  });

  test('CA-02: wrong credentials become InvalidCredentials', () async {
    final gateway = gatewayAnswering(
      (_) async => _json(400, {
        'code': 'invalid_credentials',
        'message': 'Invalid login credentials',
      }),
    );

    await expectLater(
      gateway.signIn(email: 'a@b.co', password: 'x'),
      throwsA(isA<InvalidCredentials>()),
    );
  });

  test('CA-03: no network becomes NetworkFailure', () async {
    final gateway = gatewayAnswering(
      (_) async => throw http.ClientException('Failed host lookup'),
    );

    await expectLater(
      gateway.signIn(email: 'a@b.co', password: 'x'),
      throwsA(isA<NetworkFailure>()),
    );
  });

  test('CA-03: a server error becomes NetworkFailure', () async {
    final gateway = gatewayAnswering((_) async => _json(503, {'msg': 'down'}));

    await expectLater(
      gateway.signIn(email: 'a@b.co', password: 'x'),
      throwsA(isA<NetworkFailure>()),
    );
  });

  test('CA-05: signing up sends the profile as account data and signs '
      'in', () async {
    final gateway = gatewayAnswering((_) async => _json(200, _sessionJson()));

    final session = await gateway.signUp(signUpData);

    expect(session.userId, 'user-ana');
    final body = jsonDecode(requests.single.body) as Map<String, dynamic>;
    expect(body['email'], 'ana.souza@alunos.utfpr.edu.br');
    expect(body['data'], {
      'full_name': 'Ana Souza',
      'institution_id': 'utfpr',
      'course': 'Engenharia de Software',
      'term': 5,
    });
  });

  test('CA-06: an e-mail that already has an account becomes '
      'EmailAlreadyRegistered', () async {
    final gateway = gatewayAnswering(
      (_) async => _json(422, {
        'code': 'user_already_exists',
        'message': 'User already registered',
      }),
    );

    await expectLater(
      gateway.signUp(signUpData),
      throwsA(isA<EmailAlreadyRegistered>()),
    );
  });

  test('CA-05: an account created without a session (e-mail confirmation on) '
      'becomes ConfirmationRequired', () async {
    final user = _sessionJson()['user']!;
    final gateway = gatewayAnswering((_) async => _json(200, user));

    await expectLater(
      gateway.signUp(signUpData),
      throwsA(isA<ConfirmationRequired>()),
    );
  });

  test('CA-11: signing out ends the session even without network', () async {
    var calls = 0;
    final gateway = gatewayAnswering((_) async {
      calls++;
      if (calls == 1) return _json(200, _sessionJson());
      throw http.ClientException('offline');
    });
    await gateway.signIn(email: 'a@b.co', password: 'x');
    final ended = expectLater(gateway.changes(), emitsThrough(isNull));

    await gateway.signOut();

    expect(gateway.current, isNull);
    await ended;
  });
}
