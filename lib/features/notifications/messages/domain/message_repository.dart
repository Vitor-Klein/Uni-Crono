import 'push_message.dart';

/// Opaque identity for a stored message. Wraps the persistence representation
/// so the presentation layer holds an identity, not the raw encoded JSON.
class StoredMessageId {
  const StoredMessageId(this.value);

  /// Handle from the persistence layer. Public because privacy in Dart is
  /// per-library and the `data/` layer needs it; treat it as opaque outside
  /// of `data/`.
  final String value;

  /// Value equality lets the presentation layer compare/locate ids (e.g.
  /// "is this the item the user tapped?") without reaching into [value] —
  /// that stays a `data/`-only detail.
  @override
  bool operator ==(Object other) =>
      other is StoredMessageId && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

class StoredPushMessage {
  const StoredPushMessage({required this.id, required this.message});

  final StoredMessageId id;
  final PushMessage message;
}

abstract class MessageRepository {
  Future<void> saveMessage(PushMessage message);

  Future<List<StoredPushMessage>> loadMessages();

  Future<void> deleteMessage(StoredPushMessage message);

  Future<void> clearMessages();

  Future<StoredPushMessage> markAsRead(StoredPushMessage message);

  Future<void> markAllAsRead();
}
