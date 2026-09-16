import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../messages/data/message_storage.dart';
import 'firebase_push_data_source.dart';
import 'local_notification_service.dart';
import 'notification_constants.dart';
import 'notification_error_reporter.dart';
import 'notification_preference_store.dart';

class PushNotificationController {
  PushNotificationController({
    FirebasePushDataSource? pushDataSource,
    LocalNotificationService? localNotificationService,
    NotificationPreferenceStore? preferenceStore,
  }) : _pushDataSource = pushDataSource ?? FirebasePushDataSource(),
       _localNotificationService =
           localNotificationService ?? LocalNotificationService(),
       _preferenceStore =
           preferenceStore ?? const NotificationPreferenceStore();

  final FirebasePushDataSource _pushDataSource;
  final LocalNotificationService _localNotificationService;
  final NotificationPreferenceStore _preferenceStore;

  bool _initialized = false;
  bool _notificationsEnabled = true;

  Future<bool> isNotificationsEnabled() {
    return _preferenceStore.isEnabled();
  }

  Future<void> setNotificationsEnabled(
    bool enabled, {
    String topic = NotificationConstants.defaultTopic,
  }) async {
    await _preferenceStore.setEnabled(enabled);
    _notificationsEnabled = enabled;
    unawaited(_applyNotificationPreference(enabled, topic));
  }

  Future<void> init({
    bool requestPermissions = true,
    String? topicToSubscribe = NotificationConstants.defaultTopic,
  }) async {
    try {
      _notificationsEnabled = await isNotificationsEnabled();

      if (_initialized) {
        await _applyStartupPreference(
          requestPermissions: requestPermissions,
          topicToSubscribe: topicToSubscribe,
        );
        return;
      }

      await _localNotificationService.initialize();
      await _applyStartupPreference(
        requestPermissions: requestPermissions,
        topicToSubscribe: topicToSubscribe,
      );
      await _validateToken();
      _listenToForegroundMessages();
      _listenToOpenedMessages();

      _initialized = true;
    } catch (e, st) {
      NotificationErrorReporter.report('init', e, st);
      rethrow;
    }
  }

  Future<String?> getToken() async {
    try {
      return await _pushDataSource.getToken();
    } catch (e, st) {
      NotificationErrorReporter.report('getToken', e, st);
      return null;
    }
  }

  Future<RemoteMessage?> getInitialMessage() {
    return _pushDataSource.getInitialMessage();
  }

  Future<void> showLocalNotificationFromMessage(RemoteMessage message) async {
    try {
      if (!_notificationsEnabled) return;
      await _localNotificationService.showFromRemoteMessage(message);
    } catch (e, st) {
      NotificationErrorReporter.report(
        'showLocalNotificationFromMessage',
        e,
        st,
      );
    }
  }

  Future<void> _applyStartupPreference({
    required bool requestPermissions,
    required String? topicToSubscribe,
  }) async {
    if (requestPermissions && _notificationsEnabled) {
      await _pushDataSource.requestPermission();
    }

    if (topicToSubscribe != null && topicToSubscribe.isNotEmpty) {
      if (_notificationsEnabled) {
        await _pushDataSource.subscribeToTopic(topicToSubscribe);
      } else {
        await _pushDataSource.unsubscribeFromTopic(topicToSubscribe);
      }
    }
  }

  Future<void> _applyNotificationPreference(bool enabled, String topic) async {
    try {
      if (enabled) {
        await _pushDataSource.requestPermission();
      }
      if (topic.isNotEmpty) {
        if (enabled) {
          await _pushDataSource.subscribeToTopic(topic);
        } else {
          await _pushDataSource.unsubscribeFromTopic(topic);
        }
      }
    } catch (e, st) {
      NotificationErrorReporter.report('setNotificationsEnabled', e, st);
    }
  }

  Future<void> _validateToken() async {
    final token = await _pushDataSource.getToken();
    if (kDebugMode && (token == null || token.isEmpty)) {
      NotificationErrorReporter.report(
        'init.getToken',
        'FCM token vazio: app pode não estar registrado no Firebase Console.',
      );
    }
  }

  void _listenToForegroundMessages() {
    _pushDataSource.onMessage.listen(
      (message) async {
        try {
          if (!_notificationsEnabled) return;
          await saveMessageLocally(message);
          await showLocalNotificationFromMessage(message);
        } catch (e, st) {
          NotificationErrorReporter.report('onMessage', e, st);
        }
      },
      onError: (Object error, StackTrace st) {
        NotificationErrorReporter.report('onMessage.listen', error, st);
      },
    );
  }

  void _listenToOpenedMessages() {
    _pushDataSource.onMessageOpenedApp.listen(
      (message) async {
        try {
          if (!_notificationsEnabled) return;
          await saveMessageLocally(message);
        } catch (e, st) {
          NotificationErrorReporter.report('onMessageOpenedApp', e, st);
        }
      },
      onError: (Object error, StackTrace st) {
        NotificationErrorReporter.report(
          'onMessageOpenedApp.listen',
          error,
          st,
        );
      },
    );
  }
}
