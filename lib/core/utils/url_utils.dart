import 'package:flutter/foundation.dart' show debugPrint;
import 'package:url_launcher/url_launcher.dart';

/// Launches [url] in the external browser.
/// Prepends "https://" if no scheme is present.
Future<void> launchExternalUrl(String url) async {
  if (url.isEmpty) return;
  final uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    debugPrint('Could not launch $url');
  }
}
