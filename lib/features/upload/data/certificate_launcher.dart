import '../../hours/domain/hours.dart';
import '../domain/picked_file.dart';

/// A certificate whose hours now count.
class LaunchedCertificate {
  const LaunchedCertificate({
    required this.title,
    required this.category,
    required this.hours,
  });

  final String title;
  final HourCategory category;
  final int hours;
}

/// A PDF whose text has no workload (or no text at all): the student types
/// the data. Nothing was stored yet.
class UnreadableCertificate {
  const UnreadableCertificate({required this.file, required this.title});

  final PickedFile file;

  /// The title read from the text, or from the file name.
  final String title;
}

/// Why a certificate was not launched.
sealed class LaunchFailure implements Exception {
  const LaunchFailure();
}

/// The PDF has no text, or no workload was found in it.
class Unreadable extends LaunchFailure {
  const Unreadable(this.pending);

  final UnreadableCertificate pending;
}

/// The student already launched this same PDF.
class Duplicate extends LaunchFailure {
  const Duplicate();
}

/// No network, or the server refused to store the certificate.
class ReaderUnavailable extends LaunchFailure {
  const ReaderUnavailable();
}

/// Reads a certificate and counts it.
abstract class CertificateLauncher {
  /// Throws a [LaunchFailure] when nothing was launched.
  Future<LaunchedCertificate> launch(PickedFile file);

  /// Launches with the data the student typed; for an [Unreadable] PDF.
  Future<LaunchedCertificate> launchManual(
    UnreadableCertificate pending, {
    required String title,
    required HourCategory category,
    required int hours,
  });
}
