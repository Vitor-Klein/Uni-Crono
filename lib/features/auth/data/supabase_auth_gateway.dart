import 'package:supabase_flutter/supabase_flutter.dart' hide Session;

import '../domain/institution.dart';
import '../domain/session.dart';
import '../domain/sign_up_data.dart';
import 'auth_gateway.dart';

/// The student's account in Supabase Auth. The SDK keeps the session on the
/// device and renews it; the institution travels in the account data, so it
/// is known without a request.
class SupabaseAuthGateway implements AuthGateway {
  SupabaseAuthGateway(this._client);

  final SupabaseClient _client;

  GoTrueClient get _auth => _client.auth;

  @override
  Session? get current => _toSession(_auth.currentSession?.user);

  /// The SDK also reports failures (a renewal that did not go through) as
  /// errors on this stream. They are not a change of session: dropped here,
  /// so a listener never breaks on them.
  @override
  Stream<Session?> changes() => _auth.onAuthStateChange
      .map((state) => _toSession(state.session?.user))
      .handleError((Object _) {});

  @override
  Future<Session> signIn({
    required String email,
    required String password,
  }) async {
    final AuthResponse response;
    try {
      response = await _auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on AuthException catch (error) {
      throw _failureOf(error);
    }
    return _require(response.user);
  }

  @override
  Future<Session> signUp(SignUpData data) async {
    final AuthResponse response;
    try {
      response = await _auth.signUp(
        email: data.email,
        password: data.password,
        data: {
          'full_name': data.fullName,
          'institution_id': data.institutionId,
          'course': data.course,
          'term': data.term,
        },
      );
    } on AuthException catch (error) {
      throw _failureOf(error);
    }
    if (response.session == null) throw const ConfirmationRequired();
    return _require(response.user);
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on AuthException {
      // The SDK drops the local session before telling the server: without
      // network the student is signed out all the same.
    }
  }

  /// A session for [user], or a sign-out when the account has no known
  /// institution (it was not created by this app).
  Future<Session> _require(User? user) async {
    final session = _toSession(user);
    if (session != null) return session;
    await signOut();
    throw const WrongInstitution();
  }

  static Session? _toSession(User? user) {
    if (user == null) return null;
    final institutionId = user.userMetadata?['institution_id'];
    final known = Institutions.all.any(
      (institution) => institution.id == institutionId,
    );
    if (!known) return null;
    return Session(
      userId: user.id,
      email: user.email ?? '',
      institutionId: institutionId as String,
    );
  }

  static AuthFailure _failureOf(AuthException error) => switch (error.code) {
    'invalid_credentials' => const InvalidCredentials(),
    'user_already_exists' || 'email_exists' => const EmailAlreadyRegistered(),
    _ when error.statusCode == '400' => const InvalidCredentials(),
    _ => const NetworkFailure(),
  };
}
