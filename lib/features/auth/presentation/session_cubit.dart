import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/session_repository.dart';
import '../domain/session.dart';

/// Who is signed in: the session, or null. Starts from the session read
/// before the app ran, so "not loaded yet" never looks like "signed out".
class SessionCubit extends Cubit<Session?> {
  SessionCubit(this._repository, {Session? initial}) : super(initial);

  final SessionRepository _repository;

  Future<void> signIn({
    required String institutionId,
    required String email,
  }) async {
    final session = Session(email: email, institutionId: institutionId);
    await _repository.save(session);
    emit(session);
  }

  Future<void> signOut() async {
    await _repository.clear();
    emit(null);
  }
}
