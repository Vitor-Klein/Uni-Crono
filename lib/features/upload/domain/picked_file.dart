import 'dart:typed_data';

/// A file the student chose to send.
class PickedFile {
  const PickedFile({
    required this.name,
    required this.sizeBytes,
    required this.bytes,
  });

  final String name;
  final int sizeBytes;
  final Uint8List bytes;
}
