import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:next_core_service/next_core_service.dart';

import '../core/theme/template_theme_provider.dart';

class AppThemeBootstrap {
  AppThemeBootstrap._();

  static var _configured = false;

  static void ensureConfigured() {
    if (_configured) return;
    AppThemeFactory.configureProvider(TemplateThemeConfigProvider());
    _configured = true;
  }
}

class AppProviders extends StatelessWidget {
  const AppProviders({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    AppThemeBootstrap.ensureConfigured();

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AppThemeCubit(
            preferenceService: SharedPrefsThemePreferenceService(),
          ),
        ),
        BlocProvider(
          create: (_) => TextScaleCubit(service: SharedPrefsTextScaleService()),
        ),
        BlocProvider(
          create: (_) => LocaleCubit(
            service: SharedPrefsLocaleService(),
            // en stays first (Flutter's resolution fallback) and is never
            // conditional — it's the gen-l10n template-arb-file and the
            // final fallback everywhere. pt/es come from optional_locales,
            // chosen at generation time.
            //
            // Deliberately a one-liner with the comma BEFORE each optional
            // item, not the more natural multi-line/trailing-comma form:
            // the Mustache section below (see the raw, unrendered source
            // file, not this comment) repeats whatever sits inside it, so a
            // trailing comma or an embedded newline gets duplicated once
            // per selected locale, leaving stray blank lines or a dangling
            // comma-then-bracket that `dart format` always wants to rewrite,
            // breaking format cleanliness. This exact shape was verified
            // clean against `dart format` for 0, 1, and 2 selected locales
            // before being committed. Reformatting this line "for
            // readability" will silently reintroduce that failure — if you
            // touch it, re-verify format cleanliness for all three cases
            // first. (Do not paste the literal Mustache tag syntax into a
            // comment near this file — it will be parsed as a real tag.)
            supported: const [Locale('en'), Locale('pt'), Locale('es')],
          ),
        ),
        BlocProvider(
          create: (_) => AccessibilityCubit(
            service: SharedPrefsAnimationPreferenceService(),
          ),
        ),
      ],
      child: child,
    );
  }
}
