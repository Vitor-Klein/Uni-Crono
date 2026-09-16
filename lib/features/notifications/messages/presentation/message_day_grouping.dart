import 'package:flutter/material.dart' show DateUtils;

import '../domain/message_repository.dart';

/// One day's worth of messages, already labeled for display.
class MessageDayGroup {
  const MessageDayGroup({required this.label, required this.items});

  final String label;
  final List<StoredPushMessage> items;
}

/// Buckets [items] into consecutive same-day groups. Assumes [items] is
/// already sorted most-recent-first (as [MessageRepository.loadMessages]
/// guarantees) — same-day messages are contiguous, so no re-sorting happens
/// here, preserving the caller's order within each group.
List<MessageDayGroup> groupMessagesByDay(
  List<StoredPushMessage> items, {
  required String todayLabel,
  required String yesterdayLabel,
  required String Function(DateTime date) formatOlderDate,
}) {
  final now = DateTime.now();
  final yesterday = now.subtract(const Duration(days: 1));

  String labelFor(DateTime timestamp) {
    if (DateUtils.isSameDay(timestamp, now)) return todayLabel;
    if (DateUtils.isSameDay(timestamp, yesterday)) return yesterdayLabel;
    return formatOlderDate(timestamp);
  }

  final groups = <MessageDayGroup>[];
  String? currentLabel;
  var currentItems = <StoredPushMessage>[];

  for (final item in items) {
    final label = labelFor(item.message.timestamp);
    if (label != currentLabel) {
      if (currentLabel != null) {
        groups.add(MessageDayGroup(label: currentLabel, items: currentItems));
      }
      currentLabel = label;
      currentItems = [];
    }
    currentItems.add(item);
  }
  if (currentLabel != null) {
    groups.add(MessageDayGroup(label: currentLabel, items: currentItems));
  }

  return groups;
}
