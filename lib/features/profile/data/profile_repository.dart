import '../domain/student_profile.dart';

/// The profile could not be loaded (no network, server error).
class ProfileLoadFailure implements Exception {
  const ProfileLoadFailure();
}

/// The signed-in student's profile.
abstract class ProfileRepository {
  /// Throws [ProfileLoadFailure] when it cannot be loaded.
  Future<StudentProfile> current();
}
