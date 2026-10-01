import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:next_core_service/next_core_service.dart';

import '../core/theme/template_theme_provider.dart';
import '../features/auth/data/session_repository.dart';
import '../features/auth/domain/session.dart';
import '../features/auth/presentation/session_cubit.dart';
import '../features/notifications/data/notifications_preference.dart';
import '../features/notifications/presentation/notifications_cubit.dart';

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
  const AppProviders({
    required this.child,
    this.notificationsPreference,
    this.sessionRepository,
    this.initialSession,
    super.key,
  });

  final Widget child;

  /// Where the notifications switch is read from and written to; the real push
  /// service when omitted.
  final NotificationsPreference? notificationsPreference;

  /// Where the session is kept; the device's saved preferences when omitted.
  final SessionRepository? sessionRepository;

  /// The session read before the app ran; null when nobody is signed in.
  final Session? initialSession;

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
        BlocProvider(
          create: (_) => SessionCubit(
            sessionRepository ?? const SharedPrefsSessionRepository(),
            initial: initialSession,
          ),
        ),
        // Eager: the saved choice loads at startup, so the More modal never
        // opens with the optimistic default.
        BlocProvider(
          lazy: false,
          create: (_) => NotificationsCubit(
            notificationsPreference ?? const PushNotificationsPreference(),
          ),
        ),
      ],
      child: child,
    );
  }
}
