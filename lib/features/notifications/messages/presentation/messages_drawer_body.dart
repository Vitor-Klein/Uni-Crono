import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../domain/message_repository.dart';
import 'message_card.dart';
import 'message_day_grouping.dart';
import 'messages_empty_state.dart';

/// Scrollable list of messages grouped by day, or the loading/empty state.
class MessagesDrawerBody extends StatelessWidget {
  const MessagesDrawerBody({
    super.key,
    required this.loading,
    required this.items,
    required this.hasAnyMessages,
    required this.showingUnreadFilter,
    required this.scrollController,
    required this.onRefresh,
    required this.onDelete,
    required this.onOpen,
  });

  final bool loading;
  final List<StoredPushMessage> items;
  final bool hasAnyMessages;
  final bool showingUnreadFilter;
  final ScrollController scrollController;
  final Future<void> Function() onRefresh;
  final void Function(StoredPushMessage item) onDelete;
  final void Function(StoredPushMessage item) onOpen;

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());

    final l10n = AppLocalizations.of(context)!;

    if (items.isEmpty) {
      if (showingUnreadFilter && hasAnyMessages) {
        return MessagesEmptyState(
          onRefresh: onRefresh,
          titleOverride: l10n.messagesEmptyUnreadTitle,
          messageOverride: l10n.messagesEmptyUnreadMessage,
        );
      }
      return MessagesEmptyState(onRefresh: onRefresh);
    }

    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final dateFormat = DateFormat.yMMMd(
      Localizations.localeOf(context).toString(),
    );

    final groups = groupMessagesByDay(
      items,
      todayLabel: l10n.messagesGroupToday,
      yesterdayLabel: l10n.messagesGroupYesterday,
      formatOlderDate: dateFormat.format,
    );

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
        itemCount: groups.length,
        itemBuilder: (context, groupIndex) {
          final group = groups[groupIndex];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(2, 0, 2, 6),
                  child: Text(
                    group.label,
                    style: textTheme.labelSmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.54),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                ...group.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: MessageListItem(
                      item: item,
                      colorScheme: cs,
                      textTheme: textTheme,
                      onDelete: onDelete,
                      onTap: onOpen,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
