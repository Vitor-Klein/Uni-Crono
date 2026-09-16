import 'package:shared_preferences/shared_preferences.dart';

import '../domain/message_repository.dart';
import '../domain/push_message.dart';

class SharedPreferencesMessageRepository implements MessageRepository {
  const SharedPreferencesMessageRepository();

  static const storageKey = 'push_messages';
  static const maxMessages = 100;

  @override
  Future<void> saveMessage(PushMessage message) async {
    if (!message.hasContent) return;

    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(storageKey) ?? [];

    existing.add(message.encode());
    if (existing.length > maxMessages) {
      existing.removeRange(0, existing.length - maxMessages);
    }

    await prefs.setStringList(storageKey, existing);
  }

  @override
  Future<List<StoredPushMessage>> loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(storageKey) ?? [];

    final parsed = <StoredPushMessage>[];
    for (final encoded in raw) {
      try {
        parsed.add(
          StoredPushMessage(
            id: StoredMessageId(encoded),
            message: PushMessage.fromEncoded(encoded),
          ),
        );
      } catch (_) {
        // Corrupted local entries should not block the inbox.
      }
    }

    parsed.sort((a, b) => b.message.timestamp.compareTo(a.message.timestamp));
    return parsed;
  }

  @override
  Future<void> deleteMessage(StoredPushMessage message) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(storageKey) ?? [];
    raw.remove(message.id.value);
    await prefs.setStringList(storageKey, raw);
  }

  @override
  Future<void> clearMessages() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(storageKey);
  }

  @override
  Future<StoredPushMessage> markAsRead(StoredPushMessage message) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(storageKey) ?? [];

    final updatedMessage = message.message.copyWith(read: true);
    final encoded = updatedMessage.encode();

    final index = raw.indexOf(message.id.value);
    if (index != -1) {
      raw[index] = encoded;
      await prefs.setStringList(storageKey, raw);
    }

    return StoredPushMessage(
      id: StoredMessageId(encoded),
      message: updatedMessage,
    );
  }

  @override
  Future<void> markAllAsRead() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(storageKey) ?? [];

    final updated = raw
        .map(
          (encoded) =>
              PushMessage.fromEncoded(encoded).copyWith(read: true).encode(),
        )
        .toList();

    await prefs.setStringList(storageKey, updated);
  }
}
