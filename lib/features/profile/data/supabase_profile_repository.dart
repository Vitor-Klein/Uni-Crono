import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/student_profile.dart';
import 'profile_repository.dart';

/// The signed-in student's row of the `profiles` table, with the e-mail of
/// their account. The table only lets each student read their own row.
class SupabaseProfileRepository implements ProfileRepository {
  SupabaseProfileRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<StudentProfile> current() async {
    final user = _client.auth.currentUser;
    if (user == null) throw const ProfileLoadFailure();
    try {
      final row = await _client
          .from('profiles')
          .select('full_name, institution_id, course, term')
          .eq('id', user.id)
          .single();
      return StudentProfile(
        fullName: row['full_name'] as String,
        email: user.email ?? '',
        institutionId: row['institution_id'] as String,
        course: row['course'] as String,
        term: row['term'] as int,
      );
    } catch (e) {
      // Only the type: the row holds personal data.
      debugPrint('Profile load failed: ${e.runtimeType}');
      throw const ProfileLoadFailure();
    }
  }
}
