import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:share_plus/share_plus.dart';

import '../config/remote_config_service.dart';

/// The Remote Config key for the share link on the current platform.
/// Shared with the caller that decides whether the "share" menu item should
/// be visible — its Remote Config URL being empty is exactly what makes
/// [shareApp] a silent no-op, so both need to agree on the same key.
String get shareUrlKey {
  if (kIsWeb) return RemoteConfigKeys.webShareUrl;
  return defaultTargetPlatform == TargetPlatform.iOS
      ? RemoteConfigKeys.iosShareUrl
      : RemoteConfigKeys.androidShareUrl;
}

/// Shares the app download link from Remote Config, using [shareUrlKey] to
/// pick the right platform's URL (web/iOS/Android).
Future<void> shareApp() async {
  HapticFeedback.mediumImpact();
  final String url = RemoteConfigService.get(shareUrlKey);
  if (url.isEmpty) return;
  final String link = url.startsWith('http') ? url : 'https://$url';
  await SharePlus.instance.share(
    ShareParams(text: 'Check out the app! Download now:\n$link'),
  );
}
