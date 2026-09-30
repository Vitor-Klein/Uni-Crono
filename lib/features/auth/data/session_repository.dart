import 'package:shared_preferences/shared_preferences.dart';

import '../domain/session.dart';

/// Where the session of this device is kept.
abstract class SessionRepository {
  Future<Session?> load();
  Future<void> save(Session session);
  Future<void> clear();
}

/// Keeps the session in the device preferences. Only the e-mail and the
/// institution are stored; a session missing either one is no session.
class SharedPrefsSessionRepository implements SessionRepository {
  const SharedPrefsSessionRepository();

  static const emailKey = 'session_email';
  static const institutionKey = 'session_institution';

  @override
  Future<Session?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(emailKey);
    final institutionId = prefs.getString(institutionKey);
    if (email == null || email.isEmpty) return null;
    if (institutionId == null || institutionId.isEmpty) return null;
    return Session(email: email, institutionId: institutionId);
  }

  @override
  Future<void> save(Session session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(emailKey, session.email);
    await prefs.setString(institutionKey, session.institutionId);
  }

  @override
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(emailKey);
    await prefs.remove(institutionKey);
  }
}
