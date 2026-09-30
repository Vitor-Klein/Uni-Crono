import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/notifications_preference.dart';

/// The single owner of "notifications enabled". Starts optimistic (true)
/// until the saved value loads.
class NotificationsCubit extends Cubit<bool> {
  NotificationsCubit(this._preference) : super(true) {
    _load();
  }

  final NotificationsPreference _preference;

  Future<void> _load() async {
    try {
      final enabled = await _preference.isEnabled();
      if (!isClosed) emit(enabled);
    } catch (e) {
      debugPrint('Error loading notification settings: $e');
    }
  }

  /// Switches optimistically and saves. Returns whether it was saved; on
  /// failure the previous value comes back, so the UI never shows a value
  /// that does not exist in storage.
  Future<bool> setEnabled(bool enabled) async {
    if (state == enabled) return true;
    final previous = state;
    emit(enabled);
    try {
      await _preference.setEnabled(enabled);
      return true;
    } catch (e) {
      debugPrint('Error updating notification settings: $e');
      if (!isClosed) emit(previous);
      return false;
    }
  }
}
