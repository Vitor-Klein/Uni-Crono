import 'package:flutter/material.dart';
import 'package:next_core_service/next_core_service.dart';

/// Custom theme config provider for this app.
///
/// NextAppBar (next_widgets_service 4.2.1) is transparent and paints the
/// title, the icons and the status bar with `colorScheme.primary`, which comes
/// from [primaryColor]. So `primaryColor` is a **foreground** color for
/// navigation, and it is the token to change when fixing contrast — never
/// `textPrimaryColor`, which stays without any override. The pairs
/// `primaryColor` × `primaryBackgroundColor` and `primaryColor` ×
/// `surfaceColor` (the NextSnack backdrop) are locked at >= 4.5:1 by
/// `hooks/test/contrast_gate_test.dart`.
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

/// Dark mode: light navigation over the dark Scaffold background.
/// `primaryColor` is white because the transparent NextAppBar paints the
/// title, the icons and the status bar with it — it must contrast against
/// `primaryBackgroundColor`, not against a bar of its own.
class _DarkConfig extends DefaultAppThemeDarkConfig {
  /// Navigation **foreground**: NextAppBar title/icons/back button (the bar
  /// itself is transparent), NextSnack text and status bar. It is not the
  /// backdrop of the bar — that one comes from the Scaffold/surface.
  @override
  Color get primaryColor => const Color(0xFFFFFFFF);

  /// Icons and text over the primary background (filled primary surfaces).
  @override
  Color get onPrimaryColor => const Color(0xFFFFFFFF);

  /// Accent color for interactive elements: TextButton foreground, Switch,
  /// ProgressIndicator and text selection (`app/app.dart`'s `builder`, wired
  /// through the color-blindness filter `f()`). Indigo — the one hue not
  /// already used by error/warning/success/info, so it never reads as a
  /// severity state.
  @override
  Color get accent1Color => const Color(0xFFA99BFF);

  /// Main Scaffold background (the screen behind every widget).
  @override
  Color get primaryBackgroundColor => const Color(0xFF121214);

  /// Background of secondary containers (drawers, side panels, alt sections).
  @override
  Color get secondaryBackgroundColor => const Color(0xFF2A2A30);

  /// Background of cards, chips, dialogs and bottom sheets.
  @override
  Color get surfaceColor => const Color(0xFF1D1D21);

  /// Text and icons over surfaces (cards, chips, dialogs).
  @override
  Color get onSurfaceColor => const Color(0xFFFFFFFF);

  /// Severity: error (destructive, failure). Becomes colorScheme.error.
  @override
  Color get errorColor => const Color(0xFFFF8A80);

  /// Text and icons over the error background. Becomes colorScheme.onError.
  @override
  Color get onErrorColor => const Color(0xFF000000);

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

/// Light mode: dark navigation over the light Scaffold background. Same
/// contract as dark, inverted: `primaryColor` is the foreground painted by the
/// transparent NextAppBar, so it must contrast against
/// `primaryBackgroundColor`.
/// Filled buttons (FilledButton/ElevatedButton) use the pair declared in
/// [TemplateCtaColors], applied globally by the `*ButtonTheme` entries in
/// `app/app.dart` — not `primaryColor`.
class _LightConfig extends DefaultAppThemeLightConfig {
  /// Navigation **foreground**: NextAppBar title/icons/back button (the bar
  /// itself is transparent), NextSnack text and status bar. It is not the
  /// backdrop of the bar — that one comes from the Scaffold/surface.
  @override
  Color get primaryColor => const Color(0xFF111111);

  /// Icons and text over the primary background (filled primary surfaces).
  @override
  Color get onPrimaryColor => const Color(0xFF111111);

  /// Accent color for interactive elements: TextButton foreground, Switch,
  /// ProgressIndicator and text selection (`app/app.dart`'s `builder`, wired
  /// through the color-blindness filter `f()`). Indigo — the one hue not
  /// already used by error/warning/success/info, so it never reads as a
  /// severity state.
  @override
  Color get accent1Color => const Color(0xFF4F39C7);

  /// Main Scaffold background (the screen behind every widget).
  @override
  Color get primaryBackgroundColor => const Color(0xFFF2F2F4);

  /// Background of secondary containers (drawers, side panels, alt sections).
  @override
  Color get secondaryBackgroundColor => const Color(0xFFE4E4E9);

  /// Background of cards, chips, dialogs and bottom sheets.
  @override
  Color get surfaceColor => const Color(0xFFFFFFFF);

  /// Text and icons over surfaces (cards, chips, dialogs).
  @override
  Color get onSurfaceColor => const Color(0xFF111111);

  /// Severity: error (destructive, failure). Becomes colorScheme.error.
  @override
  Color get errorColor => const Color(0xFFC62828);

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

/// Color pair for filled buttons (CTA): `FilledButton` and `ElevatedButton`.
///
/// The `ColorScheme` assembled by `AppThemeFactory` does not carry
/// `inverseSurface`/`onInverseSurface`, so this pair would not come out of the
/// app theme. It is declared here and applied globally by the `*ButtonTheme`
/// entries in `app/app.dart` — this is the only place to edit to change the
/// color of any filled button.
///
/// Do not use `primaryColor` here: it is the navigation foreground color
/// (NextAppBar title/icons), so as a button fill it would vanish against the
/// screen behind it.
class TemplateCtaColors {
  const TemplateCtaColors({required this.background, required this.foreground});

  /// Button fill.
  final Color background;

  /// Text and icon over the button fill.
  final Color foreground;

  static const dark = TemplateCtaColors(
    background: Color(0xFFFFFFFF),
    foreground: Color(0xFF121214),
  );

  static const light = TemplateCtaColors(
    background: Color(0xFF111111),
    foreground: Color(0xFFFFFFFF),
  );

  static TemplateCtaColors of(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;
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
