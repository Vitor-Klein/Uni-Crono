import '../domain/hours.dart';

/// The student's hours could not be loaded (no network, server error).
class HoursLoadFailure implements Exception {
  const HoursLoadFailure();
}

/// Where the student's hours come from.
abstract class HoursRepository {
  /// The latest hours, and every change after that. A failed load arrives as
  /// a [HoursLoadFailure] error.
  Stream<HoursSnapshot> watch();

  /// Loads the hours again.
  Future<void> refresh();

  void dispose();
}
