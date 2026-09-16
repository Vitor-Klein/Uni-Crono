import 'package:flutter/material.dart';
import 'package:next_core_service/next_core_service.dart';

import '../../../../l10n/app_localizations.dart';

enum MessageFilter { all, unread }

/// Header row (title + mark-all-read/clear-all/close) plus the
/// "All"/"Unread · N" filter tabs, shown only once there are messages.
///
/// Named `MessagesDrawerHeader`, not `DrawerHeader` — that name collides
/// with Flutter's own `Drawer`-side-nav widget in `package:flutter/material.dart`.
class MessagesDrawerHeader extends StatelessWidget {
  const MessagesDrawerHeader({
    super.key,
    required this.title,
    required this.hasMessages,
    required this.unreadCount,
    required this.filter,
    required this.onFilterChanged,
    required this.onClearAll,
    required this.onMarkAllAsRead,
  });

  final String? title;
  final bool hasMessages;
  final int unreadCount;
  final MessageFilter filter;
  final void Function(MessageFilter filter) onFilterChanged;
  final VoidCallback onClearAll;
  final VoidCallback onMarkAllAsRead;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title ?? l10n.messagesTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              if (unreadCount > 0)
                IconButton(
                  tooltip: l10n.messagesMarkAllReadTooltip,
                  visualDensity: VisualDensity.compact,
                  onPressed: onMarkAllAsRead,
                  icon: Icon(Icons.done_all, color: cs.onSurface),
                ),
              if (hasMessages)
                IconButton(
                  tooltip: l10n.messagesClearAllTooltip,
                  visualDensity: VisualDensity.compact,
                  onPressed: onClearAll,
                  icon: Icon(Icons.delete_forever, color: cs.error),
                ),
              IconButton(
                tooltip: l10n.messagesCloseTooltip,
                visualDensity: VisualDensity.compact,
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close, color: cs.onSurface),
              ),
            ],
          ),
          if (hasMessages) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                _FilterChip(
                  label: l10n.messagesFilterAll,
                  selected: filter == MessageFilter.all,
                  onTap: () => onFilterChanged(MessageFilter.all),
                ),
                const SizedBox(width: 6),
                _FilterChip(
                  label: '${l10n.messagesFilterUnread} · $unreadCount',
                  selected: filter == MessageFilter.unread,
                  onTap: () => onFilterChanged(MessageFilter.unread),
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],
        ],
      ),
    );
  }
}

/// Selected state uses a border + font weight, never a filled `accent1`
/// background — `accent1` has no locked contrast pair in this theme (only
/// `primaryColor`×`primaryBackgroundColor`/`surfaceColor` are), and using it
/// as a fill risks repeating a near-invisible-CTA bug.
class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final accent = Theme.of(context).extension<AppColorsExtra>()!.accent1;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        constraints: const BoxConstraints(minHeight: 40),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: cs.onSurface.withValues(alpha: selected ? 0.12 : 0.05),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? accent : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: cs.onSurface,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
