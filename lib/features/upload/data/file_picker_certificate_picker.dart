import 'package:file_picker/file_picker.dart';

import '../domain/picked_file.dart';
import 'certificate_picker.dart';

/// The system file chooser, showing only PDFs.
class FilePickerCertificatePicker implements CertificatePicker {
  const FilePickerCertificatePicker();

  @override
  Future<PickedFile?> pick() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
      withData: true,
    );
    final file = result?.files.singleOrNull;
    final bytes = file?.bytes;
    if (file == null || bytes == null) return null;
    return PickedFile(name: file.name, sizeBytes: file.size, bytes: bytes);
  }
}
