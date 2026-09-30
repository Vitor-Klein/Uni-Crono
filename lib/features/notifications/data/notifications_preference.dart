import 'push_service.dart';

/// Where the "notifications enabled" choice is read from and saved to.
abstract class NotificationsPreference {
  Future<bool> isEnabled();
  Future<void> setEnabled(bool enabled);
}

/// The app's preference: the push service's own store and topic setup.
class PushNotificationsPreference implements NotificationsPreference {
  const PushNotificationsPreference();

  @override
  Future<bool> isEnabled() => PushService.I.isNotificationsEnabled();

  @override
  Future<void> setEnabled(bool enabled) =>
      PushService.I.setNotificationsEnabled(enabled);
}
