import '../domain/session.dart';
import '../domain/sign_up_data.dart';

/// Why signing in or up did not work.
sealed class AuthFailure implements Exception {
  const AuthFailure();
}

class InvalidCredentials extends AuthFailure {
  const InvalidCredentials();
}

class EmailAlreadyRegistered extends AuthFailure {
  const EmailAlreadyRegistered();
}

/// The account belongs to another institution than the one chosen.
class WrongInstitution extends AuthFailure {
  const WrongInstitution();
}

/// The account exists but the e-mail still has to be confirmed.
class ConfirmationRequired extends AuthFailure {
  const ConfirmationRequired();
}

/// No network, or the server did not answer.
class NetworkFailure extends AuthFailure {
  const NetworkFailure();
}

/// The student's account on the server.
abstract class AuthGateway {
  /// The session kept on this device, if it is still valid.
  Session? get current;

  /// Every change of session after this call: sign-in, sign-out, a session
  /// that expired and could not be renewed (null).
  Stream<Session?> changes();

  Future<Session> signIn({required String email, required String password});

  Future<Session> signUp(SignUpData data);

  Future<void> signOut();
}
