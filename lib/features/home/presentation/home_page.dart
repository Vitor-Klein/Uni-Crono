import 'package:flutter/material.dart';
import 'package:next_widgets_service/next_widgets_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../l10n/app_localizations.dart';
import '../../notifications/data/push_service.dart';
import '../../notifications/presentation/notifications_sheet.dart';
import 'home_more_modal.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _notificationsEnabled = true;
  // Empty until the bundle finishes loading (_loadAppVersion). Preferable to
  // a hardcoded value that could lie about the actually installed version —
  // that was exactly the defect this field replaces.
  String _appVersionLabel = '';

  String get _appNameLabel {
    const raw = 'uni_cronos';
    final parts = raw.split('_').where((part) => part.trim().isNotEmpty);
    return parts
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (!mounted) return;
      setState(() {
        _appVersionLabel = 'v${info.version}+${info.buildNumber}';
      });
    } catch (e) {
      debugPrint('Error loading package info: $e');
    }
  }

  Future<void> _loadNotificationSettings() async {
    try {
      final enabled = await PushService.I.isNotificationsEnabled();
      if (!mounted) return;
      setState(() => _notificationsEnabled = enabled);
    } catch (e) {
      debugPrint('Error loading notification settings: $e');
    }
  }

  Future<bool> _setNotificationsEnabled(bool enabled) async {
    if (_notificationsEnabled == enabled) return _notificationsEnabled;
    setState(() => _notificationsEnabled = enabled);
    final l10n = AppLocalizations.of(context)!;

    try {
      await PushService.I.setNotificationsEnabled(enabled);
      if (!mounted) return _notificationsEnabled;
      NextSnack.showNextSnack(
        context,
        message: enabled
            ? l10n.notificationsEnabledMessage
            : l10n.notificationsDisabledMessage,
      );
    } catch (e) {
      debugPrint('Error updating notification settings: $e');
      // The optimistic swap made before the try wasn't persisted: revert it,
      // otherwise the UI ends up showing a value that doesn't exist in storage.
      if (!mounted) {
        _notificationsEnabled = !enabled;
        return _notificationsEnabled;
      }
      setState(() => _notificationsEnabled = !enabled);
      NextSnack.showNextSnack(context, message: l10n.notificationsUpdateError);
    }

    return _notificationsEnabled;
  }

  void _showNotificationsModal() {
    showNotificationsSheet(
      context,
      enabled: _notificationsEnabled,
      onChanged: _setNotificationsEnabled,
    );
  }

  void _showMoreModal() {
    showHomeMoreModal(
      context,
      notificationsEnabled: _notificationsEnabled,
      onNotificationsTap: _showNotificationsModal,
      appNameLabel: _appNameLabel,
      appVersionLabel: _appVersionLabel,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: NextAppBar(title: _appNameLabel, showLeading: false),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              onPressed: _showMoreModal,
              icon: const Icon(Icons.menu_rounded),
              label: Text(l10n.homeMoreButton),
            ),
          ],
        ),
      ),
    );
  }
}
