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

/// A sent PDF the reader could not read: it stays stored until the student
/// launches it by hand or gives up.
class UnreadableCertificate {
  const UnreadableCertificate({required this.path, required this.fileName});

  final String path;
  final String fileName;
}

/// Why a certificate was not launched.
sealed class LaunchFailure implements Exception {
  const LaunchFailure();
}

/// The PDF has no text, or the reader found no workload in it.
class Unreadable extends LaunchFailure {
  const Unreadable(this.pending);

  final UnreadableCertificate pending;
}

/// The student already launched this same PDF.
class Duplicate extends LaunchFailure {
  const Duplicate();
}

/// No network, the reader is down, or it answered something unexpected.
class ReaderUnavailable extends LaunchFailure {
  const ReaderUnavailable();
}

/// Sends a certificate to be read and counted.
abstract class CertificateLauncher {
  /// Throws a [LaunchFailure] when nothing was launched.
  Future<LaunchedCertificate> launch(PickedFile file);

  /// Launches with the data the student typed; only for an [Unreadable] PDF.
  Future<LaunchedCertificate> launchManual(
    UnreadableCertificate pending, {
    required String title,
    required HourCategory category,
    required int hours,
  });

  /// Deletes the stored PDF the student gave up on.
  Future<void> discard(UnreadableCertificate pending);
}
