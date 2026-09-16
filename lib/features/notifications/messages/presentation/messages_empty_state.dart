import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

class MessagesEmptyState extends StatelessWidget {
  const MessagesEmptyState({
    super.key,
    required this.onRefresh,
    this.titleOverride,
    this.messageOverride,
  });

  final Future<void> Function() onRefresh;

  /// Overrides for the filtered-empty case — e.g. the
  /// "Unread" tab has zero items while the inbox as a whole doesn't.
  /// When null, falls back to the generic "no messages at all" copy.
  final String? titleOverride;
  final String? messageOverride;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(14, 20, 14, 12),
        children: [
          const SizedBox(height: 40),
          Icon(
            Icons.notifications_none,
            size: 84,
            color: cs.onSurface.withValues(alpha: 0.38),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              titleOverride ?? l10n.messagesEmptyTitle,
              style: textTheme.titleMedium?.copyWith(color: cs.onSurface),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              messageOverride ?? l10n.messagesEmptyMessage,
              style: textTheme.bodyMedium?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.54),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
