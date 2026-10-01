import 'dart:async';

import 'package:flutter/foundation.dart';

/// Turns a stream into a [Listenable], so the router runs its redirect again
/// each time the stream emits.
class StreamListenable extends ChangeNotifier {
  StreamListenable(Stream<Object?> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<Object?> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
