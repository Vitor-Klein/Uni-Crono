import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../hours/domain/hours.dart';
import '../domain/picked_file.dart';
import 'certificate_launcher.dart';

/// Stores the PDF in the student's folder of the private `certificates`
/// bucket, then asks the reader to count it. The reader is the only one that
/// writes certificates: the app never sends hours it read itself.
class SupabaseCertificateLauncher implements CertificateLauncher {
  SupabaseCertificateLauncher(
    this._client, {
    required String readerUrl,
    http.Client? httpClient,
  }) : _readerUrl = readerUrl,
       _http = httpClient ?? http.Client();

  static const bucket = 'certificates';
  static const _timeout = Duration(seconds: 30);

  final SupabaseClient _client;
  final String _readerUrl;
  final http.Client _http;
  final _random = Random.secure();

  @override
  Future<LaunchedCertificate> launch(PickedFile file) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null || _readerUrl.isEmpty) throw const ReaderUnavailable();
    final path = '$userId/${_uuidV4()}.pdf';
    try {
      await _client.storage
          .from(bucket)
          .uploadBinary(
            path,
            file.bytes,
            fileOptions: const FileOptions(contentType: 'application/pdf'),
          );
    } catch (e) {
      debugPrint('Certificate upload failed: ${e.runtimeType}');
      throw const ReaderUnavailable();
    }
    final response = await _post('read', {
      'path': path,
      'file_name': file.name,
    });
    return switch ((response.statusCode, _errorOf(response))) {
      (201, _) => _launched(response),
      (422, 'no_text' || 'no_hours') => throw Unreadable(
        UnreadableCertificate(path: path, fileName: file.name),
      ),
      (409, 'duplicate') => throw const Duplicate(),
      _ => throw const ReaderUnavailable(),
    };
  }

  @override
  Future<LaunchedCertificate> launchManual(
    UnreadableCertificate pending, {
    required String title,
    required HourCategory category,
    required int hours,
  }) async {
    if (_readerUrl.isEmpty) throw const ReaderUnavailable();
    final response = await _post('manual', {
      'path': pending.path,
      'title': title,
      'category': category.name,
      'hours': hours,
    });
    return switch ((response.statusCode, _errorOf(response))) {
      (201, _) => _launched(response),
      (409, 'duplicate') => throw const Duplicate(),
      _ => throw const ReaderUnavailable(),
    };
  }

  @override
  Future<void> discard(UnreadableCertificate pending) async {
    try {
      await _client.storage.from(bucket).remove([pending.path]);
    } catch (e) {
      // Best effort: a PDF left behind is only the student's own file.
      debugPrint('Certificate discard failed: ${e.runtimeType}');
    }
  }

  Future<http.Response> _post(String action, Map<String, Object> body) async {
    final token = _client.auth.currentSession?.accessToken;
    if (token == null) throw const ReaderUnavailable();
    try {
      return await _http
          .post(
            Uri.parse('$_readerUrl/api/certificates/$action'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(_timeout);
    } catch (e) {
      debugPrint('Certificate reader unreachable: ${e.runtimeType}');
      throw const ReaderUnavailable();
    }
  }

  static String? _errorOf(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      return body is Map<String, dynamic> ? body['error'] as String? : null;
    } on FormatException {
      return null;
    }
  }

  /// The reader's answer is external data: anything unexpected is a failure.
  static LaunchedCertificate _launched(http.Response response) {
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final hours = body['hours'] as int;
      if (hours < 1 || hours > 999) throw const FormatException('hours');
      return LaunchedCertificate(
        title: body['title'] as String,
        category: HourCategory.values.byName(body['category'] as String),
        hours: hours,
      );
    } catch (_) {
      throw const ReaderUnavailable();
    }
  }

  /// A random (version 4) UUID, the name of the stored file.
  String _uuidV4() {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-'
        '${hex.substring(20)}';
  }
}
