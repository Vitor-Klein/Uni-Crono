import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:next_core_service/next_core_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:uni_cronos/app/shell/shell_app_bar.dart';
import 'package:uni_cronos/features/settings/presentation/settings_modal.dart';

import 'app_harness.dart';
import 'app_theme_test.dart' show pumpApp, pumpAppTheme;

const _dark = {'theme_mode': 1};

/// The dark color scheme of the design, role by role.
final darkColors = <String, (Color Function(ColorScheme), Color)>{
  'primary': ((c) => c.primary, const Color(0xFFF2C14E)),
  'onPrimary': ((c) => c.onPrimary, const Color(0xFF3D2F00)),
  'primaryContainer': ((c) => c.primaryContainer, const Color(0xFF5A4500)),
  'onPrimaryContainer': ((c) => c.onPrimaryContainer, const Color(0xFFFFE08B)),
  'primaryFixedDim': ((c) => c.primaryFixedDim, const Color(0xFFFFD238)),
  'tertiary': ((c) => c.tertiary, const Color(0xFFF3E6C8)),
  'secondary': ((c) => c.secondary, const Color(0xFFC4C7C9)),
  'onSecondary': ((c) => c.onSecondary, const Color(0xFF2D3133)),
  'surface': ((c) => c.surface, const Color(0xFF15130F)),
  'onSurface': ((c) => c.onSurface, const Color(0xFFEDE7DB)),
  'surfaceContainerLowest': (
    (c) => c.surfaceContainerLowest,
    const Color(0xFF221F19),
  ),
  'surfaceContainerLow': (
    (c) => c.surfaceContainerLow,
    const Color(0xFF2B2720),
  ),
  'surfaceContainer': ((c) => c.surfaceContainer, const Color(0xFF353028)),
  'surfaceContainerHigh': (
    (c) => c.surfaceContainerHigh,
    const Color(0xFF403A31),
  ),
  'surfaceContainerHighest': (
    (c) => c.surfaceContainerHighest,
    const Color(0xFF4B443A),
  ),
  'onSurfaceVariant': ((c) => c.onSurfaceVariant, const Color(0xFFD3C8B1)),
  'outline': ((c) => c.outline, const Color(0xFF9C917A)),
  'outlineVariant': ((c) => c.outlineVariant, const Color(0xFF4F4738)),
  'error': ((c) => c.error, const Color(0xFFFFB4AB)),
  'onError': ((c) => c.onError, const Color(0xFF690005)),
  'errorContainer': ((c) => c.errorContainer, const Color(0xFF93000A)),
  'onErrorContainer': ((c) => c.onErrorContainer, const Color(0xFFFFDAD6)),
};

