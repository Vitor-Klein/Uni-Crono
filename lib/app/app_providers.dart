import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:next_core_service/next_core_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Session;

import '../core/theme/template_theme_provider.dart';
import '../core/utils/link_opener.dart';
import '../features/auth/data/auth_gateway.dart';
import '../features/auth/data/supabase_auth_gateway.dart';
import '../features/auth/presentation/session_cubit.dart';
import '../features/hours/data/hours_repository.dart';
import '../features/hours/data/supabase_hours_repository.dart';
import '../features/notifications/data/notifications_preference.dart';
import '../features/notifications/presentation/notifications_cubit.dart';
import '../features/opportunities/data/opportunity_repository.dart';
import '../features/opportunities/data/supabase_opportunity_repository.dart';
import '../features/profile/data/profile_repository.dart';
import '../features/profile/data/supabase_profile_repository.dart';
import '../features/upload/data/certificate_launcher.dart';
import '../features/upload/data/certificate_picker.dart';
import '../features/upload/data/file_picker_certificate_picker.dart';
import '../features/upload/data/pdf_text_extractor.dart';
import '../features/upload/data/supabase_certificate_launcher.dart';

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
    this.certificatePicker,
    this.certificateLauncher,
    this.opportunityRepository,
    this.profileRepository,
    this.linkOpener,
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

  /// How the student chooses a certificate; the system chooser when omitted.
  final CertificatePicker? certificatePicker;

  /// How certificates are read and saved; on the device and in the
  /// Supabase project when omitted.
  final CertificateLauncher? certificateLauncher;

  /// The catalog of opportunities; the Supabase project when omitted.
  final OpportunityRepository? opportunityRepository;

  /// The student's profile; the Supabase project when omitted.
  final ProfileRepository? profileRepository;

  /// How links leave the app; the system browser when omitted.
  final LinkOpener? linkOpener;

  @override
  Widget build(BuildContext context) {
    AppThemeBootstrap.ensureConfigured();

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<HoursRepository>(
          create: (_) =>
              hoursRepository ??
              SupabaseHoursRepository(Supabase.instance.client),
          dispose: (repository) => repository.dispose(),
        ),
        RepositoryProvider<CertificatePicker>(
          create: (_) =>
              certificatePicker ?? const FilePickerCertificatePicker(),
        ),
        RepositoryProvider<CertificateLauncher>(
          create: (_) =>
              certificateLauncher ??
              SupabaseCertificateLauncher(
                Supabase.instance.client,
                extractor: const PdfrxTextExtractor(),
              ),
        ),
        RepositoryProvider<OpportunityRepository>(
          create: (_) =>
              opportunityRepository ??
              SupabaseOpportunityRepository(Supabase.instance.client),
        ),
        RepositoryProvider<ProfileRepository>(
          create: (_) =>
              profileRepository ??
              SupabaseProfileRepository(Supabase.instance.client),
        ),
        RepositoryProvider<LinkOpener>(
          create: (_) => linkOpener ?? const ExternalLinkOpener(),
        ),
      ],
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
