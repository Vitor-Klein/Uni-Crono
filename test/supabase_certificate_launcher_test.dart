import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:uni_cronos/features/hours/domain/hours.dart';
import 'package:uni_cronos/features/upload/data/certificate_launcher.dart';
import 'package:uni_cronos/features/upload/data/pdf_text_extractor.dart';
import 'package:uni_cronos/features/upload/data/supabase_certificate_launcher.dart';

import 'app_harness.dart';

const _uid = '11111111-1111-4111-8111-111111111111';

const _declaration =
    'Declaramos que o aluno participou ativamente das atividades vinculadas '
    'ao projeto de extensão universitária da UTFPR.\n'
    'Carga Horária Total: 260 horas.';

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

/// Hands over a fixed text, as if read from the PDF.
class _FakeExtractor implements PdfTextExtractor {
  String text = _declaration;

  @override
  Future<String> extract(Uint8List bytes) async => text;
}

void main() {
  late List<http.Request> requests;
  late http.Response Function(http.Request) answerSelect;
  late http.Response Function(http.Request) answerUpload;
  late http.Response Function(http.Request) answerInsert;
  late SupabaseClient client;
  late _FakeExtractor extractor;
  late SupabaseCertificateLauncher launcher;

  Iterable<http.Request> where(String method, String pathStart) => requests
      .where((r) => r.method == method && r.url.path.startsWith(pathStart));

  setUp(() async {
    requests = [];
    answerSelect = (request) => _json(200, <Object>[], request);
    answerUpload = (request) =>
        _json(200, {'Key': 'certificates/x', 'Id': 'id'}, request);
    answerInsert = (request) => http.Response('', 201, request: request);
    final mock = MockClient((request) async {
      final path = request.url.path;
      if (path.startsWith('/auth/v1/token')) {
        return _json(200, {
          'access_token': _fakeJwt(_uid),
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
      requests.add(request);
      if (path.startsWith('/storage/') && request.method == 'POST') {
        return answerUpload(request);
      }
      if (path.startsWith('/storage/')) return _json(200, <Object>[], request);
      if (request.method == 'GET') return answerSelect(request);
      return answerInsert(request);
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
    await client.auth.signInWithPassword(email: 'a@b.co', password: 'x');
    extractor = _FakeExtractor();
    launcher = SupabaseCertificateLauncher(client, extractor: extractor);
  });

  tearDown(() => client.dispose());

  final file = pickedFile('declaracao.pdf', 2048);
  final sha = sha256.convert(file.bytes).toString();

  test('CA-03: a declaration of 260 extension hours is stored in the student '
      'folder and saved as read', () async {
    final launched = await launcher.launch(file);

    expect((launched.hours, launched.category), (260, HourCategory.extension));
    final check = where('GET', '/rest/v1/certificates').single;
    expect(check.url.queryParameters['file_sha256'], 'eq.$sha');
    final upload = where('POST', '/storage/v1/object/certificates/').single;
    expect(
      upload.url.path,
      matches(
        RegExp(
          '^/storage/v1/object/certificates/$_uid/'
          r'[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\.pdf$',
        ),
      ),
    );
    final insert = where('POST', '/rest/v1/certificates').single;
    final row = jsonDecode(insert.body) as Map<String, dynamic>;
    expect(row['user_id'], _uid);
    expect(row['hours'], 260);
    expect(row['category'], 'extension');
    expect(row['issuer'], 'UTFPR');
    expect(row['source'], 'extracted');
    expect(row['file_sha256'], sha);
    expect(
      upload.url.path,
      '/storage/v1/object/certificates/${row['file_path']}',
    );
  });

  for (final (label, text) in [
    ('no text', ''),
    ('no workload', 'Certificado de participação na palestra.'),
  ]) {
    test(
      'CA-04: a PDF with $label is Unreadable and nothing is stored',
      () async {
        extractor.text = text;

        await expectLater(
          launcher.launch(file),
          throwsA(
            isA<Unreadable>()
                .having((u) => u.pending.file, 'file', file)
                .having((u) => u.pending.title, 'title', 'Declaracao'),
          ),
        );
        expect(requests, isEmpty);
      },
    );
  }

  test(
    'CA-04: launched by hand, the PDF is stored and saved as manual',
    () async {
      final launched = await launcher.launchManual(
        UnreadableCertificate(file: file, title: 'Declaracao'),
        title: 'Mutirão',
        category: HourCategory.extension,
        hours: 12,
      );

      expect(launched.hours, 12);
      expect(where('POST', '/storage/v1/object/certificates/'), hasLength(1));
      final row =
          jsonDecode(where('POST', '/rest/v1/certificates').single.body)
              as Map<String, dynamic>;
      expect(
        (row['title'], row['hours'], row['category'], row['source']),
        ('Mutirão', 12, 'extension', 'manual'),
      );
    },
  );

  test('CA-05: a PDF the student already launched is Duplicate, with no '
      'upload', () async {
    answerSelect = (request) => _json(200, [
      {'id': 'old'},
    ], request);

    await expectLater(launcher.launch(file), throwsA(isA<Duplicate>()));
    expect(where('POST', '/storage/'), isEmpty);
    expect(where('POST', '/rest/'), isEmpty);
  });

  test('CA-06: a failed upload is ReaderUnavailable and nothing is '
      'saved', () async {
    answerUpload = (request) => _json(500, {'error': 'x'}, request);

    await expectLater(launcher.launch(file), throwsA(isA<ReaderUnavailable>()));
    expect(where('POST', '/rest/'), isEmpty);
  });

  test('CA-06: a failed save is ReaderUnavailable and the stored PDF is '
      'deleted', () async {
    answerInsert = (request) => _json(500, {'message': 'down'}, request);

    await expectLater(launcher.launch(file), throwsA(isA<ReaderUnavailable>()));
    final delete = where('DELETE', '/storage/v1/object/certificates').single;
    final upload = where('POST', '/storage/v1/object/certificates/').single;
    expect((jsonDecode(delete.body) as Map<String, dynamic>)['prefixes'], [
      upload.url.path.replaceFirst('/storage/v1/object/certificates/', ''),
    ]);
  });

  test('CA-05: losing a race with the same PDF (unique violation) is '
      'Duplicate, and the copy is deleted', () async {
    answerInsert = (request) =>
        _json(409, {'code': '23505', 'message': 'duplicate key'}, request);

    await expectLater(launcher.launch(file), throwsA(isA<Duplicate>()));
    expect(where('DELETE', '/storage/'), hasLength(1));
  });

  test(
    'CA-06: no network on the duplicate check is ReaderUnavailable',
    () async {
      answerSelect = (_) => throw http.ClientException('offline');

      await expectLater(
        launcher.launch(file),
        throwsA(isA<ReaderUnavailable>()),
      );
    },
  );
}
