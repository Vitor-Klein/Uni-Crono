import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:next_core_service/next_core_service.dart';
import 'package:next_widgets_service/next_widgets_service.dart';

import '../../../core/widgets/app_modal.dart';
import '../../../l10n/app_localizations.dart';

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
        title: l10n.settingsAccessibilityTitle,
        subtitle: l10n.settingsAccessibilitySubtitle,
        icon: const Icon(Icons.accessibility_new, size: 22),
        onTap: () => _openAccessibilitySheet(context),
        showDivider: false,
      ),
    ],
  );
}

void _openAccessibilitySheet(BuildContext context) {
  showAccessibilitySheet(
    context,
    themeCubit: context.read<AppThemeCubit>(),
    includeColorBlindSection: true,
    actions: _buildAccessibilityActions(context),
  );
}

List<AccessibilityAction> _buildAccessibilityActions(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  final themeCubit = context.read<AppThemeCubit>();
  final scaleCubit = context.read<TextScaleCubit>();
  final accessibilityCubit = context.read<AccessibilityCubit>();

  return [
    AccessibilityAction(
      icon: Icons.brightness_6,
      label: l10n.settingsThemeLabel,
      onTap: () {
        final themeState = themeCubit.state;
        showThemeModeSheet(
          context: context,
          semanticsLabel: l10n.settingsThemeSemantics,
          choices: [
            ThemeModeChoice(
              icon: Icons.brightness_auto,
              label: l10n.themeModeSystem,
              selected: themeState.themeModeType == ThemeModeType.system,
              onTap: () {
                Navigator.of(context).pop();
                themeCubit.setMode(ThemeModeType.system);
              },
            ),
            ThemeModeChoice(
              icon: Icons.light_mode,
              label: l10n.themeModeLight,
              selected: themeState.themeModeType == ThemeModeType.light,
              onTap: () {
                Navigator.of(context).pop();
                themeCubit.setMode(ThemeModeType.light);
              },
            ),
            ThemeModeChoice(
              icon: Icons.dark_mode,
              label: l10n.themeModeDark,
              selected: themeState.themeModeType == ThemeModeType.dark,
              onTap: () {
                Navigator.of(context).pop();
                themeCubit.setMode(ThemeModeType.dark);
              },
            ),
          ],
        );
      },
    ),
    AccessibilityAction(
      icon: Icons.text_fields,
      label: l10n.settingsTextSizeLabel,
      onTap: () {
        final scaleState = scaleCubit.state;
        final deviceFactor = MediaQuery.of(context).textScaler.scale(1.0);
        final currentLevel = scaleState.resolveLevel(deviceFactor);
        showTextScaleSheet(
          context: context,
          semanticsLabel: l10n.settingsTextSizeSemantics,
          choices: [
            TextScaleChoice(
              icon: Icons.phonelink_setup,
              label: l10n.textScaleDevice,
              selected: scaleState.followsDeviceSetting,
              onTap: () {
                Navigator.of(context).pop();
                scaleCubit.followDeviceSetting();
              },
            ),
            TextScaleChoice(
              icon: Icons.text_decrease,
              label: l10n.textScaleSmall,
              selected:
                  !scaleState.followsDeviceSetting &&
                  currentLevel == TextScaleLevel.small,
              onTap: () {
                Navigator.of(context).pop();
                scaleCubit.setLevel(TextScaleLevel.small);
              },
            ),
            TextScaleChoice(
              icon: Icons.text_fields,
              label: l10n.textScaleMedium,
              selected:
                  !scaleState.followsDeviceSetting &&
                  currentLevel == TextScaleLevel.medium,
              onTap: () {
                Navigator.of(context).pop();
                scaleCubit.setLevel(TextScaleLevel.medium);
              },
            ),
            TextScaleChoice(
              icon: Icons.text_increase,
              label: l10n.textScaleLarge,
              selected:
                  !scaleState.followsDeviceSetting &&
                  currentLevel == TextScaleLevel.large,
              onTap: () {
                Navigator.of(context).pop();
                scaleCubit.setLevel(TextScaleLevel.large);
              },
            ),
          ],
        );
      },
    ),
    AccessibilityAction(
      icon: Icons.animation,
      label: l10n.settingsEffectsLabel,
      onTap: () {
        final currentPref = accessibilityCubit.state;
        showEffectsSheet(
          context: context,
          semanticsLabel: l10n.settingsEffectsSemantics,
          choices: [
            AnimationPreferenceChoice(
              icon: Icons.tune,
              label: l10n.animationPreferenceSystem,
              selected: currentPref == AnimationPreference.system,
              onTap: () {
                Navigator.of(context).pop();
                accessibilityCubit.setPreference(AnimationPreference.system);
              },
            ),
            AnimationPreferenceChoice(
              icon: Icons.animation,
              label: l10n.animationPreferenceNormal,
              selected: currentPref == AnimationPreference.normal,
              onTap: () {
                Navigator.of(context).pop();
                accessibilityCubit.setPreference(AnimationPreference.normal);
              },
            ),
            AnimationPreferenceChoice(
              icon: Icons.motion_photos_off,
              label: l10n.animationPreferenceReduced,
              selected: currentPref == AnimationPreference.reduced,
              onTap: () {
                Navigator.of(context).pop();
                accessibilityCubit.setPreference(AnimationPreference.reduced);
              },
            ),
          ],
        );
      },
    ),
  ];
}
