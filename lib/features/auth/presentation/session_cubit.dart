import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/session_repository.dart';
import '../domain/session.dart';

/// Who is signed in: the session, or null. Starts from the session read
/// before the app ran, so "not loaded yet" never looks like "signed out".
class SessionCubit extends Cubit<Session?> {
  SessionCubit(this._repository, {Session? initial}) : super(initial);

  final SessionRepository _repository;

  /// Signs in with the given credentials. If the device refuses to save the
  /// session (e.g., storage blocked in the browser), the student is signed in
  /// for this run only — on reopening the app they will be back at the login.
  Future<void> signIn({
    required String institutionId,
    required String email,
  }) async {
    final session = Session(email: email, institutionId: institutionId);
    try {
      await _repository.save(session);
    } catch (e) {
      // Broad catch: on web, blocked storage throws a JS error that is not a Dart Exception.
      debugPrint('Session save failed: ${e.runtimeType}');
    }
    emit(session);
  }

  Future<void> signOut() async {
    await _repository.clear();
    emit(null);
  }
}
