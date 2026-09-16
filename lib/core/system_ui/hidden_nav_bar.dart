import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Hides the system navigation bar while [child] is on screen, keeping the
/// status bar (clock, battery, signal) visible.
///
/// Restores `SystemUiMode.edgeToEdge` on dispose — that is the app-wide mode
/// and the one Android 15 (API 35) mandates. Restoring to `manual` with both
/// overlays would take the app out of edge-to-edge and shift every layout.
///
/// Tracks how many instances are currently mounted (found in device QA):
/// during a route transition, the incoming screen's `initState` runs before
/// the outgoing screen's `dispose` — both are in the tree during the
/// animation. Two consecutive routes that both hide the bar (e.g. splash →
/// upgrade-required) would otherwise flash the bar back, because the
/// outgoing screen's dispose restored `edgeToEdge` after the incoming
/// screen already asked for `manual`. Restoring only when the count reaches
/// zero — no other `HiddenNavBar` still wants the bar hidden — fixes that.
///
/// Limitations, on purpose:
/// - iOS has no navigation bar, so this is a no-op there.
/// - This is not kiosk mode: an edge swipe brings the bar back.
/// - The counter tracks *how many instances are mounted*, not *whether the
///   current top route wants the bar hidden*. It's correct for every
///   transition this app produces today (a bar-hiding route is always
///   either replaced by another bar-hiding route, or by a route that never
///   uses this widget). If a future route ever pushes a bar-*visible*
///   screen on top of one that's still mounted with `HiddenNavBar` (e.g. a
///   kept-alive route underneath), the count would stay above zero and the
///   bar would wrongly stay hidden — a `NavigatorObserver` keyed off the
///   top route would be the general fix, not needed for the current
///   3-route usage (splash, upgrade-required, webview).
class HiddenNavBar extends StatefulWidget {
  const HiddenNavBar({required this.child, super.key});

  final Widget child;

  @override
  State<HiddenNavBar> createState() => _HiddenNavBarState();
}

class _HiddenNavBarState extends State<HiddenNavBar> {
  static int _activeCount = 0;

  @override
  void initState() {
    super.initState();
    _activeCount++;
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: const [SystemUiOverlay.top],
    );
  }

  @override
  void dispose() {
    _activeCount--;
    if (_activeCount <= 0) {
      _activeCount = 0;
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
