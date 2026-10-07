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
    final visible = state.visible;
    return RefreshIndicator(
      onRefresh: cubit.load,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenGutter),
        children: [
          Text(l10n.hubTitle, style: theme.textTheme.displayMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.hubSubtitle,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Semantics(
            label: l10n.hubSearchLabel,
            child: TextField(
              controller: _search,
              onChanged: cubit.setQuery,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: l10n.hubSearchHint,
                prefixIcon: const Icon(Icons.search_outlined),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerLow,
                border: const OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.all(Radius.circular(AppRadii.md)),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final filter in OpportunityFilter.values)
                ChoiceChip(
                  label: Text(_filterLabel(l10n, filter)),
                  selected: state.filter == filter,
                  selectedColor: theme.colorScheme.primaryContainer,
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
    return Card(
      margin: EdgeInsets.zero,
      color: cs.surfaceContainerLowest,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (featured)
            ColoredBox(
              color: cs.surfaceContainer,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: Icon(kindIcon, size: AppSpacing.xxxl, color: cs.primary),
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
                      Icon(kindIcon, color: cs.primary),
                      const SizedBox(width: AppSpacing.sm),
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
                const SizedBox(height: AppSpacing.sm),
                Text(
                  o.title,
                  style: featured
                      ? theme.textTheme.headlineMedium
                      : theme.textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _meta(context, l10n, o),
                  style: theme.textTheme.bodyMedium,
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
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.schedule_outlined, color: cs.primary),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          l10n.hubHours(o.hours),
                          style: theme.textTheme.labelLarge,
                        ),
                      ],
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
