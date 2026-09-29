import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:uni_cronos/app/app.dart';
import 'package:uni_cronos/app/app_providers.dart';
import 'package:uni_cronos/l10n/app_localizations.dart';

/// Pumps the app with [prefs] as the stored preferences and returns the
/// locale a screen actually sees.
Future<Locale> pumpAppLocale(
  WidgetTester tester, {
  Map<String, Object> prefs = const {},
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  late Locale locale;
  await tester.pumpWidget(
    AppProviders(
      child: MyApp(
        enforceUpgradeGate: false,
        debugHome: Builder(
          builder: (context) {
            locale = Localizations.localeOf(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return locale;
}

void main() {
  group('app title', () {
    testWidgets('CA-01: the app is titled Uni Cronos', (tester) async {
      await pumpAppLocale(tester);

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.title, 'Uni Cronos');
    });
  });

  group('official language', () {
    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized()
          .platformDispatcher
          .localesTestValue = const [
        Locale('en', 'US'),
      ];
    });
    tearDown(
      () => TestWidgetsFlutterBinding.instance.platformDispatcher
          .clearLocalesTestValue(),
    );

    testWidgets(
      'CA-02: with no saved choice, opens in pt on an English device',
      (tester) async {
        final locale = await pumpAppLocale(tester);

        expect(locale.languageCode, 'pt');
      },
    );

    for (final code in ['en', 'es']) {
      testWidgets('CA-03: a saved choice of $code is kept', (tester) async {
        final locale = await pumpAppLocale(
          tester,
          prefs: {'preferred_locale': code},
        );

        expect(locale.languageCode, code);
      });
    }

    test('CA-04: pt is the first supported locale', () {
      expect(AppLocalizations.supportedLocales.first, const Locale('pt'));
    });
  });
}
