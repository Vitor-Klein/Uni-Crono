import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config/app_config.dart';

import '../core/config/remote_config_service.dart';
import '../core/theme/font_licenses.dart';
import '../features/notifications/messages/data/message_storage.dart';
import '../features/notifications/data/push_service.dart';
import '../firebase_options.dart';
import 'app_providers.dart';

class AppBootstrapResult {
  const AppBootstrapResult({
    required this.firebaseInitialized,
    required this.firebaseWarningMessage,
  });

  final bool firebaseInitialized;
  final String? firebaseWarningMessage;
}

class AppBootstrap {
  const AppBootstrap._();

  static Future<AppBootstrapResult> initialize() async {
    AppThemeBootstrap.ensureConfigured();
    FontLicenses.register();

    var firebaseInitialized = false;
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      firebaseInitialized = true;
    } catch (e, st) {
      debugPrint('Firebase initialization failed: $e');
      if (kDebugMode) debugPrint('$st');
    }

    final firebaseWarningMessage = (kDebugMode && !firebaseInitialized)
        ? 'Aviso (teste): verifique o login do Firebase neste ambiente.'
        : null;

    return AppBootstrapResult(
      firebaseInitialized: firebaseInitialized,
      firebaseWarningMessage: firebaseWarningMessage,
    );
  }

  /// Connects to the account server (Supabase). Must run before runApp: the
  /// saved session has to be known before the first redirect, so "still
  /// loading" never looks like "signed out".
  static Future<void> connectAccountServer() async {
    if (!AppConfig.isConfigured) {
      throw StateError(
        'Supabase is not configured: run with '
        '--dart-define-from-file=config/app.json',
      );
    }
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      publishableKey: AppConfig.supabasePublishableKey,
    );
  }

  static Future<void> runDeferred({required bool firebaseInitialized}) async {
    if (!firebaseInitialized) {
      debugPrint(
        'App started without Firebase. Skipping Remote Config and Push setup.',
      );
      return;
    }

    await _configureRemoteConfig();
    await _configurePush();
  }

  static Future<void> _configureRemoteConfig() async {
    try {
      await RemoteConfigService.configureAndFetch();
    } catch (e, st) {
      debugPrint('RemoteConfig failed: $e');
      if (kDebugMode) debugPrint('$st');
    }
  }

  static Future<void> _configurePush() async {
    try {
      await PushService.I.init();

      final initial = await PushService.I.getInitialMessage();
      if (initial != null) {
        await saveMessageLocally(initial);
      }
    } catch (e, st) {
      debugPrint('PushService.init failed: $e');
      if (kDebugMode) debugPrint('$st');
    }
  }
}
