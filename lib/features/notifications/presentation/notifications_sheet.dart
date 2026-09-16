import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

Future<void> showNotificationsSheet(
  BuildContext context, {
  required bool enabled,
  required Future<bool> Function(bool enabled) onChanged,
}) {
  var localEnabled = enabled;

  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) {
      final cs = Theme.of(ctx).colorScheme;
      final l10n = AppLocalizations.of(ctx)!;

      Future<void> toggle(
        bool value,
        void Function(void Function()) setModalState,
      ) async {
        if (localEnabled == value) return;
        setModalState(() => localEnabled = value);

        final updated = await onChanged(value);
        if (!ctx.mounted) return;
        setModalState(() => localEnabled = updated);
      }

      return StatefulBuilder(
        builder: (ctx, setModalState) {
          return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              decoration: BoxDecoration(
                color: cs.surface.withValues(alpha: 0.95),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                border: Border.all(
                  color: cs.outline.withValues(alpha: 0.12),
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 8, bottom: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: cs.onSurface.withValues(alpha: 0.24),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Text(
                    l10n.notificationsSheetTitle,
                    style: Theme.of(ctx).textTheme.labelSmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.54),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 3.0,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 16,
                    ),
                    leading: Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: cs.onSurface.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        localEnabled
                            ? Icons.notifications_active_outlined
                            : Icons.notifications_off_outlined,
                        color: cs.onSurface,
                        size: 22,
                      ),
                    ),
                    title: Text(
                      l10n.pushNotificationsLabel,
                      style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                        color: cs.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      localEnabled ? l10n.enabledLabel : l10n.disabledLabel,
                      style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                    trailing: Theme(
                      // Merge over the global switchTheme instead of replacing
                      // it: `app/app.dart` puts the accent color on the thumb
                      // and the selected track, and a fresh SwitchThemeData
                      // here would silently drop it.
                      data: Theme.of(ctx).copyWith(
                        switchTheme: Theme.of(ctx).switchTheme.copyWith(
                          trackOutlineColor:
                              WidgetStateProperty.resolveWith<Color?>((states) {
                                if (states.contains(WidgetState.selected)) {
                                  return cs.onPrimary;
                                }
                                return cs.onSurface.withValues(alpha: 0.22);
                              }),
                          trackOutlineWidth:
                              const WidgetStatePropertyAll<double>(1.2),
                        ),
                      ),
                      child: Switch.adaptive(
                        value: localEnabled,
                        onChanged: (value) => toggle(value, setModalState),
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
