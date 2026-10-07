import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/domain/institution.dart';
import '../../auth/presentation/session_cubit.dart';
import '../../notifications/presentation/notifications_cubit.dart';
import '../../notifications/presentation/open_notifications_sheet.dart';
import '../../settings/presentation/settings_sheets.dart';
import '../domain/student_profile.dart';
import 'profile_cubit.dart';

/// The student's card with the summary of their hours, and their settings.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _confirmSignOut(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final session = context.read<SessionCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.profileSignOutTitle),
        content: Text(l10n.profileSignOutBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancelAction),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.profileSignOut),
          ),
        ],
      ),
    );
    if (confirmed ?? false) await session.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final state = context.watch<ProfileCubit>().state;
    final notificationsOn = context.watch<NotificationsCubit>().state;
    // No header on this tab: the page keeps clear of the status bar itself.
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenGutter),
        children: [
          _StudentCard(state: state),
          const SizedBox(height: AppSpacing.xxl),
          _SectionTitle(l10n.profilePreferences),
          _Group(
            children: [
              _SettingsTile(
                icon: notificationsOn
                    ? Icons.notifications_active_outlined
                    : Icons.notifications_off_outlined,
                title: l10n.profileNotifications,
                subtitle: notificationsOn
                    ? l10n.enabledLabel
                    : l10n.disabledLabel,
                onTap: () => openNotificationsSheet(context),
              ),
              _SettingsTile(
                icon: Icons.language_outlined,
                title: l10n.profileLanguage,
                subtitle: languageName(Localizations.localeOf(context)),
                onTap: () => openLanguageSheet(context),
              ),
              _SettingsTile(
                icon: Icons.accessibility_new_outlined,
                title: l10n.profileAccessibility,
                subtitle: l10n.settingsAccessibilitySubtitle,
                onTap: () => openAccessibilitySheet(context),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          _SectionTitle(l10n.profileAccount),
          _Group(
            children: [
              _SettingsTile(
                icon: Icons.logout_outlined,
                title: l10n.profileSignOut,
                color: cs.error,
                badgeColor: cs.errorContainer,
                onTap: () => _confirmSignOut(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// White card on top of the page: who the student is, then the three
/// numbers of their hours.
class _StudentCard extends StatelessWidget {
  const _StudentCard({required this.state});

  final ProfileState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final profile = state.profile;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        boxShadow: AppShadows.lg,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            if (state.failed) ...[
              Semantics(
                liveRegion: true,
                child: Text(
                  l10n.profileLoadError,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              OutlinedButton(
                onPressed: context.read<ProfileCubit>().load,
                child: Text(l10n.retryAction),
              ),
            ] else if (profile == null)
              const Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: CircularProgressIndicator(),
              )
            else
              _Identity(profile: profile),
            const SizedBox(height: AppSpacing.xl),
            Divider(height: 1, color: cs.outlineVariant),
            const SizedBox(height: AppSpacing.lg),
            _Summary(state: state),
          ],
        ),
      ),
    );
  }
}

class _Identity extends StatelessWidget {
  const _Identity({required this.profile});

  final StudentProfile profile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final institution = Institutions.all
        .where((i) => i.id == profile.institutionId)
        .map((i) => i.name)
        .firstOrNull;
    return Column(
      children: [
        CircleAvatar(
          radius: 44,
          backgroundColor: cs.surfaceContainerLow,
          child: Text(
            profile.initials,
            style: theme.textTheme.headlineSmall?.copyWith(color: cs.primary),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          profile.fullName,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(color: cs.onSurface),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          profile.email,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: cs.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        DecoratedBox(
          decoration: BoxDecoration(
            color: cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadii.pill),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.school_outlined,
                  size: AppSpacing.lg,
                  color: cs.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.xs),
                Flexible(
                  child: Text(
                    [
                      ?institution,
                      profile.course,
                      l10n.profileTerm(profile.term),
                    ].join(' · '),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.state});

  final ProfileState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final summary = state.summary;
    String value(String Function(int) format, int? number) =>
        number == null ? '–' : format(number);
    final divider = VerticalDivider(width: 1, color: cs.outlineVariant);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Stat(
            icon: Icons.schedule_outlined,
            value: value(l10n.profileHoursValue, summary?.totalHours),
            label: l10n.profileHoursLabel,
          ),
          divider,
          _Stat(
            icon: Icons.description_outlined,
            value: value((n) => '$n', summary?.certificates),
            label: l10n.profileCertificatesLabel,
          ),
          divider,
          _Stat(
            icon: Icons.flag_outlined,
            value: value(l10n.profileGoalValue, summary?.goalPercent),
            label: l10n.profileGoalLabel,
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.value, required this.label});

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        child: Column(
          children: [
            _IconBadge(icon: icon, size: 36, circle: true),
            const SizedBox(height: AppSpacing.sm),
            Text(
              value,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A white card holding a column of rows, split by thin dividers.
class _Group extends StatelessWidget {
  const _Group({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(AppRadii.xl);
    return DecoratedBox(
      decoration: BoxDecoration(borderRadius: radius, boxShadow: AppShadows.md),
      // The rows' ink paints on this Material, above the card's color.
      child: Material(
        color: cs.surfaceContainerLowest,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            for (final (i, child) in children.indexed) ...[
              if (i > 0)
                Divider(
                  height: 1,
                  indent: AppSpacing.lg + 40 + AppSpacing.lg,
                  color: cs.outlineVariant,
                ),
              child,
            ],
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.color,
    this.badgeColor,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  /// Set for a destructive row (Sair): its icon and title take this color,
  /// and the row has no chevron.
  final Color? color;
  final Color? badgeColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      leading: _IconBadge(
        icon: icon,
        size: 40,
        iconColor: color,
        background: badgeColor,
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: color ?? cs.onSurface,
        ),
      ),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
      trailing: color == null
          ? Icon(Icons.chevron_right_outlined, color: cs.onSurfaceVariant)
          : null,
      onTap: onTap,
    );
  }
}

/// An icon on a soft gold badge: the yellow of the brand as an accent.
class _IconBadge extends StatelessWidget {
  const _IconBadge({
    required this.icon,
    required this.size,
    this.circle = false,
    this.iconColor,
    this.background,
  });

  final IconData icon;
  final double size;
  final bool circle;
  final Color? iconColor;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ExcludeSemantics(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background ?? cs.primaryContainer.withValues(alpha: 0.35),
          shape: circle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: circle ? null : BorderRadius.circular(AppRadii.lg),
        ),
        child: SizedBox.square(
          dimension: size,
          child: Icon(
            icon,
            size: size / 2,
            color: iconColor ?? cs.onPrimaryContainer,
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.xs,
        bottom: AppSpacing.sm,
      ),
      child: Semantics(
        header: true,
        child: Text(
          text,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