double _contrast(Color a, Color b) {
  final (la, lb) = (a.computeLuminance(), b.computeLuminance());
  final (hi, lo) = la > lb ? (la, lb) : (lb, la);
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  testWidgets('CA-01: with Escuro saved the app renders the dark palette', (
    tester,
  ) async {
    final theme = await pumpAppTheme(tester, prefs: _dark);

    expect(theme.brightness, Brightness.dark);
    final mismatches = [
      for (final MapEntry(key: role, value: (read, expected))
          in darkColors.entries)
        if (read(theme.colorScheme) != expected)
          '$role: expected $expected, got ${read(theme.colorScheme)}',
    ];
    expect(mismatches, isEmpty);
  });

  for (final device in Brightness.values) {
    testWidgets('CA-02: Sistema follows a ${device.name} device', (
      tester,
    ) async {
      tester.platformDispatcher.platformBrightnessTestValue = device;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

      final theme = await pumpAppTheme(tester, prefs: {'theme_mode': 2});

      expect(theme.brightness, device);
    });
  }

  testWidgets('CA-02: Claro stays light on a dark device', (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

    final theme = await pumpAppTheme(tester, prefs: {'theme_mode': 0});

    expect(theme.brightness, Brightness.light);
  });

  testWidgets('CA-03: choosing Escuro in the accessibility menu saves it and '
      'turns the app dark at once', (tester) async {
    final theme = await pumpApp(
      tester,
      prefs: {'theme_mode': 0},
      home: (context) => TextButton(
        onPressed: () => showSettingsModal(
          context,
          notificationsEnabled: false,
          onNotificationsTap: () {},
        ),
        child: const Text('open settings'),
      ),
    );

    await tester.tap(find.text('open settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ACESSIBILIDADE'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tema'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Escuro'));
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('theme_mode'), 1);
    expect(theme().brightness, Brightness.dark);
  });

  testWidgets('CA-04: every dark text/background pair reaches 4.5:1', (
    tester,
  ) async {
    final c = (await pumpAppTheme(tester, prefs: _dark)).colorScheme;
    final pairs = <String, (Color, Color)>{
      'onSurface/surface': (c.onSurface, c.surface),
      'onSurfaceVariant/surface': (c.onSurfaceVariant, c.surface),
      'primary/surface': (c.primary, c.surface),
      'onSurface/surfaceContainerLowest': (
        c.onSurface,
        c.surfaceContainerLowest,
      ),
      'onSurfaceVariant/surfaceContainerLowest': (
        c.onSurfaceVariant,
        c.surfaceContainerLowest,
      ),
      'onPrimaryContainer/primaryContainer': (
        c.onPrimaryContainer,
        c.primaryContainer,
      ),
      'tertiary/primaryContainer': (c.tertiary, c.primaryContainer),
      'onPrimary/primary': (c.onPrimary, c.primary),
      'onError/error': (c.onError, c.error),
      'onErrorContainer/errorContainer': (c.onErrorContainer, c.errorContainer),
    };

    final failing = [
      for (final MapEntry(key: pair, value: (fg, bg)) in pairs.entries)
        if (_contrast(fg, bg) < 4.5)
          '$pair: ${_contrast(fg, bg).toStringAsFixed(2)}:1',
    ];
    expect(failing, isEmpty);
  });

  testWidgets(
    'CA-05: dark roles from the tokens go through the color-blindness '
    'filter exactly once',
    (tester) async {
      const profile = ColorBlindProfile.protanopia;
      final scheme = (await pumpAppTheme(
        tester,
        prefs: {..._dark, 'color_blind_profile': profile.index},
      )).colorScheme;

      const addedRoles = [
        'primaryContainer',
        'onPrimaryContainer',
        'primaryFixedDim',
        'tertiary',
        'surfaceContainerLowest',
        'surfaceContainerLow',
        'surfaceContainer',
        'surfaceContainerHigh',
        'surfaceContainerHighest',
        'onSurfaceVariant',
        'outline',
        'outlineVariant',
        'errorContainer',
        'onErrorContainer',
      ];
      final mismatches = [
        for (final role in addedRoles)
          if (darkColors[role]!.$1(scheme) !=
              AppColorBlindUtils.applyColorBlindFilter(
                darkColors[role]!.$2,
                profile,
              ))
            role,
      ];
      expect(mismatches, isEmpty);
    },
  );

  testWidgets('CA-06: in dark the header asks for light status bar icons', (
    tester,
  ) async {
    await pumpRoutedApp(tester, prefs: _dark);

    final region = tester.widget<AnnotatedRegion<SystemUiOverlayStyle>>(
      find.descendant(
        of: find.byType(ShellAppBar),
        matching: find.byType(AnnotatedRegion<SystemUiOverlayStyle>),
      ),
    );
    expect(region.value.statusBarIconBrightness, Brightness.light);
  });

  for (final tab in ['Dashboard', 'Enviar', 'Atividades', 'Perfil']) {
    testWidgets('CA-07: in dark, $tab opens without overflow and with no '
        'white background', (tester) async {
      await pumpRoutedApp(tester, prefs: _dark);
      await tester.tap(navLabel(tab));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      const white = Color(0xFFFFFFFF);
      final whiteBoxes = tester
          .widgetList<DecoratedBox>(find.byType(DecoratedBox))
          .map((box) => box.decoration)
          .whereType<BoxDecoration>()
          .where((d) => d.color == white);
      final whiteMaterials = tester
          .widgetList<Material>(find.byType(Material))
          .where((m) => m.color == white);
      expect(whiteBoxes, isEmpty, reason: 'decorated boxes');
      expect(whiteMaterials, isEmpty, reason: 'materials');
    });
  }
}
