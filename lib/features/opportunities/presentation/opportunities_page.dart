import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/link_opener.dart';
import '../../../l10n/app_localizations.dart';
import '../../hours/domain/hours.dart';
import '../data/opportunity_repository.dart';
import '../domain/opportunity.dart';
import 'opportunities_cubit.dart';

/// The Hub: courses and events in which the student earns hours.
class OpportunitiesPage extends StatelessWidget {
  const OpportunitiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          OpportunitiesCubit(context.read<OpportunityRepository>()),
      child: const _HubView(),
    );
  }
}

class _HubView extends StatefulWidget {
  const _HubView();

  @override
  State<_HubView> createState() => _HubViewState();
}

class _HubViewState extends State<_HubView> {
  // Owned here, not by the field: the list is lazy and may rebuild it.
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cubit = context.read<OpportunitiesCubit>();
    final state = context.watch<OpportunitiesCubit>().state;
    final cs = theme.colorScheme;
    final visible = state.visible;
    const pill = BorderRadius.all(Radius.circular(AppRadii.pill));
    return RefreshIndicator(
      onRefresh: cubit.load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenGutter,
          AppSpacing.sm,
          AppSpacing.screenGutter,
          AppSpacing.screenGutter,
        ),
        children: [
          Text(l10n.hubTitle, style: theme.textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.hubSubtitle,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          DecoratedBox(
            decoration: const BoxDecoration(
              borderRadius: pill,
              boxShadow: AppShadows.lg,
            ),
            child: Semantics(
              label: l10n.hubSearchLabel,
              child: TextField(
                controller: _search,
                onChanged: cubit.setQuery,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: l10n.hubSearchHint,
                  hintStyle: theme.textTheme.bodyLarge?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(
                      left: AppSpacing.lg,
                      right: AppSpacing.sm,
                    ),
                    child: Icon(Icons.search_outlined, color: cs.primary),
                  ),
                  filled: true,
                  fillColor: cs.surfaceContainerLowest,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.lg,
                  ),
                  border: const OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: pill,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: cs.outlineVariant),
                    borderRadius: pill,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: cs.primary, width: 2),
                    borderRadius: pill,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final filter in OpportunityFilter.values)
                ChoiceChip(
                  label: Text(_filterLabel(l10n, filter)),
                  selected: state.filter == filter,
                  selectedColor: cs.primaryContainer,
                  backgroundColor: cs.surfaceContainerLowest,
                  side: state.filter == filter
                      ? BorderSide.none
                      : BorderSide(color: cs.outlineVariant),
                  shape: const StadiumBorder(),
                  labelStyle: theme.textTheme.labelLarge?.copyWith(
                    color: state.filter == filter
                        ? cs.onPrimaryContainer
                        : cs.onSurfaceVariant,
                  ),
                  showCheckmark: false,
                  onSelected: (_) => cubit.setFilter(filter),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          if (state.failed)
            _LoadError(
              message: l10n.hubLoadError,
              retry: l10n.retryAction,
              onRetry: cubit.load,
            )
          else if (state.all == null)
            const Center(child: CircularProgressIndicator())
          else if (visible.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: Text(
                l10n.hubEmpty,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge,
              ),
            )
          else
            for (final opportunity in visible) ...[
              _OpportunityCard(opportunity: opportunity),
              const SizedBox(height: AppSpacing.lg),
            ],
        ],
      ),
    );
  }

  static String _filterLabel(AppLocalizations l10n, OpportunityFilter f) =>
      switch (f) {
        OpportunityFilter.all => l10n.hubFilterAll,
        OpportunityFilter.courses => l10n.hubFilterCourses,
        OpportunityFilter.events => l10n.hubFilterEvents,
        OpportunityFilter.extension => l10n.hubFilterExtension,
        OpportunityFilter.complementary => l10n.hubFilterComplementary,
      };
}

/// An icon on a soft gold badge: the brand yellow as an accent.
class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon, this.size = 44});

  final IconData icon;
  final double size;

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
          dimension: size,
          child: Icon(icon, size: size / 2, color: cs.onPrimaryContainer),
        ),
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({
    required this.message,
    required this.retry,
    required this.onRetry,
  });

  final String message;
  final String retry;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Semantics(
          liveRegion: true,
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        OutlinedButton(onPressed: onRetry, child: Text(retry)),
      ],
    );
  }
}

class _OpportunityCard extends StatelessWidget {
  const _OpportunityCard({required this.opportunity});

  final Opportunity opportunity;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final o = opportunity;
    final url = o.url;
    final featured = o.featured;
    final kindIcon = o.kind == OpportunityKind.course
        ? Icons.menu_book_outlined
        : Icons.event_outlined;
    void signUp() => context.read<LinkOpener>().open(url!);
    final radius = BorderRadius.circular(AppRadii.xl);
    return DecoratedBox(
      decoration: BoxDecoration(borderRadius: radius, boxShadow: AppShadows.lg),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        color: cs.surfaceContainerLowest,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: radius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (featured)
              ColoredBox(
                color: cs.primaryContainer.withValues(alpha: 0.2),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  child: Icon(
                    kindIcon,
                    size: AppSpacing.xxxl,
                    color: cs.onPrimaryContainer,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (!featured) ...[
                        _IconBadge(icon: kindIcon, size: 36),
                        const SizedBox(width: AppSpacing.md),
                      ],
                      Expanded(
                        child: Text(
                          _tag(l10n, o).toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    o.title,
                    style: featured
                        ? theme.textTheme.headlineSmall
                        : theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _meta(context, l10n, o),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(o.description, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: AppSpacing.lg),
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      DecoratedBox(
                        key: const ValueKey('hub-hours-pill'),
                        decoration: BoxDecoration(
                          color: cs.primaryContainer.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(AppRadii.pill),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.schedule_outlined,
                                size: AppSpacing.lg + AppSpacing.xs,
                                color: cs.onPrimaryContainer,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                l10n.hubHours(o.hours),
                                style: theme.textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: cs.onPrimaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (url != null)
                        featured
                            ? FilledButton(
                                onPressed: signUp,
                                child: Text(l10n.hubSignUp),
                              )
                            : OutlinedButton(
                                onPressed: signUp,
                                child: Text(l10n.hubSignUp),
                              ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _tag(AppLocalizations l10n, Opportunity o) {
    final kind = o.kind == OpportunityKind.course
        ? l10n.hubKindCourse
        : l10n.hubKindEvent;
    final category = o.category == HourCategory.extension
        ? l10n.hubFilterExtension
        : l10n.hubFilterComplementary;
    return '$kind · $category';
  }

  static String _meta(
    BuildContext context,
    AppLocalizations l10n,
    Opportunity o,
  ) {
    final modality = switch (o.modality) {
      Modality.online => l10n.hubModalityOnline,
      Modality.presencial => l10n.hubModalityPresencial,
      Modality.hibrido => l10n.hubModalityHibrido,
    };
    final startsAt = o.startsAt;
    final locale = Localizations.localeOf(context).toLanguageTag();
    return [
      o.provider,
      if (startsAt != null) DateFormat.MMMd(locale).format(startsAt),
      modality,
    ].join(' · ');
  }
}
