import 'package:flutter/material.dart';
import 'package:next_core_service/next_core_service.dart';

import '../../../../l10n/app_localizations.dart';
import '../domain/message_repository.dart';

/// Swipe-to-delete + tap-to-open wrapper around [MessageCard] for a single
/// list row. Operates on [StoredPushMessage] identity (`item.id`, compared
/// by `==` — [StoredMessageId]'s persistence handle stays a `data/`-only
/// detail), not on a positional index — the drawer above
/// this widget filters and groups, so a stable positional index isn't
/// available here.
class MessageListItem extends StatelessWidget {
  const MessageListItem({
    super.key,
    required this.item,
    required this.colorScheme,
    required this.textTheme,
    required this.onDelete,
    required this.onTap,
  });

  final StoredPushMessage item;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final void Function(StoredPushMessage item) onDelete;
  final void Function(StoredPushMessage item) onTap;

  @override
  Widget build(BuildContext context) {
    final message = item.message;
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: colorScheme.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(Icons.delete, color: colorScheme.onError),
      ),
      onDismissed: (_) => onDelete(item),
      child: MessageCard(
        title: message.title,
        body: message.body,
        imageUrl: message.imageUrl,
        hasLink: message.link.isNotEmpty,
        read: message.read,
        timestamp: _formatTimestamp(message.timestamp),
        colorScheme: colorScheme,
        textTheme: textTheme,
        onDelete: () => onDelete(item),
        onTap: () => onTap(item),
      ),
    );
  }
}

String _formatTimestamp(DateTime dt) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(dt.day)}/${two(dt.month)}/${dt.year} ${two(dt.hour)}:${two(dt.minute)}';
}

class MessageCard extends StatelessWidget {
  const MessageCard({
    super.key,
    required this.title,
    required this.body,
    required this.imageUrl,
    required this.hasLink,
    required this.read,
    required this.timestamp,
    required this.colorScheme,
    required this.textTheme,
    required this.onDelete,
    required this.onTap,
  });

  final String title;
  final String body;
  final String imageUrl;
  final bool hasLink;
  final bool read;
  final String timestamp;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final accent = Theme.of(context).extension<AppColorsExtra>()!.accent1;
    final railColor = read ? Colors.transparent : accent;

    return InkWell(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: railColor, width: 3)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 4, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (imageUrl.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    height: 140,
                    width: double.infinity,
                    errorBuilder: (_, _, _) => Container(
                      height: 80,
                      color: cs.onSurface.withValues(alpha: 0.08),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: cs.onSurface.withValues(alpha: 0.24),
                        size: 32,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      title.isEmpty ? l10n.messageNoTitle : title,
                      style: textTheme.titleSmall?.copyWith(
                        color: cs.onSurface,
                        fontWeight: read ? FontWeight.w600 : FontWeight.w800,
                        height: 1.3,
                      ),
                    ),
                  ),
                  if (hasLink)
                    Padding(
                      padding: const EdgeInsets.only(left: 4, top: 2),
                      child: Icon(
                        Icons.chevron_right_rounded,
                        color: cs.onSurface.withValues(alpha: 0.38),
                        size: 20,
                      ),
                    ),
                  IconButton(
                    tooltip: l10n.messagesDeleteTooltip,
                    onPressed: onDelete,
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.delete_outline, size: 18),
                    color: cs.error,
                  ),
                ],
              ),
              if (body.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  body,
                  style: textTheme.bodyMedium?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.7),
                    height: 1.4,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                timestamp,
                style: textTheme.labelSmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.38),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
