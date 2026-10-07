import 'package:flutter_bloc/flutter_bloc.dart';

import '../../hours/domain/hours.dart';
import '../data/certificate_launcher.dart';
import '../data/certificate_picker.dart';
import '../domain/certificate_file_rules.dart';
import '../domain/picked_file.dart';

/// The Upload tab: the chosen file, and how sending it went.
class UploadState {
  const UploadState({
    this.file,
    this.invalid = false,
    this.sending = false,
    this.failure,
    this.pending,
  });

  final PickedFile? file;

  /// The last file chosen was refused (not a PDF, or over 10 MB).
  final bool invalid;
  final bool sending;

  /// Why the last send did not launch, when it was not [Unreadable].
  final LaunchFailure? failure;

  /// A sent PDF the reader could not read, waiting for the student's data.
  final UnreadableCertificate? pending;
}

class UploadCubit extends Cubit<UploadState> {
  UploadCubit(this._picker, this._launcher) : super(const UploadState());

  final CertificatePicker _picker;
  final CertificateLauncher _launcher;

  Future<void> choose() async {
    final file = await _picker.pick();
    if (file == null || isClosed) return;
    emit(
      isAcceptedCertificate(file)
          ? UploadState(file: file)
          : const UploadState(invalid: true),
    );
  }

  void clear() => emit(const UploadState());

  /// Sends the chosen file; the launched certificate, or null — then the
  /// state says why ([UploadState.failure]) or holds the [UploadState.pending]
  /// PDF the student has to describe by hand.
  Future<LaunchedCertificate?> send() async {
    final file = state.file;
    if (file == null || state.sending) return null;
    emit(UploadState(file: file, sending: true));
    try {
      return await _launcher.launch(file);
    } on Unreadable catch (unreadable) {
      emit(UploadState(file: file, pending: unreadable.pending));
    } on LaunchFailure catch (failure) {
      emit(UploadState(file: file, failure: failure));
    }
    return null;
  }

  /// Launches the [UploadState.pending] PDF with the student's data.
  Future<LaunchedCertificate?> launchManual({
    required String title,
    required HourCategory category,
    required int hours,
  }) async {
    final pending = state.pending;
    if (pending == null || state.sending) return null;
    emit(UploadState(file: state.file, sending: true, pending: pending));
    try {
      return await _launcher.launchManual(
        pending,
        title: title,
        category: category,
        hours: hours,
      );
    } on LaunchFailure catch (failure) {
      emit(UploadState(file: state.file, pending: pending, failure: failure));
    }
    return null;
  }

  /// Gives up typing the data: the file stays chosen.
  void discardPending() => emit(UploadState(file: state.file));
}
