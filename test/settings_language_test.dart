import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:uni_cronos/app/app.dart';
import 'package:uni_cronos/app/app_providers.dart';
import 'package:uni_cronos/features/settings/presentation/settings_modal.dart';

/// Pumps the app with [prefs] stored, opens the settings modal and returns a
/// getter for the locale a screen currently sees.
Future<Locale Function()> openSettings(
  WidgetTester tester, {
  Map<String, Object> prefs = const {},
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  late Locale locale;
  await tester.pumpWidget(
    AppProviders(
      child: MyApp(
        enforceUpgradeGate: false,
        debugHome: Scaffold(
          body: Builder(
            builder: (context) {
              locale = Localizations.localeOf(context);
              return TextButton(
                onPressed: () => showSettingsModal(
                  context,
                  notificationsEnabled: false,
                  onNotificationsTap: () {},
                ),
                child: const Text('open settings'),
              );
            },
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('open settings'));
  await tester.pumpAndSettle();
  return () => locale;
}

Future<String?> savedLocale() async =>
    (await SharedPreferences.getInstance()).getString('preferred_locale');

void main() {
  testWidgets(
    'CA-01: with no saved choice, settings shows the language item as '
    'Português',
    (tester) async {
      await openSettings(tester);

      expect(find.text('IDIOMA'), findsOneWidget);
      expect(find.text('Português'), findsOneWidget);
    },
  );

  testWidgets(
    'CA-02: the language sheet lists pt, en and es by their own names, with '
    'only the current one marked and no system option',
    (tester) async {
      await openSettings(tester);
      await tester.tap(find.text('IDIOMA'));
      await tester.pumpAndSettle();

      for (final name in ['Português', 'English', 'Español']) {
        expect(find.widgetWithText(ListTile, name), findsOneWidget);
      }
      expect(find.text('Sistema'), findsNothing);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(
        find.descendant(
          of: find.widgetWithText(ListTile, 'Português'),
          matching: find.byIcon(Icons.check_circle),
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets('CA-03: choosing English switches the app to en and saves it', (
    tester,
  ) async {
    final locale = await openSettings(tester);
    await tester.tap(find.text('IDIOMA'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'English'));
    await tester.pumpAndSettle();

    expect(locale().languageCode, 'en');
    expect(await savedLocale(), 'en');
  });

  testWidgets(
    'CA-04: with en saved, choosing Português switches back to pt and saves it',
    (tester) async {
      final locale = await openSettings(
        tester,
        prefs: {'preferred_locale': 'en'},
      );
      await tester.tap(find.text('LANGUAGE'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ListTile, 'Português'));
      await tester.pumpAndSettle();

      expect(locale().languageCode, 'pt');
      expect(await savedLocale(), 'pt');
    },
  );
}
