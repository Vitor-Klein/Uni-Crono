import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:uni_cronos/features/hours/domain/hours.dart';
import 'package:uni_cronos/features/opportunities/data/opportunity_repository.dart';
import 'package:uni_cronos/features/opportunities/data/supabase_opportunity_repository.dart';
import 'package:uni_cronos/features/opportunities/domain/opportunity.dart';
import 'package:uni_cronos/features/profile/data/profile_repository.dart';
import 'package:uni_cronos/features/profile/data/supabase_profile_repository.dart';

const _uid = '11111111-1111-4111-8111-111111111111';

String _fakeJwt(String sub) {
  String part(Map<String, Object> json) =>
      base64Url.encode(utf8.encode(jsonEncode(json))).replaceAll('=', '');
  final exp = DateTime.now().add(const Duration(hours: 1));
  return '${part({'alg': 'HS256', 'typ': 'JWT'})}.'
      '${part({'sub': sub, 'exp': exp.millisecondsSinceEpoch ~/ 1000})}.sig';
}

http.Response _json(int status, Object body, http.Request request) =>
    http.Response(
      jsonEncode(body),
      status,
      headers: {'content-type': 'application/json'},
      request: request,
    );

Map<String, Object?> _row({
  String id = 'semana',
  String kind = 'event',
  String category = 'complementary',
  String modality = 'presencial',
  String? url = 'https://example.com/semana',
}) => {
  'id': id,
  'kind': kind,
  'hour_category': category,
  'title': 'Semana Acadêmica',
  'description': 'Palestras',
  'provider': 'Centro Acadêmico (exemplo)',
  'modality': modality,
  'hours': 20,
  'starts_at': '2026-11-09',
  'url': url,
  'featured': true,
};

void main() {
  late List<http.Request> requests;
  late http.Response Function(http.Request) answerRest;
  late SupabaseClient client;

  setUp(() async {
    requests = [];
    client = SupabaseClient(
      'https://projeto.supabase.co',
      'sb_publishable_test',
      httpClient: MockClient((request) async {
        requests.add(request);
        if (request.url.path.startsWith('/auth/v1/token')) {
          return _json(200, {
            'access_token': _fakeJwt(_uid),
            'token_type': 'bearer',
            'expires_in': 3600,
            'refresh_token': 'refresh',
            'user': {
              'id': _uid,
              'aud': 'authenticated',
              'role': 'authenticated',
              'email': 'ana.souza@alunos.utfpr.edu.br',
              'app_metadata': <String, Object>{},
              'user_metadata': {'institution_id': 'utfpr'},
              'created_at': '2026-10-06T00:00:00Z',
            },
          }, request);
        }
        return answerRest(request);
      }),
      authOptions: const AuthClientOptions(
        autoRefreshToken: false,
        authFlowType: AuthFlowType.implicit,
      ),
    );
    await client.auth.signInWithPassword(email: 'a@b.co', password: 'x');
    requests.clear();
  });

  tearDown(() => client.dispose());

  group('opportunities', () {
    test('CA-01: the published rows become opportunities', () async {
      answerRest = (request) => _json(200, [_row()], request);

      final list = await SupabaseOpportunityRepository(client).list();

      final o = list.single;
      expect(
        (o.id, o.kind, o.category, o.modality, o.hours, o.featured),
        (
          'semana',
          OpportunityKind.event,
          HourCategory.complementary,
          Modality.presencial,
          20,
          true,
        ),
      );
      expect(o.startsAt, DateTime(2026, 11, 9));
      expect(o.url, Uri.parse('https://example.com/semana'));
      expect(requests.single.url.path, '/rest/v1/opportunities');
      expect(requests.single.url.queryParameters['published'], 'eq.true');
    });

    test('CA-04: a link that is not https is dropped', () async {
      answerRest = (request) =>
          _json(200, [_row(url: 'javascript:alert(1)')], request);

      final list = await SupabaseOpportunityRepository(client).list();

      expect(list.single.url, isNull);
    });

    test('CA-01: a row the app does not understand is left out, the rest '
        'shows', () async {
      answerRest = (request) => _json(200, [
        _row(id: 'ok'),
        _row(id: 'bad', modality: 'teleporte'),
      ], request);

      final list = await SupabaseOpportunityRepository(client).list();

      expect(list.map((o) => o.id), ['ok']);
    });

    test('CA-05: a failed load is OpportunityLoadFailure', () async {
      answerRest = (request) => _json(500, {'message': 'down'}, request);

      await expectLater(
        SupabaseOpportunityRepository(client).list(),
        throwsA(isA<OpportunityLoadFailure>()),
      );
    });
  });

  group('profile', () {
    test('CA-06: the profile row of the student, with the e-mail of the '
        'account', () async {
      answerRest = (request) => _json(200, {
        'full_name': 'Ana Souza',
        'institution_id': 'utfpr',
        'course': 'Engenharia de Software',
        'term': 5,
      }, request);

      final profile = await SupabaseProfileRepository(client).current();

      expect(
        (
          profile.fullName,
          profile.email,
          profile.institutionId,
          profile.course,
          profile.term,
        ),
        (
          'Ana Souza',
          'ana.souza@alunos.utfpr.edu.br',
          'utfpr',
          'Engenharia de Software',
          5,
        ),
      );
      expect(requests.single.url.path, '/rest/v1/profiles');
      expect(requests.single.url.queryParameters['id'], 'eq.$_uid');
    });

    test('CA-06: a failed load is ProfileLoadFailure', () async {
      answerRest = (request) => _json(500, {'message': 'down'}, request);

      await expectLater(
        SupabaseProfileRepository(client).current(),
        throwsA(isA<ProfileLoadFailure>()),
      );
    });
  });
}
