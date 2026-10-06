import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:next_core_service/next_core_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Session;

import '../core/theme/template_theme_provider.dart';
import '../features/auth/data/auth_gateway.dart';
import '../features/auth/data/supabase_auth_gateway.dart';
import '../features/auth/presentation/session_cubit.dart';
import '../features/hours/data/hours_repository.dart';
import '../features/hours/data/supabase_hours_repository.dart';
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
    this.authGateway,
    this.hoursRepository,
    super.key,
  });

  final Widget child;

  /// Where the notifications switch is read from and written to; the real push
  /// service when omitted.
  final NotificationsPreference? notificationsPreference;

  /// The student's account; the Supabase project when omitted.
  final AuthGateway? authGateway;

  /// Where the student's hours come from; the Supabase project when
  /// omitted.
  final HoursRepository? hoursRepository;

  @override
  Widget build(BuildContext context) {
    AppThemeBootstrap.ensureConfigured();

    return RepositoryProvider<HoursRepository>(
      create: (_) =>
          hoursRepository ?? SupabaseHoursRepository(Supabase.instance.client),
      dispose: (repository) => repository.dispose(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => AppThemeCubit(
              preferenceService: SharedPrefsThemePreferenceService(),
            ),
          ),
          BlocProvider(
            create: (_) =>
                TextScaleCubit(service: SharedPrefsTextScaleService()),
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
              authGateway ?? SupabaseAuthGateway(Supabase.instance.client),
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
      ),
    );
  }
}
