import 'package:firebase_messaging/firebase_messaging.dart';

class FirebasePushDataSource {
  FirebasePushDataSource({FirebaseMessaging? messaging})
    : _messaging = messaging ?? FirebaseMessaging.instance;

  final FirebaseMessaging _messaging;

  Stream<RemoteMessage> get onMessage => FirebaseMessaging.onMessage;

  Stream<RemoteMessage> get onMessageOpenedApp =>
      FirebaseMessaging.onMessageOpenedApp;

  Future<void> requestPermission() {
    return _messaging.requestPermission(alert: true, badge: true, sound: true);
  }

  Future<void> subscribeToTopic(String topic) {
    return _messaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) {
    return _messaging.unsubscribeFromTopic(topic);
  }

  Future<String?> getToken() {
    return _messaging.getToken();
  }

  Future<RemoteMessage?> getInitialMessage() {
    return _messaging.getInitialMessage();
  }
}
