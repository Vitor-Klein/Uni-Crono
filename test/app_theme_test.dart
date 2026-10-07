import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:next_core_service/next_core_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:uni_cronos/app/app.dart';
import 'package:uni_cronos/app/app_providers.dart';
import 'package:uni_cronos/features/settings/presentation/settings_modal.dart';

/// Pumps the app with [prefs] as the stored preferences and returns a getter
/// for the theme a screen actually sees — after the `MaterialApp.builder`
/// overrides, and updated on every rebuild.
Future<ThemeData Function()> pumpApp(
  WidgetTester tester, {
  Map<String, Object> prefs = const {},
  Widget Function(BuildContext context)? home,
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  late ThemeData theme;
  await tester.pumpWidget(
    AppProviders(
      child: MyApp(
        enforceUpgradeGate: false,
        debugHome: Builder(
          builder: (context) {
            theme = Theme.of(context);
            return Scaffold(body: home?.call(context));
          },
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return () => theme;
}

Future<ThemeData> pumpAppTheme(
  WidgetTester tester, {
  Map<String, Object> prefs = const {},
}) async => (await pumpApp(tester, prefs: prefs))();

/// The light color scheme of the design, role by role.
final designColors = <String, (Color Function(ColorScheme), Color)>{
  'primary': ((c) => c.primary, const Color(0xFF755B00)),
  'onPrimary': ((c) => c.onPrimary, const Color(0xFFFFFFFF)),
  'primaryContainer': ((c) => c.primaryContainer, const Color(0xFFFECB29)),
  'onPrimaryContainer': ((c) => c.onPrimaryContainer, const Color(0xFF6F5600)),
  'secondary': ((c) => c.secondary, const Color(0xFF5B5F61)),
  'tertiary': ((c) => c.tertiary, const Color(0xFF4E3B00)),
  'primaryFixedDim': ((c) => c.primaryFixedDim, const Color(0xFFFFD238)),
  'surface': ((c) => c.surface, const Color(0xFFF9F9F9)),
  'surfaceContainerLowest': (
    (c) => c.surfaceContainerLowest,
    const Color(0xFFFFFFFF),
  ),
  'surfaceContainerLow': (
    (c) => c.surfaceContainerLow,
    const Color(0xFFF3F3F4),
  ),
  'surfaceContainer': ((c) => c.surfaceContainer, const Color(0xFFEEEEEE)),
  'surfaceContainerHigh': (
    (c) => c.surfaceContainerHigh,
    const Color(0xFFE8E8E8),
  ),
  'surfaceContainerHighest': (
    (c) => c.surfaceContainerHighest,
    const Color(0xFFE2E2E2),
  ),
  'onSurface': ((c) => c.onSurface, const Color(0xFF1A1C1C)),
  'onSurfaceVariant': ((c) => c.onSurfaceVariant, const Color(0xFF4E4633)),
  'outline': ((c) => c.outline, const Color(0xFF807660)),
  'outlineVariant': ((c) => c.outlineVariant, const Color(0xFFD2C5AC)),
  'error': ((c) => c.error, const Color(0xFFBA1A1A)),
  'onError': ((c) => c.onError, const Color(0xFFFFFFFF)),
  'errorContainer': ((c) => c.errorContainer, const Color(0xFFFFDAD6)),
  'onErrorContainer': ((c) => c.onErrorContainer, const Color(0xFF93000A)),
};

void main() {
  group('color scheme', () {
    testWidgets('CA-01: every color role matches the design', (tester) async {
      final scheme = (await pumpAppTheme(tester)).colorScheme;

      final mismatches = [
        for (final MapEntry(key: role, value: (read, expected))
            in designColors.entries)
          if (read(scheme) != expected)
            '$role: expected $expected, got ${read(scheme)}',
      ];
      expect(mismatches, isEmpty);
    });

    testWidgets(
      'CA-02: roles added on top of the factory go through the color-blindness '
      'filter exactly once',
      (tester) async {
        const profile = ColorBlindProfile.protanopia;
        final scheme = (await pumpAppTheme(
          tester,
          prefs: {'color_blind_profile': profile.index},
        )).colorScheme;

        const addedRoles = [
          'primaryContainer',
          'tertiary',
          'primaryFixedDim',
          'onPrimaryContainer',
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
            if (designColors[role]!.$1(scheme) !=
                AppColorBlindUtils.applyColorBlindFilter(
                  designColors[role]!.$2,
                  profile,
                ))
              role,
        ];
        expect(mismatches, isEmpty);
      },
    );
  });

  group('type scale', () {
    // (read, family, weight, size, height, letterSpacing)
    final scale =
        <
          String,
          (
            TextStyle? Function(TextTheme),
            String,
            FontWeight,
            double,
            double,
            double,
          )
        >{
          'displayMedium': (
            (t) => t.displayMedium,
            'Montserrat',
            FontWeight.w600,
            48,
            1.10,
            -0.96,
          ),
          'headlineLarge': (
            (t) => t.headlineLarge,
            'Montserrat',
            FontWeight.w700,
            36,
            1.11,
            0,
          ),
          'headlineMedium': (
            (t) => t.headlineMedium,
            'Montserrat',
            FontWeight.w600,
            32,
            1.20,
            -0.32,
          ),
          'headlineSmall': (
            (t) => t.headlineSmall,
            'Montserrat',
            FontWeight.w600,
            28,
            1.20,
            0,
          ),
          'titleLarge': (
            (t) => t.titleLarge,
            'Montserrat',
            FontWeight.w500,
            24,
            1.30,
            0,
          ),
          'titleMedium': (
            (t) => t.titleMedium,
            'Inter',
            FontWeight.w500,
            18,
            1.60,
            0,
          ),
          'bodyLarge': (
            (t) => t.bodyLarge,
            'Inter',
            FontWeight.w400,
            16,
            1.60,
            0,
          ),
          'bodyMedium': (
            (t) => t.bodyMedium,
            'Inter',
            FontWeight.w400,
            14,
            1.50,
            0,
          ),
          'labelLarge': (
            (t) => t.labelLarge,
            'Inter',
            FontWeight.w600,
            14,
            1.00,
            0.70,
          ),
          'labelSmall': (
            (t) => t.labelSmall,
            'Inter',
            FontWeight.w700,
            10,
            1.50,
            0.50,
          ),
        };

    testWidgets('CA-03: every text style matches the design type scale', (
      tester,
    ) async {
      final textTheme = (await pumpAppTheme(tester)).textTheme;

      final mismatches = <String>[];
      for (final MapEntry(
            key: name,
            value: (read, family, weight, size, height, spacing),
          )
          in scale.entries) {
        final s = read(textTheme)!;
        if (s.fontFamily != family ||
            s.fontWeight != weight ||
            s.fontSize != size ||
            (s.height! - height).abs() > 0.005 ||
            s.letterSpacing != spacing) {
          mismatches.add(
            '$name: ${s.fontFamily} ${s.fontWeight} ${s.fontSize}/'
            '${s.height} ls=${s.letterSpacing}',
          );
        }
      }
      expect(mismatches, isEmpty);
    });

    testWidgets(
      'CA-09: text is onSurface, except bodyMedium and bodySmall, which are '
      'onSurfaceVariant',
      (tester) async {
        final theme = await pumpAppTheme(tester);
        final c = theme.colorScheme;
        final t = theme.textTheme;
        final expected = <String, (Color?, Color)>{
          for (final MapEntry(key: name, value: (read, _, _, _, _, _))
              in scale.entries)
            name: (read(t)!.color, c.onSurface),
          'bodyMedium': (t.bodyMedium!.color, c.onSurfaceVariant),
          'bodySmall': (t.bodySmall!.color, c.onSurfaceVariant),
        };

        final mismatches = [
          for (final MapEntry(key: name, value: (actual, want))
              in expected.entries)
            if (actual != want) '$name: $actual',
        ];
        expect(mismatches, isEmpty);
      },
    );
  });

  group('fonts', () {
    const fontFiles = [
      'assets/fonts/Montserrat-Medium.ttf',
      'assets/fonts/Montserrat-SemiBold.ttf',
      'assets/fonts/Montserrat-Bold.ttf',
      'assets/fonts/Inter-Regular.ttf',
      'assets/fonts/Inter-Medium.ttf',
      'assets/fonts/Inter-SemiBold.ttf',
      'assets/fonts/Inter-Bold.ttf',
    ];

    for (final file in fontFiles) {
      test('CA-04: $file loads from the app bundle', () async {
        TestWidgetsFlutterBinding.ensureInitialized();

        final data = await rootBundle.load(file);

        expect(data.lengthInBytes, greaterThan(0));
      });
    }
  });

  group('interactive colors', () {
    testWidgets(
      'CA-08: filled buttons use the yellow container; text buttons, switch, '
      'progress and cursor use primary',
      (tester) async {
        final theme = await pumpAppTheme(tester);
        final c = theme.colorScheme;
        const none = <WidgetState>{};

        for (final style in [
          theme.filledButtonTheme.style!,
          theme.elevatedButtonTheme.style!,
        ]) {
          expect(style.backgroundColor!.resolve(none), c.primaryContainer);
          expect(style.foregroundColor!.resolve(none), c.onPrimaryContainer);
        }
        expect(
          theme.textButtonTheme.style!.foregroundColor!.resolve(none),
          c.primary,
        );
        expect(
          theme.switchTheme.thumbColor!.resolve({WidgetState.selected}),
          c.primary,
        );
        expect(theme.progressIndicatorTheme.color, c.primary);
        expect(theme.textSelectionTheme.cursorColor, c.primary);
      },
    );
  });

  group('contrast', () {
    double contrast(Color a, Color b) {
      final (la, lb) = (a.computeLuminance(), b.computeLuminance());
      final (hi, lo) = la > lb ? (la, lb) : (lb, la);
      return (hi + 0.05) / (lo + 0.05);
    }

    testWidgets('CA-05: every text/background pair reaches 4.5:1', (
      tester,
    ) async {
      final c = (await pumpAppTheme(tester)).colorScheme;
      final pairs = <String, (Color, Color)>{
        'onSurface/surface': (c.onSurface, c.surface),
        'onSurfaceVariant/surface': (c.onSurfaceVariant, c.surface),
        'primary/surface': (c.primary, c.surface),
        'onSurface/surfaceContainerLowest': (
          c.onSurface,
          c.surfaceContainerLowest,
        ),
        'onPrimaryContainer/primaryContainer': (
          c.onPrimaryContainer,
          c.primaryContainer,
        ),
        'onPrimary/primary': (c.onPrimary, c.primary),
        'onError/error': (c.onError, c.error),
        'onErrorContainer/errorContainer': (
          c.onErrorContainer,
          c.errorContainer,
        ),
      };

      final failing = [
        for (final MapEntry(key: pair, value: (fg, bg)) in pairs.entries)
          if (contrast(fg, bg) < 4.5)
            '$pair: ${contrast(fg, bg).toStringAsFixed(2)}:1',
      ];
      expect(failing, isEmpty);
    });
  });

  group('theme mode', () {
    testWidgets('CA-06: renders dark when the saved preference is dark', (
      tester,
    ) async {
      final theme = await pumpAppTheme(tester, prefs: {'theme_mode': 1});

      expect(theme.brightness, Brightness.dark);
    });

    testWidgets('CA-06: renders dark when following a dark system', (
      tester,
    ) async {
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

      final theme = await pumpAppTheme(tester, prefs: {'theme_mode': 2});

      expect(theme.brightness, Brightness.dark);
    });

    testWidgets(
      'CA-07: choosing dark in the accessibility menu saves it and renders '
      'dark',
      (tester) async {
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
      },
    );
  });
}
