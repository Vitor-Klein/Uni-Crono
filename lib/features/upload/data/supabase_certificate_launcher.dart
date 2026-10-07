import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../auth/domain/institution.dart';
import '../../hours/domain/hours.dart';
import '../domain/certificate_reading.dart';
import '../domain/picked_file.dart';
import 'certificate_launcher.dart';
import 'pdf_text_extractor.dart';

/// Reads the PDF on the device, stores it in the student's folder of the
/// private `certificates` bucket and saves the certificate. The table only
/// takes rows of the signed-in student; the same PDF counts once.
class SupabaseCertificateLauncher implements CertificateLauncher {
  SupabaseCertificateLauncher(
    this._client, {
    required PdfTextExtractor extractor,
  }) : _extractor = extractor;

  static const bucket = 'certificates';

  final SupabaseClient _client;
  final PdfTextExtractor _extractor;
  final _random = Random.secure();

  @override
  Future<LaunchedCertificate> launch(PickedFile file) async {
    final text = await _extractor.extract(file.bytes);
    final reading = readCertificate(
      text,
      fileName: file.name,
      institution: _institutionName(),
    );
    final hours = reading.hours;
    if (text.isEmpty || hours == null) {
      throw Unreadable(UnreadableCertificate(file: file, title: reading.title));
    }
    return _save(
      file,
      title: reading.title,
      issuer: reading.issuer,
      category: reading.category,
      hours: hours,
      source: 'extracted',
    );
  }

  @override
  Future<LaunchedCertificate> launchManual(
    UnreadableCertificate pending, {
    required String title,
    required HourCategory category,
    required int hours,
  }) => _save(
    pending.file,
    title: title,
    issuer: null,
    category: category,
    hours: hours,
    source: 'manual',
  );

  Future<LaunchedCertificate> _save(
    PickedFile file, {
    required String title,
    required String? issuer,
    required HourCategory category,
    required int hours,
    required String source,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw const ReaderUnavailable();
    final sha = sha256.convert(file.bytes).toString();

    try {
      final existing = await _client
          .from('certificates')
          .select('id')
          .eq('user_id', userId)
          .eq('file_sha256', sha)
          .limit(1);
      if (existing.isNotEmpty) throw const Duplicate();
    } on LaunchFailure {
      rethrow;
    } catch (e) {
      debugPrint('Duplicate check failed: ${e.runtimeType}');
      throw const ReaderUnavailable();
    }

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

    try {
      await _client.from('certificates').insert({
        'user_id': userId,
        'title': title,
        'issuer': issuer,
        'category': category.name,
        'hours': hours,
        'file_path': path,
        'file_sha256': sha,
        'source': source,
      });
    } catch (e) {
      // Nothing half done: the stored PDF goes with the failed save.
      await _removeQuietly(path);
      if (e is PostgrestException && e.code == '23505') {
        throw const Duplicate();
      }
      debugPrint('Certificate save failed: ${e.runtimeType}');
      throw const ReaderUnavailable();
    }
    return LaunchedCertificate(title: title, category: category, hours: hours);
  }

  Future<void> _removeQuietly(String path) async {
    try {
      await _client.storage.from(bucket).remove([path]);
    } catch (e) {
      debugPrint('Certificate cleanup failed: ${e.runtimeType}');
    }
  }

  /// The name of the student's institution, as certificates print it.
  String _institutionName() {
    final id = _client.auth.currentUser?.userMetadata?['institution_id'];
    return Institutions.all
            .where((institution) => institution.id == id)
            .map((institution) => institution.name)
            .firstOrNull ??
        '';
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
