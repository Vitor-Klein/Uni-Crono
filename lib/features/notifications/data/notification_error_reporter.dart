import 'dart:async';

import 'package:flutter/foundation.dart';

class NotificationErrorReporter {
  NotificationErrorReporter._();

  static final List<String> _pendingDevFirebaseErrors = <String>[];
  static final StreamController<String> _devFirebaseErrorController =
      StreamController<String>.broadcast();

  static Stream<String> get devFirebaseErrorStream =>
      _devFirebaseErrorController.stream;

  static List<String> takePendingDevFirebaseErrors() {
    final pending = List<String>.from(_pendingDevFirebaseErrors);
    _pendingDevFirebaseErrors.clear();
    return pending;
  }

  static void report(String stage, Object error, [StackTrace? stackTrace]) {
    final message = 'Push/Firebase error [$stage]: $error';
    debugPrint('Push/Firebase: $message');
    if (kDebugMode) {
      _pendingDevFirebaseErrors.add(message);
      _devFirebaseErrorController.add(message);
      if (stackTrace != null) debugPrint('$stackTrace');
    }
  }
}
