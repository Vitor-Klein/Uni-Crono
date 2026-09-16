import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../../firebase_options.dart';
import '../messages/data/message_storage.dart';
import 'notification_constants.dart';
import 'notification_error_reporter.dart';
import 'push_notification_controller.dart';

class PushService {
  PushService({PushNotificationController? controller})
    : _controller = controller ?? PushNotificationController();

  static final PushService I = PushService();

  final PushNotificationController _controller;

  static Stream<String> get devFirebaseErrorStream =>
      NotificationErrorReporter.devFirebaseErrorStream;

  static List<String> takePendingDevFirebaseErrors() {
    return NotificationErrorReporter.takePendingDevFirebaseErrors();
  }

  Future<bool> isNotificationsEnabled() {
    return _controller.isNotificationsEnabled();
  }

  Future<void> setNotificationsEnabled(
    bool enabled, {
    String topic = NotificationConstants.defaultTopic,
  }) {
    return _controller.setNotificationsEnabled(enabled, topic: topic);
  }

  Future<void> init({
    bool requestPermissions = true,
    String? topicToSubscribe = NotificationConstants.defaultTopic,
  }) {
    return _controller.init(
      requestPermissions: requestPermissions,
      topicToSubscribe: topicToSubscribe,
    );
  }

  Future<String?> getToken() {
    return _controller.getToken();
  }

  Future<RemoteMessage?> getInitialMessage() {
    return _controller.getInitialMessage();
  }

  Future<void> showLocalNotificationFromMessage(RemoteMessage message) {
    return _controller.showLocalNotificationFromMessage(message);
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await PushService.I.init(requestPermissions: false, topicToSubscribe: null);
    await saveMessageLocally(message);
    await PushService.I.showLocalNotificationFromMessage(message);
  } catch (e, st) {
    NotificationErrorReporter.report(
      'firebaseMessagingBackgroundHandler',
      e,
      st,
    );
    debugPrint('Background push handling failed: $e');
    if (kDebugMode) debugPrint('$st');
  }
}
