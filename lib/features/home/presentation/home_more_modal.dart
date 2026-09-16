import 'package:flutter/material.dart';

import '../../../core/config/remote_config_service.dart';
import '../../../core/utils/share_utils.dart';
import '../../../features/legal/presentation/legal_navigation.dart';
import '../../../features/settings/presentation/settings_modal.dart';
import '../../../core/widgets/app_modal.dart';
import '../../../l10n/app_localizations.dart';
import '../../notifications/messages/presentation/messages_drawer.dart';

void showHomeMoreModal(
  BuildContext context, {
  required bool notificationsEnabled,
  required VoidCallback onNotificationsTap,
  required String appNameLabel,
  required String appVersionLabel,
}) {
  final l10n = AppLocalizations.of(context)!;
  // shareUrlKey (core/utils/share_utils.dart) picks the right platform's
  // Remote Config key — the item must hide under the same condition that
  // makes shareApp() a silent no-op.
  final hasShareUrl = RemoteConfigService.get(shareUrlKey).isNotEmpty;
  final hasPrivacyUrl = RemoteConfigService.get(
    RemoteConfigKeys.privacyPolicyUrl,
  ).isNotEmpty;
  final hasTermsUrl = RemoteConfigService.get(
    RemoteConfigKeys.termsUrl,
  ).isNotEmpty;
  showAppModal(
    context,
    title: l10n.homeMoreButton,
    items: [
      AppModalItem(
        title: l10n.moreMessagesTitle,
        subtitle: l10n.moreMessagesSubtitle,
        icon: const Icon(Icons.chat_bubble_outline_rounded, size: 21),
        onTap: () => openMessagesDrawer(context),
      ),
      AppModalItem(
        title: l10n.moreSettingsTitle,
        subtitle: l10n.moreSettingsSubtitle,
        icon: const Icon(Icons.settings_outlined, size: 22),
        onTap: () => showSettingsModal(
          context,
          notificationsEnabled: notificationsEnabled,
          onNotificationsTap: onNotificationsTap,
        ),
        showDivider: hasShareUrl || hasPrivacyUrl || hasTermsUrl,
      ),
      if (hasShareUrl)
        AppModalItem(
          title: l10n.moreShareTitle,
          subtitle: l10n.moreShareSubtitle,
          icon: const Icon(Icons.ios_share, size: 21),
          onTap: shareApp,
          showDivider: hasPrivacyUrl || hasTermsUrl,
        ),
      if (hasPrivacyUrl)
        AppModalItem(
          title: l10n.morePrivacyTitle,
          subtitle: l10n.morePrivacySubtitle,
          icon: const Icon(Icons.privacy_tip_outlined, size: 22),
          onTap: () => openRemoteConfigLegalPage(
            context,
            remoteConfigKey: RemoteConfigKeys.privacyPolicyUrl,
            title: l10n.legalPrivacyPageTitle,
          ),
          showDivider: hasTermsUrl,
        ),
      if (hasTermsUrl)
        AppModalItem(
          title: l10n.moreTermsTitle,
          subtitle: l10n.moreTermsSubtitle,
          icon: const Icon(Icons.description_outlined, size: 22),
          onTap: () => openRemoteConfigLegalPage(
            context,
            remoteConfigKey: RemoteConfigKeys.termsUrl,
            title: l10n.legalTermsPageTitle,
          ),
          showDivider: false,
        ),
    ],
    footerBuilder: (ctx) {
      final cs = Theme.of(ctx).colorScheme;
      return Column(
        children: [
          Text(
            appNameLabel.toUpperCase(),
            style: Theme.of(ctx).textTheme.labelSmall?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.55),
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            appVersionLabel,
            style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.3),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    },
  );
}
