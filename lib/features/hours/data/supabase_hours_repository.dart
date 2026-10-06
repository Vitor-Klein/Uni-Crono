import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/hours.dart';
import 'hours_repository.dart';

/// The certificates of the signed-in student, from the `certificates` table.
/// The table only lets each student read their own rows; the query also
/// filters by the student, so it uses the index.
class SupabaseHoursRepository implements HoursRepository {
  SupabaseHoursRepository(this._client) {
    _authChanges = _client.auth.onAuthStateChange.listen((state) {
      // The repository outlives the screens: forget the hours on sign-out,
      // so the next student on this device never sees them.
      if (state.event == AuthChangeEvent.signedOut) _subject.add(null);
    }, onError: (Object _) {});
  }

  final SupabaseClient _client;
  final _subject = BehaviorSubject<HoursSnapshot?>();
  late final StreamSubscription<AuthState> _authChanges;

  @override
  Stream<HoursSnapshot> watch() =>
      _subject.stream.where((snapshot) => snapshot != null).cast();

  @override
  Future<void> refresh() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      _subject.add(HoursSnapshot.fromCertificates(const []));
      return;
    }
    try {
      final rows = await _client
          .from('certificates')
          .select('id, title, category, hours, approved_at')
          .eq('user_id', userId)
          .order('approved_at', ascending: false);
      _subject.add(HoursSnapshot.fromCertificates(rows.map(_parse).toList()));
    } catch (e) {
      // Only the type: the rows hold personal data.
      debugPrint('Hours load failed: ${e.runtimeType}');
      _subject.addError(const HoursLoadFailure());
    }
  }

  /// A row read from the server is external data: anything unexpected fails
  /// the load instead of being counted.
  static ApprovedCertificate _parse(Map<String, dynamic> row) {
    final category = HourCategory.values.firstWhere(
      (c) => c.name == row['category'],
      orElse: () => throw const FormatException('category'),
    );
    final hours = row['hours'];
    if (hours is! int || hours < 1 || hours > 999) {
      throw const FormatException('hours');
    }
    return ApprovedCertificate(
      id: row['id'] as String,
      title: row['title'] as String,
      category: category,
      hours: hours,
      approvedAt: DateTime.parse(row['approved_at'] as String),
    );
  }

  @override
  void dispose() {
    _authChanges.cancel();
    _subject.close();
  }
}
