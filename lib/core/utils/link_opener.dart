import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens a link outside the app.
abstract class LinkOpener {
  Future<void> open(Uri url);
}

/// The system browser.
class ExternalLinkOpener implements LinkOpener {
  const ExternalLinkOpener();

  @override
  Future<void> open(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not open a link');
    }
  }
}
