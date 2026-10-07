import 'package:flutter/material.dart';
import 'package:next_core_service/next_core_service.dart';

import 'app_tokens.dart';

/// Custom theme config provider for this app.
///
/// NextAppBar (next_widgets_service 4.2.1) is transparent and paints the
/// title, the icons and the status bar with `colorScheme.primary`, which comes
/// from [primaryColor]. So `primaryColor` is a **foreground** color for
/// navigation, and it is the token to change when fixing the navigation's
/// contrast — not `textPrimaryColor`, which only paints the text theme. Every
/// text/background
/// pair of the scheme — `primaryColor` × `surfaceColor` (the screen and the
/// NextSnack backdrop) among them — is locked at >= 4.5:1 by the contrast test
/// in `test/app_theme_test.dart`.
///
/// Register before runApp:
/// ```dart
/// AppThemeFactory.configureProvider(TemplateThemeConfigProvider());
/// ```
class TemplateThemeConfigProvider extends AppThemeConfigProvider {
  final _light = _LightConfig();
  final _dark = _DarkConfig();

  @override
  AppThemeConfig getTheme(ThemeModeType mode) =>
      mode == ThemeModeType.dark ? _dark : _light;
}

/// Dark mode: the warm near-black of the brand, with the gold as the accent.
/// The gold `primaryColor` is the foreground painted by the transparent
/// NextAppBar and the progress bars, so it must contrast against
/// `primaryBackgroundColor`. The roles the factory does not build come from
/// `AppColorRoles.dark` (`app_tokens.dart`).
class _DarkConfig extends DefaultAppThemeDarkConfig {
  @override
  String get fontFamily => AppTypography.body;

  /// Navigation **foreground** (NextAppBar title/icons, NextSnack text) and
  /// the progress bars.
  @override
  Color get primaryColor => const Color(0xFFF2C14E);

  /// Icons and text over the primary background (filled primary surfaces).
  @override
  Color get onPrimaryColor => const Color(0xFF3D2F00);

  @override
  Color get secondaryColor => const Color(0xFFC4C7C9);

  @override
  Color get onSecondaryColor => const Color(0xFF2D3133);

  /// Accent for interactive elements: TextButton foreground, Switch,
  /// ProgressIndicator and text selection. The same gold as [primaryColor],
  /// as in light.
  @override
  Color get accent1Color => const Color(0xFFF2C14E);

  /// Main Scaffold background (the screen behind every widget).
  @override
  Color get primaryBackgroundColor => const Color(0xFF15130F);

  /// Background of secondary containers (drawers, side panels, alt sections).
  @override
  Color get secondaryBackgroundColor => const Color(0xFF2B2720);

  /// The screen color, as in light (`surface` = the Scaffold background); the
  /// cards use `surfaceContainerLowest`.
  @override
  Color get surfaceColor => const Color(0xFF15130F);

  /// Text and icons over surfaces (cards, chips, dialogs).
  @override
  Color get onSurfaceColor => const Color(0xFFEDE7DB);

  @override
  Color get textPrimaryColor => const Color(0xFFEDE7DB);

  @override
  Color get textSecondaryColor => const Color(0xFFD3C8B1);

  /// Severity: error (destructive, failure). Becomes colorScheme.error.
  @override
  Color get errorColor => const Color(0xFFFFB4AB);

  /// Text and icons over the error background. Becomes colorScheme.onError.
  @override
  Color get onErrorColor => const Color(0xFF690005);

  /// Severity: warning (attention, degradation). Becomes AppColorsExtra.warning.
  @override
  Color get warningColor => const Color(0xFFFFE082);

  /// Severity: success (confirmation). Becomes AppColorsExtra.success.
  @override
  Color get successColor => const Color(0xFF4DB6AC);

  /// Severity: info (neutral). Becomes AppColorsExtra.info.
  @override
  Color get infoColor => const Color(0xFF64B5F6);
}

