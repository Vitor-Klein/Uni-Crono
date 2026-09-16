import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/remote_config_service.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/utils/url_utils.dart';
import '../../../core/webview/webview_args.dart';

void openRemoteConfigLegalPage(
  BuildContext context, {
  required String remoteConfigKey,
  required String title,
}) {
  final url = RemoteConfigService.get(remoteConfigKey);
  if (url.isEmpty) return;

  // webview_flutter has no web implementation — WebViewController() throws
  // there — so the web target opens the link in a new browser tab instead
  // of pushing the in-app WebViewPage.
  if (kIsWeb) {
    launchExternalUrl(url);
    return;
  }

  context.push(
    AppRoutes.webview,
    extra: WebViewArgs(url: url, title: title),
  );
}
