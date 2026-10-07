import 'package:flutter/material.dart';

import '../../../core/widgets/app_modal.dart';
import '../../../l10n/app_localizations.dart';
import 'settings_sheets.dart';

void showSettingsModal(
  BuildContext context, {
  required bool notificationsEnabled,
  required VoidCallback onNotificationsTap,
}) {
  final l10n = AppLocalizations.of(context)!;
  showAppModal(
    context,
    title: l10n.settingsTitle,
    items: [
      AppModalItem(
        title: l10n.notificationsSheetTitle,
        subtitle: notificationsEnabled ? l10n.enabledLabel : l10n.disabledLabel,
        icon: Icon(
          notificationsEnabled
              ? Icons.notifications_active_outlined
              : Icons.notifications_off_outlined,
          size: 22,
        ),
        onTap: onNotificationsTap,
      ),
      AppModalItem(
        title: l10n.settingsLanguageTitle,
        subtitle: languageName(Localizations.localeOf(context)),
        icon: const Icon(Icons.language_outlined, size: 22),
        onTap: () => openLanguageSheet(context),
      ),
      AppModalItem(
        title: l10n.settingsAccessibilityTitle,
        subtitle: l10n.settingsAccessibilitySubtitle,
        icon: const Icon(Icons.accessibility_new, size: 22),
        onTap: () => openAccessibilitySheet(context),
        showDivider: false,
      ),
    ],
  );
}
