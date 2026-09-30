import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:next_widgets_service/next_widgets_service.dart';

import '../../../l10n/app_localizations.dart';
import 'notifications_cubit.dart';
import 'notifications_sheet.dart';

/// Opens the notifications sheet over [context], saving through the shared
/// [NotificationsCubit] and confirming (or reporting the failure) in a snack.
void openNotificationsSheet(BuildContext context) {
  final cubit = context.read<NotificationsCubit>();
  final l10n = AppLocalizations.of(context)!;
  showNotificationsSheet(
    context,
    enabled: cubit.state,
    onChanged: (enabled) async {
      final saved = await cubit.setEnabled(enabled);
      if (context.mounted) {
        NextSnack.showNextSnack(
          context,
          message: !saved
              ? l10n.notificationsUpdateError
              : enabled
              ? l10n.notificationsEnabledMessage
              : l10n.notificationsDisabledMessage,
        );
      }
      return cubit.state;
    },
  );
}
