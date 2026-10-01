import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/hours_repository.dart';
import '../domain/hours.dart';

/// The hours the dashboard shows; null until the first snapshot arrives.
class DashboardCubit extends Cubit<HoursSnapshot?> {
  DashboardCubit(HoursRepository repository) : super(null) {
    _subscription = repository.watch().listen(emit);
  }

  late final StreamSubscription<HoursSnapshot> _subscription;

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
