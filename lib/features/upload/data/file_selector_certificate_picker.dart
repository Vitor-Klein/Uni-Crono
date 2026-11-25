import 'package:file_selector/file_selector.dart';

import '../domain/picked_file.dart';
import 'certificate_picker.dart';

/// The system file chooser, showing only PDFs.
class FileSelectorCertificatePicker implements CertificatePicker {
  const FileSelectorCertificatePicker();

  // Each platform filters by a different key: Android by MIME type, iOS by
  // UTI, and the others by extension.
  static const _pdf = XTypeGroup(
    label: 'PDF',
    extensions: ['pdf'],
    mimeTypes: ['application/pdf'],
    uniformTypeIdentifiers: ['com.adobe.pdf'],
  );

  @override
  Future<PickedFile?> pick() async {
    final file = await openFile(acceptedTypeGroups: const [_pdf]);
    if (file == null) return null;
    final bytes = await file.readAsBytes();
    return PickedFile(name: file.name, sizeBytes: bytes.length, bytes: bytes);
  }
}
