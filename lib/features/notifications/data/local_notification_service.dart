import 'dart:convert';
import 'dart:ui';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../l10n/app_localizations.dart';
import 'notification_constants.dart';
import 'notification_error_reporter.dart';

class LocalNotificationService {
  LocalNotificationService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  /// Device locale, validated against the app's catalog.
  ///
  /// `AppLocalizations.delegate.load()` **throws** for any locale the catalog
  /// doesn't declare (verified in the generated app: `fr`, `es` and `de`
  /// raise FlutterError). Inside the widget tree this never happens because
  /// MaterialApp only loads delegates whose `isSupported` is true — but this
  /// path runs outside the tree (startup and the FCM background isolate),
  /// where nothing filters. Without this fallback, a device set to French
  /// would lose the entire push initialization, not just the translation.
  static Locale get _catalogLocale {
    final locale = PlatformDispatcher.instance.locale;
    return AppLocalizations.delegate.isSupported(locale)
        ? locale
        : const Locale('en');
  }

  Future<void> initialize() async {
    // Channel registration runs at startup, on the main isolate: locale is
    // available via PlatformDispatcher, but there's no
    // BuildContext (initialize() is called from outside the widget tree) —
    // hence delegate.load(), not AppLocalizations.of(context).
    final l10n = await AppLocalizations.delegate.load(_catalogLocale);

    const androidInit = AndroidInitializationSettings(
      '@drawable/ic_notification',
    );

    final iosInit = DarwinInitializationSettings(
      notificationCategories: [
        DarwinNotificationCategory(
          NotificationConstants.iosCategoryId,
          actions: [
            DarwinNotificationAction.plain(
              NotificationConstants.openLinkActionId,
              l10n.notificationOpenLinkAction,
              options: {DarwinNotificationActionOption.foreground},
            ),
          ],
        ),
      ],
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final init = InitializationSettings(android: androidInit, iOS: iosInit);

    await _plugin.initialize(
      init,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
          _onDidReceiveBackgroundNotificationResponse,
    );

    final channel = AndroidNotificationChannel(
      NotificationConstants.androidChannelId,
      l10n.notificationChannelName,
      description: l10n.notificationChannelDescription,
      importance: Importance.max,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  Future<void> showFromRemoteMessage(RemoteMessage message) async {
    // This method also runs in the FCM background handler (a separate
    // isolate, no BuildContext): it resolves the locale from the platform and
    // loads the catalog via the delegate, same as initialize() above.
    final l10n = await AppLocalizations.delegate.load(_catalogLocale);

    final data = message.data;
    final title =
        message.notification?.title ??
        data['title'] ??
        l10n.notificationFallbackTitle;
    final body = message.notification?.body ?? data['body'] ?? '';
    final link = (data['link'] ?? data['url'] ?? data['deeplink'])?.toString();

    final payload = jsonEncode({
      'id': message.messageId,
      'title': title,
      'body': body,
      'link': link,
    });

    final android = AndroidNotificationDetails(
      NotificationConstants.androidChannelId,
      l10n.notificationChannelName,
      channelDescription: l10n.notificationChannelDescription,
      importance: Importance.max,
      priority: Priority.high,
      category: AndroidNotificationCategory.message,
      actions: [
        if (link != null && link.isNotEmpty)
          AndroidNotificationAction(
            NotificationConstants.openLinkActionId,
            l10n.notificationOpenLinkAction,
            showsUserInterface: true,
            cancelNotification: true,
          ),
      ],
      styleInformation: const BigTextStyleInformation(''),
    );

    const ios = DarwinNotificationDetails(
      categoryIdentifier: NotificationConstants.iosCategoryId,
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      NotificationDetails(android: android, iOS: ios),
      payload: payload,
    );
  }

  static void _onDidReceiveNotificationResponse(NotificationResponse response) {
    _handleNotificationResponse(response);
  }

  @pragma('vm:entry-point')
  static void _onDidReceiveBackgroundNotificationResponse(
    NotificationResponse response,
  ) {
    _handleNotificationResponse(response);
  }

  static Future<void> _handleNotificationResponse(
    NotificationResponse response,
  ) async {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;

    try {
      final map = Map<String, dynamic>.from(jsonDecode(payload));
      final url = (map['link'] ?? map['url'] ?? map['deeplink'])?.toString();
      final actionId = response.actionId;
      final isDefaultTap = actionId == null || actionId.isEmpty;
      final isOpenAction = actionId == NotificationConstants.openLinkActionId;

      if ((isDefaultTap || isOpenAction) && url != null && url.isNotEmpty) {
        final uri = Uri.tryParse(url);
        if (uri != null) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      }
    } catch (e, st) {
      NotificationErrorReporter.report('handleNotificationResponse', e, st);
    }
  }
}