/// Light mode, the default one (the dark is [_DarkConfig]). The gold
/// `primaryColor` is the foreground painted by the transparent NextAppBar, so
/// it must contrast against `primaryBackgroundColor`.
/// Filled buttons (FilledButton/ElevatedButton) use the yellow
/// `primaryContainer` pair (see `app_tokens.dart`), applied globally by the
/// `*ButtonTheme` entries in `app/app.dart` — not `primaryColor`.
class _LightConfig extends DefaultAppThemeLightConfig {
  /// Base family of every text style; the headings switch to Montserrat in
  /// `AppTypography` (`app_tokens.dart`).
  @override
  String get fontFamily => AppTypography.body;

  /// Navigation **foreground**: NextAppBar title/icons/back button (the bar
  /// itself is transparent), NextSnack text and status bar. It is not the
  /// backdrop of the bar — that one comes from the Scaffold/surface.
  @override
  Color get primaryColor => const Color(0xFF755B00);

  /// Icons and text over the primary background (filled primary surfaces).
  @override
  Color get onPrimaryColor => const Color(0xFFFFFFFF);

  @override
  Color get secondaryColor => const Color(0xFF5B5F61);

  @override
  Color get onSecondaryColor => const Color(0xFFFFFFFF);

  /// Accent color for interactive elements: TextButton foreground, Switch,
  /// ProgressIndicator and text selection (`app/app.dart`'s `builder`, wired
  /// through the color-blindness filter `f()`). Same gold as [primaryColor]:
  /// the design has a single accent.
  @override
  Color get accent1Color => const Color(0xFF755B00);

  /// Main Scaffold background (the screen behind every widget).
  @override
  Color get primaryBackgroundColor => const Color(0xFFF9F9F9);

  /// Background of secondary containers (drawers, side panels, alt sections).
  @override
  Color get secondaryBackgroundColor => const Color(0xFFF3F3F4);

  /// Becomes colorScheme.surface — the screen tone. Cards and sheets sit on
  /// the `surfaceContainer*` roles (see `app_tokens.dart`).
  @override
  Color get surfaceColor => const Color(0xFFF9F9F9);

  /// Text and icons over surfaces (cards, chips, dialogs).
  @override
  Color get onSurfaceColor => const Color(0xFF1A1C1C);

  /// Main text (titleLarge, titleMedium). Opaque, same as [onSurfaceColor].
  @override
  Color get textPrimaryColor => const Color(0xFF1A1C1C);

  /// Secondary text (bodyMedium, bodySmall). Opaque, same as
  /// `AppColorRoles.light.onSurfaceVariant`.
  @override
  Color get textSecondaryColor => const Color(0xFF4E4633);

  /// Severity: error (destructive, failure). Becomes colorScheme.error.
  @override
  Color get errorColor => const Color(0xFFBA1A1A);

  /// Text and icons over the error background. Becomes colorScheme.onError.
  @override
  Color get onErrorColor => const Color(0xFFFFFFFF);

  /// Severity: warning (attention, degradation). Becomes AppColorsExtra.warning.
  @override
  Color get warningColor => const Color(0xFF8A6100);

  /// Severity: success (confirmation). Becomes AppColorsExtra.success.
  @override
  Color get successColor => const Color(0xFF146C43);

  /// Severity: info (neutral). Becomes AppColorsExtra.info.
  @override
  Color get infoColor => const Color(0xFF1565C0);
}

/// Brand identity colors (not theme colors).
///
/// They do not invert with light/dark and do not go through the color
/// blindness filter, on purpose: changing them would break brand identity.
/// They still live here, because every color of the template lives in this
/// file.
class TemplateBrandColors {
  /// Splash screen background. It matches `assets/splash.png` and therefore
  /// does **not** invert with light/dark: the splash is painted before the app
  /// theme resolves. Changing this color without changing the asset leaves a
  /// visible seam.
  static const splashBackground = Color(0xFFF7F2DE);
}

/// Overlay colors (barrier scrim, veils).
class TemplateOverlayColors {
  /// Barrier behind modals/drawers.
  static const scrim = Color(0x8A000000); // value of Colors.black54
}
