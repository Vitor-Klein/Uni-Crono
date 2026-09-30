import 'package:flutter_test/flutter_test.dart';

import 'package:uni_cronos/features/notifications/data/notifications_preference.dart';
import 'package:uni_cronos/features/notifications/presentation/notifications_cubit.dart';

class FakeNotificationsPreference implements NotificationsPreference {
  FakeNotificationsPreference({this.enabled = true, this.failWrites = false});

  bool enabled;
  bool failWrites;
  final writes = <bool>[];

  @override
  Future<bool> isEnabled() async => enabled;

  @override
  Future<void> setEnabled(bool value) async {
    writes.add(value);
    if (failWrites) throw Exception('write failed');
    enabled = value;
  }
}

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

  test('CA-05: setting the current value writes nothing', () async {
    final preference = FakeNotificationsPreference();
    final cubit = NotificationsCubit(preference);
    await Future<void>.delayed(Duration.zero);

    await Future.wait([cubit.setEnabled(true), cubit.setEnabled(true)]);

    expect(preference.writes, isEmpty);
  });
}
