import 'package:firebase_messaging/firebase_messaging.dart';

import '../domain/message_repository.dart';
import 'remote_message_mapper.dart';
import 'shared_preferences_message_repository.dart';

const MessageRepository _messageRepository =
    SharedPreferencesMessageRepository();

/// Saves a received FCM message to local storage.
///
/// To read or clear stored messages from a new feature, use [MessageRepository]
/// directly (see messages_drawer.dart for the pattern — constructor injection of
/// a `MessageRepository?`), not this file: it only wraps the write path consumed
/// by the push-receive pipeline.
Future<void> saveMessageLocally(RemoteMessage message) async {
  await _messageRepository.saveMessage(pushMessageFromRemoteMessage(message));
}
