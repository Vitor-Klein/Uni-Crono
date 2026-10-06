import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:uni_cronos/features/hours/data/hours_repository.dart';
import 'package:uni_cronos/features/hours/data/supabase_hours_repository.dart';
import 'package:uni_cronos/features/hours/domain/hours.dart';

String _fakeJwt(String sub) {
  String part(Map<String, Object> json) =>
      base64Url.encode(utf8.encode(jsonEncode(json))).replaceAll('=', '');
  final exp = DateTime.now().add(const Duration(hours: 1));
  return '${part({'alg': 'HS256', 'typ': 'JWT'})}.'
      '${part({'sub': sub, 'exp': exp.millisecondsSinceEpoch ~/ 1000})}.sig';
}

/// A JSON answer to [request]; the SDK reads the request back from the
/// response, as a real client returns it.
http.Response _json(int status, Object body, [http.Request? request]) =>
    http.Response(
      jsonEncode(body),
      status,
      headers: {'content-type': 'application/json'},
      request: request,
    );

final _session = {
  'access_token': _fakeJwt('user-ana'),
  'token_type': 'bearer',
  'expires_in': 3600,
  'refresh_token': 'refresh',
  'user': {
    'id': 'user-ana',
    'aud': 'authenticated',
    'role': 'authenticated',
    'email': 'ana.souza@alunos.utfpr.edu.br',
    'app_metadata': <String, Object>{},
    'user_metadata': {'institution_id': 'utfpr'},
    'created_at': '2026-10-06T00:00:00Z',
  },
};

final _rows = [
  {
    'id': 'b',
    'title': 'Novo',
    'category': 'extension',
    'hours': 15,
    'approved_at': '2026-10-01T12:00:00+00:00',
  },
  {
    'id': 'a',
    'title': 'Antigo',
    'category': 'complementary',
    'hours': 10,
    'approved_at': '2026-09-01T12:00:00+00:00',
  },
];

void main() {
  late List<http.Request> requests;
  late Future<http.Response> Function(http.Request) answerRest;
  late SupabaseClient client;
  late SupabaseHoursRepository repository;

  setUp(() async {
    requests = [];
    answerRest = (request) async => _json(200, _rows, request);
    client = SupabaseClient(
      'https://projeto.supabase.co',
      'sb_publishable_test',
      httpClient: MockClient((request) {
        requests.add(request);
        if (request.url.path.startsWith('/auth/v1/token')) {
          return Future.value(_json(200, _session));
        }
        if (request.url.path.startsWith('/auth/v1/logout')) {
          return Future.value(http.Response('', 204));
        }
        return answerRest(request);
      }),
      authOptions: const AuthClientOptions(
        autoRefreshToken: false,
        authFlowType: AuthFlowType.implicit,
      ),
    );
    await client.auth.signInWithPassword(email: 'a@b.co', password: 'x');
    repository = SupabaseHoursRepository(client);
  });

  tearDown(() async {
    repository.dispose();
    await client.dispose();
  });

  test('CA-08: the certificates of the signed-in student become the hours, '
      'newest first', () async {
    final snapshot = repository.watch().first;

    await repository.refresh();

    final hours = await snapshot;
    expect(hours.of(HourCategory.complementary).hours, 10);
    expect(hours.of(HourCategory.extension).hours, 15);
    expect([for (final c in hours.recent) c.title], ['Novo', 'Antigo']);
    final query = requests.last.url;
    expect(query.path, '/rest/v1/certificates');
    expect(query.queryParameters['user_id'], 'eq.user-ana');
  });

  test('CA-09: a failed load arrives as HoursLoadFailure, and the next '
      'refresh loads again', () async {
    answerRest = (request) async => _json(500, {'message': 'down'}, request);
    final events = expectLater(
      repository.watch(),
      emitsInOrder([emitsError(isA<HoursLoadFailure>()), isA<HoursSnapshot>()]),
    );

    await repository.refresh();
    answerRest = (request) async => _json(200, _rows, request);
    await repository.refresh();
    await events;
  });

  test('CA-09: a row the app does not understand fails the load instead of '
      'being counted', () async {
    answerRest = (request) async => _json(200, [
      {..._rows.first, 'category': 'unknown'},
    ], request);
    final failed = expectLater(
      repository.watch(),
      emitsError(isA<HoursLoadFailure>()),
    );

    await repository.refresh();
    await failed;
  });

  test('CA-11: after signing out, the hours of the previous student are not '
      'handed to anyone', () async {
    await repository.refresh();
    await repository.watch().first;

    await client.auth.signOut();
    await Future<void>.delayed(Duration.zero);

    final seen = <Object>[];
    final sub = repository.watch().listen(seen.add, onError: seen.add);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    await sub.cancel();
    expect(seen, isEmpty);
  });
}
