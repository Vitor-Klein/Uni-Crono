import 'package:flutter/material.dart';

/// Color roles of the light scheme that `AppThemeFactory` does not assemble —
/// it only builds primary/secondary/tertiary/error/surface and their `on*`.
///
/// Applied on top of the factory's `ColorScheme` by the `builder` in
/// `app/app.dart`, which runs each one through the color-blindness filter.
abstract final class AppColorRoles {
  static const primaryContainer = Color(0xFFFECB29);
  static const onPrimaryContainer = Color(0xFF6F5600);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFF3F3F4);
  static const surfaceContainer = Color(0xFFEEEEEE);
  static const surfaceContainerHigh = Color(0xFFE8E8E8);
  static const surfaceContainerHighest = Color(0xFFE2E2E2);
  static const onSurfaceVariant = Color(0xFF4E4633);
  static const outline = Color(0xFF807660);
  static const outlineVariant = Color(0xFFD2C5AC);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF93000A);

  /// Returns [scheme] with the roles above, each passed through [filter].
  static ColorScheme applyTo(
    ColorScheme scheme, {
    required Color Function(Color) filter,
  }) => scheme.copyWith(
    primaryContainer: filter(primaryContainer),
    onPrimaryContainer: filter(onPrimaryContainer),
    surfaceContainerLowest: filter(surfaceContainerLowest),
    surfaceContainerLow: filter(surfaceContainerLow),
    surfaceContainer: filter(surfaceContainer),
    surfaceContainerHigh: filter(surfaceContainerHigh),
    surfaceContainerHighest: filter(surfaceContainerHighest),
    onSurfaceVariant: filter(onSurfaceVariant),
    outline: filter(outline),
    outlineVariant: filter(outlineVariant),
    errorContainer: filter(errorContainer),
    onErrorContainer: filter(onErrorContainer),
  );
}

/// Spacing scale (4-point grid) of the design.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
  static const double section = 80;

  /// Side margin of every screen.
  static const double screenGutter = xl;
}

/// Corner radii of the design.
abstract final class AppRadii {
  static const double xs = 2;
  static const double sm = 4;
  static const double md = 8;
  static const double lg = 12;

  /// Fully rounded ends: chips, pills, avatars.
  static const double pill = 9999;
}

/// Elevation of the design: very soft shadows, 2–5% opacity, the largest one
/// tinted with the primary gold.
abstract final class AppShadows {
  static const sm = [
    BoxShadow(color: Color(0x0D000000), offset: Offset(0, 1), blurRadius: 2),
  ];
  static const md = [
    BoxShadow(
      color: Color(0x0D000000),
      offset: Offset(0, 4),
      blurRadius: 6,
      spreadRadius: -1,
    ),
  ];
  static const lg = [
    BoxShadow(
      color: Color(0x0D735C00),
      offset: Offset(0, 10),
      blurRadius: 40,
      spreadRadius: -10,
    ),
  ];
}

/// Type scale of the design: Montserrat for display, headline and the large
/// title; Inter for everything else.
abstract final class AppTypography {
  static const heading = 'Montserrat';
  static const body = 'Inter';

  /// Returns [base] with the design's family, weight, size, line height and
  /// letter spacing. Colors stay as they come from [base].
  static TextTheme applyTo(TextTheme base) => base.copyWith(
    displayMedium: base.displayMedium?.copyWith(
      fontFamily: heading,
      fontWeight: FontWeight.w600,
      fontSize: 48,
      height: 52.8 / 48,
      letterSpacing: -0.96,
    ),
    headlineLarge: base.headlineLarge?.copyWith(
      fontFamily: heading,
      fontWeight: FontWeight.w700,
      fontSize: 36,
      height: 40 / 36,
      letterSpacing: 0,
    ),
    headlineMedium: base.headlineMedium?.copyWith(
      fontFamily: heading,
      fontWeight: FontWeight.w600,
      fontSize: 32,
      height: 1.2,
      letterSpacing: -0.32,
    ),
    headlineSmall: base.headlineSmall?.copyWith(
      fontFamily: heading,
      fontWeight: FontWeight.w600,
      fontSize: 28,
      height: 1.2,
      letterSpacing: 0,
    ),
    titleLarge: base.titleLarge?.copyWith(
      fontFamily: heading,
      fontWeight: FontWeight.w500,
      fontSize: 24,
      height: 1.3,
      letterSpacing: 0,
    ),
    titleMedium: base.titleMedium?.copyWith(
      fontFamily: body,
      fontWeight: FontWeight.w500,
      fontSize: 18,
      height: 1.6,
      letterSpacing: 0,
    ),
    bodyLarge: base.bodyLarge?.copyWith(
      fontFamily: body,
      fontWeight: FontWeight.w400,
      fontSize: 16,
      height: 1.6,
      letterSpacing: 0,
    ),
    bodyMedium: base.bodyMedium?.copyWith(
      fontFamily: body,
      fontWeight: FontWeight.w400,
      fontSize: 14,
      height: 1.5,
      letterSpacing: 0,
    ),
    labelLarge: base.labelLarge?.copyWith(
      fontFamily: body,
      fontWeight: FontWeight.w600,
      fontSize: 14,
      height: 1,
      letterSpacing: 0.7,
    ),
    // Category tags: the uppercase is applied to the text, not the style.
    labelSmall: base.labelSmall?.copyWith(
      fontFamily: body,
      fontWeight: FontWeight.w700,
      fontSize: 10,
      height: 1.5,
      letterSpacing: 0.5,
    ),
  );
}
