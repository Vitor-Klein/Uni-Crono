import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:next_widgets_service/l10n/generated/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:uni_cronos/app/app.dart';
import 'package:uni_cronos/app/app_providers.dart';
import 'package:uni_cronos/core/localization/next_widgets_fallback_delegate.dart';
import 'package:uni_cronos/features/settings/presentation/settings_modal.dart';

/// The pt text of every next_widgets_service string.
final ptStrings = <String, (String Function(S), String)>{
  'accessibilityDialogTitle': (
    (s) => s.accessibilityDialogTitle,
    'Acessibilidade',
  ),
  'accessibilityTooltip': (
    (s) => s.accessibilityTooltip,
    'Abrir opções de acessibilidade',
  ),
  'theme': ((s) => s.theme, 'Tema'),
  'light': ((s) => s.light, 'Claro'),
  'dark': ((s) => s.dark, 'Escuro'),
  'colorBlindMode': ((s) => s.colorBlindMode, 'Modo daltônico'),
  'apply': ((s) => s.apply, 'Aplicar'),
  'accessibility': ((s) => s.accessibility, 'Acessibilidade'),
  'accessibilityOpenHint': (
    (s) => s.accessibilityOpenHint,
    'Abrir opções de acessibilidade',
  ),
  'close': ((s) => s.close, 'Fechar'),
  'colorBlindProfile': ((s) => s.colorBlindProfile, 'Perfil de daltonismo'),
  'colorBlindNormal': ((s) => s.colorBlindNormal, 'Normal'),
  'colorBlindProtanopia': ((s) => s.colorBlindProtanopia, 'Protanopia'),
  'colorBlindDeuteranopia': ((s) => s.colorBlindDeuteranopia, 'Deuteranopia'),
  'colorBlindTritanopia': ((s) => s.colorBlindTritanopia, 'Tritanopia'),
  'colorBlindAchromatopsia': ((s) => s.colorBlindAchromatopsia, 'Acromatopsia'),
};

void main() {
  const delegate = NextWidgetsFallbackDelegate();

  testWidgets('CA-01: in pt, the accessibility sheet shows its texts in pt', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      AppProviders(
        child: MyApp(
          enforceUpgradeGate: false,
          debugHome: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showSettingsModal(
                  context,
                  notificationsEnabled: false,
                  onNotificationsTap: () {},
                ),
                child: const Text('open settings'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('open settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ACESSIBILIDADE'));
    await tester.pumpAndSettle();

    expect(find.text('Acessibilidade'), findsOneWidget);
    expect(find.text('Perfil de daltonismo'), findsOneWidget);
    expect(find.text('Accessibility'), findsNothing);
    expect(find.text('Color Blind Profile'), findsNothing);
  });

  test('CA-02: every string loaded for pt matches the pt table', () async {
    final s = await delegate.load(const Locale('pt'));

    final mismatches = [
      for (final MapEntry(key: key, value: (read, expected))
          in ptStrings.entries)
        if (read(s) != expected) '$key: ${read(s)}',
    ];
    expect(mismatches, isEmpty);
  });

  test('CA-03: en and es are left to the package own translations', () {
    expect(delegate.isSupported(const Locale('en')), isFalse);
    expect(delegate.isSupported(const Locale('es')), isFalse);
  });

  test('CA-04: loading pt does not change the global Intl locale', () async {
    Intl.defaultLocale = 'pt';
    addTearDown(() => Intl.defaultLocale = null);

    await delegate.load(const Locale('pt'));

    expect(Intl.defaultLocale, 'pt');
  });
}
