import 'picked_file.dart';

/// Largest certificate the app sends, the same limit as the storage bucket.
const maxCertificateBytes = 10 * 1024 * 1024;

const _pdfSignature = '%PDF-';

/// Whether [file] is a PDF of at most 10 MB: by its extension and its first
/// bytes. The reader checks it again on the server: this only spares an
/// upload that would be refused.
bool isAcceptedCertificate(PickedFile file) {
  if (!file.name.toLowerCase().endsWith('.pdf')) return false;
  if (file.sizeBytes > maxCertificateBytes) return false;
  final bytes = file.bytes;
  if (bytes.length < _pdfSignature.length) return false;
  return String.fromCharCodes(bytes.take(_pdfSignature.length)) ==
      _pdfSignature;
}

/// `certificado-game-jam.pdf` -> "Certificado Game Jam".
String titleFromFileName(String fileName) {
  final name = fileName.split(RegExp(r'[/\\]')).last;
  final dot = name.lastIndexOf('.');
  final stem = dot > 0 ? name.substring(0, dot) : name;
  return stem
      .split(RegExp(r'[-_\s]+'))
      .where((word) => word.isNotEmpty)
      .map((word) => word[0].toUpperCase() + word.substring(1))
      .join(' ');
}
