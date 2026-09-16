import 'package:firebase_messaging/firebase_messaging.dart';

import '../domain/push_message.dart';

PushMessage pushMessageFromRemoteMessage(
  RemoteMessage message, {
  DateTime? receivedAt,
}) {
  final notification = message.notification;
  final data = message.data;

  return PushMessage(
    title: notification?.title ?? data['title'] ?? '',
    body: notification?.body ?? data['body'] ?? '',
    link: data['link'] ?? data['url'] ?? data['deeplink'] ?? '',
    imageUrl:
        notification?.android?.imageUrl ??
        notification?.apple?.imageUrl ??
        data['imageUrl'] ??
        '',
    timestamp: receivedAt ?? DateTime.now(),
  );
}
