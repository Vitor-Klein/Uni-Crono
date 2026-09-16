import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:uni_cronos/features/notifications/messages/data/shared_preferences_message_repository.dart';
import 'package:uni_cronos/features/notifications/messages/domain/message_repository.dart';
import 'package:uni_cronos/features/notifications/messages/domain/push_message.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('loads stored messages with the most recent first', () async {
    final older = PushMessage(
      title: 'Older',
      body: 'First message',
      link: '',
      imageUrl: '',
      timestamp: DateTime(2026, 1, 1, 8),
    );
    final newer = PushMessage(
      title: 'Newer',
      body: 'Second message',
      link: '',
      imageUrl: '',
      timestamp: DateTime(2026, 1, 1, 9),
    );

    SharedPreferences.setMockInitialValues({
      SharedPreferencesMessageRepository.storageKey: [
        older.encode(),
        newer.encode(),
      ],
    });

    const repository = SharedPreferencesMessageRepository();
    final messages = await repository.loadMessages();

    expect(messages, hasLength(2));
    expect(messages.first.message.title, 'Newer');
    expect(messages.last.message.title, 'Older');
  });

  test('deletes and clears stored messages', () async {
    final message = PushMessage(
      title: 'Title',
      body: 'Body',
      link: '',
      imageUrl: '',
      timestamp: DateTime(2026, 1, 1),
    );
    final stored = StoredPushMessage(
      id: StoredMessageId(message.encode()),
      message: message,
    );

    SharedPreferences.setMockInitialValues({
      SharedPreferencesMessageRepository.storageKey: [stored.id.value],
    });

    const repository = SharedPreferencesMessageRepository();
    await repository.deleteMessage(stored);

    expect(await repository.loadMessages(), isEmpty);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(SharedPreferencesMessageRepository.storageKey, [
      stored.id.value,
    ]);

    await repository.clearMessages();

    expect(await repository.loadMessages(), isEmpty);
  });
}
