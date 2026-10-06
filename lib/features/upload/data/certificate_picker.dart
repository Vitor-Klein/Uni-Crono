import '../domain/picked_file.dart';

/// Lets the student choose a file; null when they give up.
abstract class CertificatePicker {
  Future<PickedFile?> pick();
}
