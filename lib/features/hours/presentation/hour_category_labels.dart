import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../domain/hours.dart';

/// How each category of hours is named and drawn.
extension HourCategoryLabels on HourCategory {
  String title(AppLocalizations l10n) => switch (this) {
    HourCategory.complementary => l10n.hoursComplementaryTitle,
    HourCategory.extension => l10n.hoursExtensionTitle,
  };

  String subtitle(AppLocalizations l10n) => switch (this) {
    HourCategory.complementary => l10n.hoursComplementarySubtitle,
    HourCategory.extension => l10n.hoursExtensionSubtitle,
  };

  IconData get icon => switch (this) {
    HourCategory.complementary => Icons.workspace_premium_outlined,
    HourCategory.extension => Icons.volunteer_activism_outlined,
  };
}
