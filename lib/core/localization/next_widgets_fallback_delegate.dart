import 'package:flutter/material.dart';
import 'package:next_widgets_service/l10n/generated/l10n.dart';

/// Fills the locales that next_widgets_service's own `S` delegate does not
/// cover (it ships `en` and `es` only). Without this, `S.of(context)` throws
/// inside the accessibility sheet on a pt device: Flutter only installs
/// delegates whose `isSupported` returns true, so `S` is absent from the tree.
///
/// Temporary: remove once next_widgets_service ships `intl_pt.arb`.
class NextWidgetsFallbackDelegate extends LocalizationsDelegate<S> {
  const NextWidgetsFallbackDelegate();

  @override
  bool isSupported(Locale locale) => !S.delegate.isSupported(locale);

  @override
  Future<S> load(Locale locale) => S.load(const Locale('en'));

  @override
  bool shouldReload(NextWidgetsFallbackDelegate old) => false;
}
