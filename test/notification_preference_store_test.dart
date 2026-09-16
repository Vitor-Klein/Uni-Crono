import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:uni_cronos/features/notifications/data/notification_preference_store.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('defaults notifications to enabled', () async {
    const store = NotificationPreferenceStore();

    expect(await store.isEnabled(), isTrue);
  });

  test('persists notification preference', () async {
    const store = NotificationPreferenceStore();

    await store.setEnabled(false);

    expect(await store.isEnabled(), isFalse);
  });
}
