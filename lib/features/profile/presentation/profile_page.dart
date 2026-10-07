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

/// The student's card, the summary of their hours and their settings.
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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final state = context.watch<ProfileCubit>().state;
    final notificationsOn = context.watch<NotificationsCubit>().state;
    final profile = state.profile;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenGutter),
      children: [
        if (state.failed)
          Column(
            children: [
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
            ],
          )
        else if (profile == null)
          const Center(child: CircularProgressIndicator())
        else
          _StudentCard(profile: profile),
        const SizedBox(height: AppSpacing.xl),
        _Summary(state: state),
        const SizedBox(height: AppSpacing.xl),
        _SectionTitle(l10n.profilePreferences),
        ListTile(
          leading: Icon(
            notificationsOn
                ? Icons.notifications_active_outlined
                : Icons.notifications_off_outlined,
          ),
          title: Text(l10n.profileNotifications),
          subtitle: Text(
            notificationsOn ? l10n.enabledLabel : l10n.disabledLabel,
          ),
          onTap: () => openNotificationsSheet(context),
        ),
        ListTile(
          leading: const Icon(Icons.language_outlined),
          title: Text(l10n.profileLanguage),
          subtitle: Text(languageName(Localizations.localeOf(context))),
          onTap: () => openLanguageSheet(context),
        ),
        ListTile(
          leading: const Icon(Icons.accessibility_new_outlined),
          title: Text(l10n.profileAccessibility),
          subtitle: Text(l10n.settingsAccessibilitySubtitle),
          onTap: () => openAccessibilitySheet(context),
        ),
        const SizedBox(height: AppSpacing.lg),
        _SectionTitle(l10n.profileAccount),
        ListTile(
          leading: Icon(Icons.logout_outlined, color: cs.error),
          title: Text(
            l10n.profileSignOut,
            style: theme.textTheme.titleMedium?.copyWith(color: cs.error),
          ),
          onTap: () => _confirmSignOut(context),
        ),
      ],
    );
  }
}

class _StudentCard extends StatelessWidget {
  const _StudentCard({required this.profile});

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
    final onCard = cs.onPrimaryContainer;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        boxShadow: AppShadows.md,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: cs.surfaceContainerLowest,
              child: Text(
                profile.initials,
                style: theme.textTheme.titleLarge?.copyWith(color: cs.primary),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              profile.fullName,
              style: theme.textTheme.headlineSmall?.copyWith(color: onCard),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              profile.email,
              style: theme.textTheme.bodyMedium?.copyWith(color: onCard),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              [
                ?institution,
                profile.course,
                l10n.profileTerm(profile.term),
              ].join(' · '),
              style: theme.textTheme.bodyMedium?.copyWith(color: onCard),
            ),
          ],
        ),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.state});

  final ProfileState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final summary = state.summary;
    String value(String Function(int) format, int? number) =>
        number == null ? '–' : format(number);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Stat(
          value: value(l10n.profileHoursValue, summary?.totalHours),
          label: l10n.profileHoursLabel,
        ),
        _Stat(
          value: value((n) => '$n', summary?.certificates),
          label: l10n.profileCertificatesLabel,
        ),
        _Stat(
          value: value(l10n.profileGoalValue, summary?.goalPercent),
          label: l10n.profileGoalLabel,
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
        ],
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
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
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
