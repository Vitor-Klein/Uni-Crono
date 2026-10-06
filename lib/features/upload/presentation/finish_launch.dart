import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:next_widgets_service/next_widgets_service.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../l10n/app_localizations.dart';
import '../../hours/data/hours_repository.dart';
import '../../hours/presentation/hour_category_labels.dart';
import '../data/certificate_launcher.dart';
import 'upload_cubit.dart';

/// After a certificate is launched: the hours load again, the Upload tab
/// empties and goes back to its root, and the student lands on the
/// dashboard with the news.
void finishLaunch(BuildContext context, LaunchedCertificate launched) {
  final l10n = AppLocalizations.of(context)!;
  final router = GoRouter.of(context);
  context.read<HoursRepository>().refresh();
  context.read<UploadCubit>().clear();
  NextSnack.showNextSnack(
    context,
    message: l10n.uploadLaunched(launched.hours, launched.category.title(l10n)),
  );
  if (!router.canPop()) {
    router.go(AppRoutes.dashboard);
    return;
  }
  // From the form at /upload/manual: the Upload tab goes back to its root
  // first, so it does not reopen on the form; the dashboard comes a frame
  // later, once that location is settled.
  router.go(AppRoutes.upload);
  WidgetsBinding.instance.addPostFrameCallback(
    (_) => router.go(AppRoutes.dashboard),
  );
}

/// What the student reads when a certificate was not launched.
String launchFailureMessage(AppLocalizations l10n, LaunchFailure failure) =>
    switch (failure) {
      Duplicate() => l10n.uploadDuplicate,
      Unreadable() || ReaderUnavailable() => l10n.uploadUnavailable,
    };
