import 'package:flutter/material.dart';
import 'package:next_widgets_service/next_widgets_service.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../l10n/app_localizations.dart';

/// In-app browser page built around [WebViewWidget]. Reached via the
/// `/webview` go_router route (see `AppRouter.build`), not constructed
/// directly.
///
/// Usage:
/// ```dart
/// context.push(
///   AppRoutes.webview,
///   extra: const WebViewArgs(url: 'https://example.com', title: 'Contact'),
/// );
/// ```
class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key, required this.url, this.title = ''});

  final String url;
  final String title;

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController _controller;

  bool _loading = true;
  bool _hasError = false;
  bool _bannerVisible = true;

  /// Fallback chain for the app bar title: explicit [WebViewPage.title]
  /// first, then the URL host, then the raw [WebViewPage.url] for edge
  /// cases without a host (e.g. `data:`/`file:` URLs).
  String get _title {
    if (widget.title.isNotEmpty) return widget.title;
    final host = Uri.tryParse(widget.url)?.host ?? '';
    return host.isNotEmpty ? host : widget.url;
  }

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() {
            _loading = true;
            _hasError = false;
          }),
          onPageFinished: (_) => setState(() => _loading = false),
          onWebResourceError: (error) {
            if (error.isForMainFrame == false) return; // sub-resource: ignore
            setState(() {
              _loading = false;
              _hasError = true;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: NextAppBar(title: _title),
      body: Column(
        children: [
          if (_loading && !_hasError)
            const LinearProgressIndicator(minHeight: 2),
          if (_bannerVisible)
            MaterialBanner(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
              content: Text(
                l10n.webViewDeviceDisclaimer,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
              backgroundColor: cs.surfaceContainerHighest,
              actions: [
                TextButton(
                  onPressed: () => setState(() => _bannerVisible = false),
                  child: Text(l10n.webViewDismiss),
                ),
              ],
            ),
          Expanded(
            child: _hasError
                ? _ErrorState(
                    onRetry: () {
                      setState(() => _hasError = false);
                      _controller.reload();
                    },
                  )
                : WebViewWidget(controller: _controller),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 64,
              color: colorScheme.onSurface.withValues(alpha: 0.38),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.webViewErrorTitle,
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.webViewErrorMessage,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.54),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.webViewRetry),
            ),
          ],
        ),
      ),
    );
  }
}
