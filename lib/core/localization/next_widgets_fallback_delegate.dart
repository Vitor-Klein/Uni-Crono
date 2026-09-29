import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:next_widgets_service/l10n/generated/l10n.dart';

/// Fills the locales that next_widgets_service's own `S` delegate does not
/// cover (it ships `en` and `es` only). Without this, `S.of(context)` throws
/// inside the accessibility sheet on a pt device: Flutter only installs
/// delegates whose `isSupported` returns true, so `S` is absent from the tree.
///
/// pt gets its own texts ([_PtStrings]); any other uncovered locale falls
/// back to `en`.
///
/// Temporary: remove once next_widgets_service ships `intl_pt.arb`.
class NextWidgetsFallbackDelegate extends LocalizationsDelegate<S> {
  const NextWidgetsFallbackDelegate();

  @override
  bool isSupported(Locale locale) => !S.delegate.isSupported(locale);

  /// pt is served directly, without `S.load`: it would also set the global
  /// `Intl.defaultLocale`, which is not this delegate's to change.
  @override
  Future<S> load(Locale locale) => locale.languageCode == 'pt'
      ? SynchronousFuture<S>(_PtStrings())
      : S.load(const Locale('en'));

  @override
  bool shouldReload(NextWidgetsFallbackDelegate old) => false;
}

class _PtStrings extends S {
  @override
  String get accessibilityDialogTitle => 'Acessibilidade';
  @override
  String get accessibilityTooltip => 'Abrir opções de acessibilidade';
  @override
  String get theme => 'Tema';
  @override
  String get light => 'Claro';
  @override
  String get dark => 'Escuro';
  @override
  String get colorBlindMode => 'Modo daltônico';
  @override
  String get apply => 'Aplicar';
  @override
  String get accessibility => 'Acessibilidade';
  @override
  String get accessibilityOpenHint => 'Abrir opções de acessibilidade';
  @override
  String get close => 'Fechar';
  @override
  String get colorBlindProfile => 'Perfil de daltonismo';
  @override
  String get colorBlindNormal => 'Normal';
  @override
  String get colorBlindProtanopia => 'Protanopia';
  @override
  String get colorBlindDeuteranopia => 'Deuteranopia';
  @override
  String get colorBlindTritanopia => 'Tritanopia';
  @override
  String get colorBlindAchromatopsia => 'Acromatopsia';
}
