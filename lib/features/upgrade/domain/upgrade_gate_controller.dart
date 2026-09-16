import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:upgrader/upgrader.dart';

const _forceUpgradeGate = bool.fromEnvironment('force_upgrade_gate');

/// Owns the [Upgrader] and exposes its state as a [ChangeNotifier], to
/// feed the GoRouter `redirect`/`refreshListenable` — replaces the old
/// full-screen upgrade gate widget.
class UpgradeGateController extends ChangeNotifier {
  UpgradeGateController({this.enabled = true}) {
    if (enabled) {
      unawaited(_bootstrap());
    }
  }

  final bool enabled;

  late final Upgrader _upgrader = Upgrader(
    debugLogging: kDebugMode,
    debugDisplayAlways: _forceUpgradeGate,
    durationUntilAlertAgain: const Duration(days: 1),
  );

  StreamSubscription<UpgraderState>? _stateSub;

  bool get shouldBlock => enabled && _upgrader.shouldDisplayUpgrade();

  VoidCallback get onUpdate => _upgrader.sendUserToAppStore;

  Future<void> _bootstrap() async {
    _stateSub = _upgrader.stateStream.listen((_) => notifyListeners());
    await _upgrader.initialize();
    if (enabled && _forceUpgradeGate) {
      await _applyDebugFallback();
    }
    notifyListeners();
  }

  Future<void> _applyDebugFallback() async {
    try {
      if (_upgrader.state.versionInfo != null) return;

      final packageInfo = _upgrader.state.packageInfo;
      if (packageInfo == null || packageInfo.version.isEmpty) return;

      final installedVersion = Upgrader.parseVersion(
        packageInfo.version,
        'packageInfo.version',
        kDebugMode,
      );
      if (installedVersion == null) return;

      _upgrader.updateState(
        _upgrader.state.copyWith(
          versionInfo: UpgraderVersionInfo(
            appStoreListingURL:
                'https://play.google.com/store/apps/details?id=${packageInfo.packageName}',
            appStoreVersion: installedVersion,
            installedVersion: installedVersion,
            releaseNotes: 'Debug mode: forced update page for local testing.',
          ),
        ),
      );
    } catch (e, st) {
      debugPrint('Upgrader debug fallback failed: $e');
      debugPrint('$st');
    }
  }

  @override
  void dispose() {
    _stateSub?.cancel();
    super.dispose();
  }
}
