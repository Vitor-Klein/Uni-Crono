import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../hours/data/hours_repository.dart';
import '../../hours/domain/hours.dart';
import '../data/profile_repository.dart';
import '../domain/student_profile.dart';

class ProfileState {
  const ProfileState({this.profile, this.failed = false, this.summary});

  /// Null while loading.
  final StudentProfile? profile;
  final bool failed;

  /// The same totals the dashboard reads; null until the hours arrive.
  final HoursSummary? summary;
}

/// The signed-in student's profile, and the summary of their hours.
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._profiles, HoursRepository hours)
    : super(const ProfileState()) {
    _hours = hours.watch().listen(
      (snapshot) => emit(
        ProfileState(
          profile: state.profile,
          failed: state.failed,
          summary: snapshot.summary,
        ),
      ),
      onError: (Object _) {},
    );
    load();
  }

  final ProfileRepository _profiles;
  late final StreamSubscription<HoursSnapshot> _hours;

  Future<void> load() async {
    emit(ProfileState(summary: state.summary));
    try {
      final profile = await _profiles.current();
      if (!isClosed) {
        emit(ProfileState(profile: profile, summary: state.summary));
      }
    } on ProfileLoadFailure {
      if (!isClosed) emit(ProfileState(failed: true, summary: state.summary));
    }
  }

  @override
  Future<void> close() async {
    await _hours.cancel();
    return super.close();
  }
}
