import 'package:shared_preferences/shared_preferences.dart';

import 'notification_constants.dart';

class NotificationPreferenceStore {
  const NotificationPreferenceStore();

  Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(NotificationConstants.notificationsPrefKey) ?? true;
  }

  Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(NotificationConstants.notificationsPrefKey, enabled);
  }
}
