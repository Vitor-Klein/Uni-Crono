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
            // pt first: it is the official language and the gen-l10n
            // template-arb-file. en/es are translations.
            supported: const [Locale('pt'), Locale('en'), Locale('es')],
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
