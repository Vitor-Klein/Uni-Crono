import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/auth_gateway.dart';
import '../domain/session.dart';
import '../domain/sign_up_data.dart';

/// Who is signed in: the session, or null. Starts from the session the
/// account server still holds, so "not loaded yet" never looks like "signed
/// out". From the server it only takes the end of a session (signed out
/// elsewhere, or expired): signing in goes through [signIn], which checks the
/// institution before anyone sees the session.
class SessionCubit extends Cubit<Session?> {
  SessionCubit(this._auth) : super(_auth.current) {
    _ended = _auth.changes().where((session) => session == null).listen(emit);
  }

  final AuthGateway _auth;
  late final StreamSubscription<Session?> _ended;

  /// Signs in with an account of [institutionId]. Throws an [AuthFailure]
  /// when the server refuses, and [WrongInstitution] — after signing out on
  /// the server — when the account belongs to another institution.
  Future<void> signIn({
    required String email,
    required String password,
    required String institutionId,
  }) async {
    final session = await _auth.signIn(email: email, password: password);
    if (session.institutionId != institutionId) {
      await _auth.signOut();
      throw const WrongInstitution();
    }
    emit(session);
  }

  /// Throws an [AuthFailure] when the account server refuses.
  Future<void> signUp(SignUpData data) async {
    emit(await _auth.signUp(data));
  }

  Future<void> signOut() async {
    await _auth.signOut();
    emit(null);
  }

  @override
  Future<void> close() async {
    await _ended.cancel();
    return super.close();
  }
}
