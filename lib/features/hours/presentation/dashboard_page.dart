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
    final snapshot = context.watch<DashboardCubit>().state;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenGutter),
      children: [
        Text(
          l10n.dashboardTitle,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: AppSpacing.xl),
        if (snapshot != null) ...[
          for (final progress in snapshot.progress) ...[
            _ProgressCard(progress: progress),
            const SizedBox(height: AppSpacing.lg),
          ],
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.dashboardRecentTitle,
                  style: Theme.of(context).textTheme.titleLarge,
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
          for (final certificate in snapshot.recent) ...[
            _CertificateTile(certificate: certificate),
            const SizedBox(height: AppSpacing.md),
          ],
        ],
      ],
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
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadii.md),
        boxShadow: AppShadows.sm,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    category.title(l10n),
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                Icon(category.icon, color: cs.primary),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              category.subtitle(l10n),
              style: theme.textTheme.bodyLarge?.copyWith(
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
                    minHeight: AppSpacing.sm,
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
                    ),
                  ),
                  Text(
                    l10n.hoursGoalTotal(progress.goal),
                    style: theme.textTheme.labelLarge,
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

class _CertificateTile extends StatelessWidget {
  const _CertificateTile({required this.certificate});

  final ApprovedCertificate certificate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadii.md),
        boxShadow: AppShadows.sm,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: cs.surfaceContainer,
              child: Icon(certificate.category.icon, color: cs.primary),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(certificate.title, style: theme.textTheme.titleMedium),
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
                Text(
                  l10n.certificateHours(certificate.hours),
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.primary,
                  ),
                ),
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
      ),
    );
  }
}
