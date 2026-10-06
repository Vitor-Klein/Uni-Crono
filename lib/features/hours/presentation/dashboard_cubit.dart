import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/hours_repository.dart';
import '../domain/hours.dart';

/// What the dashboard shows: the hours, or that they could not be loaded.
class DashboardState {
  const DashboardState({this.snapshot, this.failed = false});

  /// Null until the first load arrives.
  final HoursSnapshot? snapshot;
  final bool failed;
}

/// Follows the student's hours, and loads them when the dashboard opens.
class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit(this._repository) : super(const DashboardState()) {
    _subscription = _repository.watch().listen(
      (snapshot) => emit(DashboardState(snapshot: snapshot)),
      onError: (Object _) => emit(const DashboardState(failed: true)),
    );
    unawaited(_repository.refresh());
  }

  final HoursRepository _repository;
  late final StreamSubscription<HoursSnapshot> _subscription;

  Future<void> retry() {
    emit(const DashboardState());
    return _repository.refresh();
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
