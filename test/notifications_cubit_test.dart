import 'package:flutter_test/flutter_test.dart';

import 'package:uni_cronos/features/notifications/presentation/notifications_cubit.dart';

import 'app_harness.dart';

void main() {
  test('CA-05: starts from the saved preference', () async {
    final cubit = NotificationsCubit(
      FakeNotificationsPreference(enabled: false),
    );
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state, isFalse);
  });

  test('CA-05: turning off saves false and reports success', () async {
    final preference = FakeNotificationsPreference();
    final cubit = NotificationsCubit(preference);
    await Future<void>.delayed(Duration.zero);

    final saved = await cubit.setEnabled(false);

    expect(saved, isTrue);
    expect(cubit.state, isFalse);
    expect(preference.writes, [false]);
  });

  test('CA-05: a failed save reverts the value and reports failure', () async {
    final preference = FakeNotificationsPreference(failWrites: true);
    final cubit = NotificationsCubit(preference);
    await Future<void>.delayed(Duration.zero);

    final saved = await cubit.setEnabled(false);

    expect(saved, isFalse);
    expect(cubit.state, isTrue);
  });

  test('CA-05: a quick double tap to the same value writes once', () async {
    final preference = FakeNotificationsPreference();
    final cubit = NotificationsCubit(preference);
    await Future<void>.delayed(Duration.zero);

    await Future.wait([cubit.setEnabled(false), cubit.setEnabled(false)]);

    expect(preference.writes, [false]);
  });
}
