import 'package:shared_preferences/shared_preferences.dart';

import '../domain/email_format.dart';
import '../domain/institution.dart';
import '../domain/session.dart';

/// Where the session of this device is kept.
abstract class SessionRepository {
  Future<Session?> load();
  Future<void> save(Session session);
  Future<void> clear();
}

/// Keeps the session in the device preferences. Only the e-mail and the
/// institution are stored. What is read back is external data: a session whose
/// e-mail is malformed or whose institution is unknown is no session.
class SharedPrefsSessionRepository implements SessionRepository {
  const SharedPrefsSessionRepository();

  static const emailKey = 'session_email';
  static const institutionKey = 'session_institution';

  @override
  Future<Session?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(emailKey);
    final institutionId = prefs.getString(institutionKey);
    if (email == null || !isValidEmail(email)) return null;
    if (institutionId == null || !_isKnownInstitution(institutionId)) {
      return null;
    }
    return Session(email: email, institutionId: institutionId);
  }

  static bool _isKnownInstitution(String id) =>
      Institutions.all.any((institution) => institution.id == id);

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
