import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:next_widgets_service/next_widgets_service.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../data/hours_repository.dart';
import '../domain/hours.dart';
import 'dashboard_cubit.dart';
import 'hour_category_labels.dart';

/// The student's hours: progress per category.
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DashboardCubit(context.read<HoursRepository>()),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final state = context.watch<DashboardCubit>().state;
    final snapshot = state.snapshot;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenGutter,
        AppSpacing.sm,
        AppSpacing.screenGutter,
        AppSpacing.screenGutter,
      ),
      children: [
        Text(l10n.dashboardTitle, style: theme.textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.lg),
        if (state.failed)
          _LoadError(onRetry: context.read<DashboardCubit>().retry)
        else if (snapshot == null)
          const Center(child: CircularProgressIndicator())
        else ...[
          for (final progress in snapshot.progress) ...[
            _ProgressCard(progress: progress),
            const SizedBox(height: AppSpacing.lg),
          ],
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.dashboardRecentTitle,
                  style: theme.textTheme.titleLarge,
                ),
              ),
              TextButton(
                onPressed: () =>
                    NextSnack.showNextSnack(context, message: l10n.comingSoon),
                child: Text(l10n.dashboardSeeAll),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (snapshot.recent.isEmpty) _EmptyRecent(text: l10n.dashboardEmpty),
          for (final certificate in snapshot.recent) ...[
            _CertificateTile(certificate: certificate),
            const SizedBox(height: AppSpacing.md),
          ],
        ],
      ],
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Column(
      children: [
        Semantics(
          liveRegion: true,
          child: Text(
            l10n.dashboardLoadError,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        OutlinedButton(onPressed: onRetry, child: Text(l10n.retryAction)),
      ],
    );
  }
}

/// White card of the dashboard: large radius and the soft gold shadow.
BoxDecoration _cardDecoration(ColorScheme cs, {double radius = AppRadii.xl}) =>
    BoxDecoration(
      color: cs.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: AppShadows.lg,
    );

/// An icon on a soft gold badge: the brand yellow as an accent.
class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon});

  final IconData icon;

  static const double _size = 44;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ExcludeSemantics(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: cs.primaryContainer.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
        child: SizedBox.square(
          dimension: _size,
          child: Icon(icon, color: cs.onPrimaryContainer),
        ),
      ),
    );
  }
}

/// A short value in a rounded pill: the share of the goal, the hours of a
/// certificate.
class _Pill extends StatelessWidget {
  const _Pill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        child: Text(
          text,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: cs.onPrimaryContainer,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.progress});

  final CategoryProgress progress;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final category = progress.category;
    return DecoratedBox(
      decoration: _cardDecoration(cs),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _IconBadge(icon: category.icon),
                const Spacer(),
                _Pill(text: l10n.dashboardGoalPercent(progress.percent)),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(category.title(l10n), style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.xs),
            Text(
              category.subtitle(l10n),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            // The framework's progress-bar role only accepts a bare number as
            // value, so the bar announces the category and the hours itself.
            Semantics(
              label: category.title(l10n),
              value: l10n.hoursProgressSemantics(progress.hours, progress.goal),
              child: ExcludeSemantics(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  child: LinearProgressIndicator(
                    value: progress.ratio,
                    color: cs.primary,
                    minHeight: AppSpacing.md,
                    backgroundColor: cs.surfaceContainer,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: AppSpacing.sm,
                children: [
                  Text(
                    l10n.hoursAccumulated(progress.hours),
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                  Text(
                    l10n.hoursGoalTotal(progress.goal),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyRecent extends StatelessWidget {
  const _EmptyRecent({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadii.xl),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            Icon(Icons.inbox_outlined, color: cs.onSurfaceVariant),
            const SizedBox(height: AppSpacing.sm),
            Text(
              text,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CertificateTile extends StatelessWidget {
  const _CertificateTile({required this.certificate});

  final ApprovedCertificate certificate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return DecoratedBox(
      decoration: _cardDecoration(cs, radius: AppRadii.lg),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            _IconBadge(icon: certificate.category.icon),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    certificate.title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  Text(
                    certificate.category.title(l10n),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _Pill(text: l10n.certificateHours(certificate.hours)),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: AppSpacing.lg,
                      color: cs.primary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      l10n.certificateApproved,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
