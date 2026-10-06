import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:uni_cronos/features/hours/domain/hours.dart';
import 'package:uni_cronos/features/upload/data/certificate_launcher.dart';
import 'package:uni_cronos/features/upload/data/supabase_certificate_launcher.dart';

import 'app_harness.dart';

const _uid = '11111111-1111-4111-8111-111111111111';
const _reader = 'https://leitor.example.com';

String _fakeJwt(String sub) {
  String part(Map<String, Object> json) =>
      base64Url.encode(utf8.encode(jsonEncode(json))).replaceAll('=', '');
  final exp = DateTime.now().add(const Duration(hours: 1));
  return '${part({'alg': 'HS256', 'typ': 'JWT'})}.'
      '${part({'sub': sub, 'exp': exp.millisecondsSinceEpoch ~/ 1000})}.sig';
}

final _accessToken = _fakeJwt(_uid);

http.Response _json(int status, Object body, http.Request request) =>
    http.Response(
      jsonEncode(body),
      status,
      headers: {'content-type': 'application/json'},
      request: request,
    );

void main() {
  late List<http.Request> requests;
  late http.Response Function(http.Request) answerReader;
  late http.Response Function(http.Request) answerStorage;
  late SupabaseClient client;

  SupabaseCertificateLauncher launcher({String readerUrl = _reader}) {
    final mock = MockClient((request) async {
      requests.add(request);
      final path = request.url.path;
      if (path.startsWith('/auth/v1/token')) {
        return _json(200, {
          'access_token': _accessToken,
          'token_type': 'bearer',
          'expires_in': 3600,
          'refresh_token': 'refresh',
          'user': {
            'id': _uid,
            'aud': 'authenticated',
            'role': 'authenticated',
            'email': 'ana@b.co',
            'app_metadata': <String, Object>{},
            'user_metadata': {'institution_id': 'utfpr'},
            'created_at': '2026-10-06T00:00:00Z',
          },
        }, request);
      }
      if (path.startsWith('/storage/')) return answerStorage(request);
      return answerReader(request);
    });
    client = SupabaseClient(
      'https://projeto.supabase.co',
      'sb_publishable_test',
      httpClient: mock,
      authOptions: const AuthClientOptions(
        autoRefreshToken: false,
        authFlowType: AuthFlowType.implicit,
      ),
    );
    return SupabaseCertificateLauncher(
      client,
      readerUrl: readerUrl,
      httpClient: mock,
    );
  }

  setUp(() {
    requests = [];
    answerStorage = (request) =>
        _json(200, {'Key': 'certificates/x', 'Id': 'id'}, request);
    answerReader = (request) => _json(201, {
      'title': 'Semana Acadêmica',
      'issuer': 'UTFPR',
      'category': 'extension',
      'hours': 20,
    }, request);
  });

  tearDown(() => client.dispose());

  Future<SupabaseCertificateLauncher> signedIn({
    String readerUrl = _reader,
  }) async {
    final subject = launcher(readerUrl: readerUrl);
    await client.auth.signInWithPassword(email: 'ana@b.co', password: 'x');
    requests.clear();
    return subject;
  }

  final file = pickedFile('certificado-game-jam.pdf', 2048);

  test('CA-03: stores the PDF in the student folder and asks the reader with '
      'the student token', () async {
    final subject = await signedIn();

    final launched = await subject.launch(file);

    expect(
      (launched.title, launched.category, launched.hours),
      ('Semana Acadêmica', HourCategory.extension, 20),
    );
    final upload = requests.first;
    expect(
      upload.url.path,
      startsWith('/storage/v1/object/certificates/$_uid/'),
    );
    expect(
      upload.url.path,
      matches(
        RegExp(
          r'/[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\.pdf$',
        ),
      ),
    );
    final read = requests.last;
    expect(read.url.toString(), '$_reader/api/certificates/read');
    expect(read.headers['Authorization'], 'Bearer $_accessToken');
    final body = jsonDecode(read.body) as Map<String, dynamic>;
    expect(body['file_name'], 'certificado-game-jam.pdf');
    expect(upload.url.path, endsWith(body['path'] as String));
  });

  for (final code in ['no_text', 'no_hours']) {
    test('CA-04: $code becomes Unreadable, with the stored path', () async {
      final subject = await signedIn();
      answerReader = (request) => _json(422, {'error': code}, request);

      await expectLater(
        subject.launch(file),
        throwsA(
          isA<Unreadable>()
              .having((u) => u.pending.path, 'path', startsWith('$_uid/'))
              .having(
                (u) => u.pending.fileName,
                'fileName',
                'certificado-game-jam.pdf',
              ),
        ),
      );
    });
  }

  test('CA-05: duplicate becomes Duplicate', () async {
    final subject = await signedIn();
    answerReader = (request) => _json(409, {'error': 'duplicate'}, request);

    await expectLater(subject.launch(file), throwsA(isA<Duplicate>()));
  });

  test('CA-06: a reader error, no network, a failed upload or no reader '
      'address become ReaderUnavailable', () async {
    var subject = await signedIn();
    answerReader = (request) => _json(500, {'error': 'unavailable'}, request);
    await expectLater(subject.launch(file), throwsA(isA<ReaderUnavailable>()));

    answerReader = (_) => throw http.ClientException('offline');
    await expectLater(subject.launch(file), throwsA(isA<ReaderUnavailable>()));

    answerStorage = (request) => _json(500, {'error': 'x'}, request);
    await expectLater(subject.launch(file), throwsA(isA<ReaderUnavailable>()));

    client.dispose();
    subject = await signedIn(readerUrl: '');
    await expectLater(subject.launch(file), throwsA(isA<ReaderUnavailable>()));
  });

  const pending = UnreadableCertificate(
    path: '$_uid/22222222-2222-4222-8222-222222222222.pdf',
    fileName: 'certificado-game-jam.pdf',
  );

  test('CA-04b: launching by hand sends the typed data for the stored '
      'PDF', () async {
    final subject = await signedIn();
    answerReader = (request) => _json(201, {
      'title': 'Mutirão',
      'issuer': null,
      'category': 'extension',
      'hours': 12,
    }, request);

    final launched = await subject.launchManual(
      pending,
      title: 'Mutirão',
      category: HourCategory.extension,
      hours: 12,
    );

    expect(launched.hours, 12);
    final manual = requests.single;
    expect(manual.url.toString(), '$_reader/api/certificates/manual');
    expect(jsonDecode(manual.body), {
      'path': pending.path,
      'title': 'Mutirão',
      'category': 'extension',
      'hours': 12,
    });
  });

  test('CA-04b: by hand, duplicate is Duplicate and anything else is '
      'ReaderUnavailable', () async {
    final subject = await signedIn();
    Future<LaunchedCertificate> launch() => subject.launchManual(
      pending,
      title: 'x',
      category: HourCategory.complementary,
      hours: 1,
    );

    answerReader = (request) => _json(409, {'error': 'duplicate'}, request);
    await expectLater(launch(), throwsA(isA<Duplicate>()));

    answerReader = (request) => _json(409, {'error': 'readable'}, request);
    await expectLater(launch(), throwsA(isA<ReaderUnavailable>()));
  });

  test('CA-04c: discarding deletes the stored PDF', () async {
    final subject = await signedIn();

    await subject.discard(pending);

    final delete = requests.single;
    expect(delete.method, 'DELETE');
    expect(delete.url.path, '/storage/v1/object/certificates');
    expect(jsonDecode(delete.body), {
      'prefixes': [pending.path],
    });
  });
}
