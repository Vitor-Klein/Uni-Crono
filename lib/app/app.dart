import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:next_core_service/next_core_service.dart';
import 'package:next_widgets_service/next_widgets_service.dart';

import '../l10n/app_localizations.dart';
import '../core/localization/next_widgets_fallback_delegate.dart';
import '../core/navigation/app_routes.dart';
import '../core/theme/template_theme_provider.dart';
import '../features/notifications/data/push_service.dart';
import '../features/upgrade/domain/upgrade_gate_controller.dart';
import 'app_router.dart';

class MyApp extends StatefulWidget {
  const MyApp({
    this.firebaseWarningMessage,
    this.debugHome,
    this.enforceUpgradeGate = true,
    super.key,
  });

  final String? firebaseWarningMessage;
  final Widget? debugHome;
  final bool enforceUpgradeGate;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription<String>? _pushErrorsSub;
  UpgradeGateController? _upgradeGate;
  late final GoRouter _router = _buildRouter();

  GoRouter _buildRouter() {
    final debugHome = widget.debugHome;
    if (debugHome != null) {
      return GoRouter(
        initialLocation: AppRoutes.home,
        routes: [GoRoute(path: AppRoutes.home, builder: (_, __) => debugHome)],
      );
    }

    final upgradeGate = UpgradeGateController(
      enabled: widget.enforceUpgradeGate,
    );
    _upgradeGate = upgradeGate;
    return AppRouter.build(
      enforceUpgradeGate: widget.enforceUpgradeGate,
      upgradeGate: upgradeGate,
    );
  }

  SnackBar _pushDevErrorSnackBar(String message) {
    final cs = Theme.of(context).colorScheme;
    return SnackBar(
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 8),
      content: Text(
        'Push/Firebase (dev): $message',
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: cs.onError),
      ),
      backgroundColor: cs.error,
    );
  }

  void _showPushDevError(String message) {
    if (!mounted) return;
    final messenger = AppRouter.scaffoldMessengerKey.currentState;
    if (messenger == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final retryMessenger = AppRouter.scaffoldMessengerKey.currentState;
        if (retryMessenger == null) return;
        retryMessenger.clearSnackBars();
        // Debug-only diagnostic (kDebugMode): uses the messenger's global key
        // because this caller sits above MaterialApp, and
        // ScaffoldMessenger.of(context) (used by NextSnack) can't reach the
        // messenger from here.
        // ignore: prefer_next_snack
        retryMessenger.showSnackBar(_pushDevErrorSnackBar(message));
      });
      return;
    }
    messenger.clearSnackBars();
    // Debug-only diagnostic (kDebugMode): uses the messenger's global key
    // because this caller sits above MaterialApp, and
    // ScaffoldMessenger.of(context) (used by NextSnack) can't reach the
    // messenger from here.
    // ignore: prefer_next_snack
    messenger.showSnackBar(_pushDevErrorSnackBar(message));
  }

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      _pushErrorsSub = PushService.devFirebaseErrorStream.listen(
        _showPushDevError,
      );
      final pendingErrors = PushService.takePendingDevFirebaseErrors();
      if (pendingErrors.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          for (final message in pendingErrors) {
            _showPushDevError(message);
          }
        });
      }

      if (widget.firebaseWarningMessage != null && pendingErrors.isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Future<void>.delayed(const Duration(milliseconds: 350), () {
            if (!mounted) return;
            final messenger = AppRouter.scaffoldMessengerKey.currentState;
            if (messenger == null) return;
            final extra = Theme.of(context).extension<AppColorsExtra>()!;
            messenger.clearSnackBars();
            // Debug-only diagnostic (kDebugMode): uses the messenger's global
            // key because this caller sits above MaterialApp, and
            // ScaffoldMessenger.of(context) (used by NextSnack) can't reach
            // the messenger from here.
            // ignore: prefer_next_snack
            messenger.showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 8),
                content: Text(widget.firebaseWarningMessage!),
                backgroundColor: extra.warning,
              ),
            );
          });
        });
      }
    }
  }

  @override
  void dispose() {
    _pushErrorsSub?.cancel();
    _upgradeGate?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppThemeCubit, AppThemeState>(
      builder: (context, themeState) {
        return BlocBuilder<LocaleCubit, Locale?>(
          builder: (context, locale) {
            return MaterialApp.router(
              title: 'uni_cronos',
              debugShowCheckedModeBanner: false,
              scaffoldMessengerKey: AppRouter.scaffoldMessengerKey,
              theme: themeState.lightTheme,
              darkTheme: themeState.darkTheme,
              themeMode: themeState.themeMode,
              locale: locale,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                ...NextLocalizations.localizationsDelegates,
                // Fallback: must stay after
                // ...NextLocalizations.localizationsDelegates so `S.delegate`
                // (en/es) claims a locale first — this one only fills what
                // it does not cover (pt today), never overrides it.
                NextWidgetsFallbackDelegate(),
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              builder: (context, child) {
                final baseTheme = Theme.of(context);
                final cta = TemplateCtaColors.of(baseTheme.brightness);
                Color f(Color c) => AppColorBlindUtils.applyColorBlindFilter(
                  c,
                  themeState.colorBlindProfile,
                );
                final ctaStyle = ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(f(cta.background)),
                  foregroundColor: WidgetStatePropertyAll(f(cta.foreground)),
                );
                // Accent for interactive elements: text
                // buttons, switch, progress indicator and text selection.
                //
                // Read as-is, with no `f()`: AppThemeFactory already applies
                // the color-blindness filter when it builds AppColorsExtra
                // (`accent1: f(config.accent1Color)`), so filtering again here
                // would apply the matrix twice and over-correct the accent
                // against the rest of the theme. The CTA above is the opposite
                // case — it comes from a literal that never passes through the
                // factory, so it needs the local `f()` to be filtered at all.
                final accent = baseTheme.extension<AppColorsExtra>()!.accent1;
                return Theme(
                  data: baseTheme.copyWith(
                    textButtonTheme: TextButtonThemeData(
                      style: TextButton.styleFrom(
                        foregroundColor: accent,
                        textStyle: baseTheme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    filledButtonTheme: FilledButtonThemeData(style: ctaStyle),
                    elevatedButtonTheme: ElevatedButtonThemeData(
                      style: ctaStyle,
                    ),
                    switchTheme: SwitchThemeData(
                      thumbColor: WidgetStatePropertyAll(accent),
                      trackColor: WidgetStateProperty.resolveWith(
                        (states) => states.contains(WidgetState.selected)
                            ? accent.withValues(alpha: 0.5)
                            : null,
                      ),
                    ),
                    progressIndicatorTheme: ProgressIndicatorThemeData(
                      color: accent,
                    ),
                    textSelectionTheme: TextSelectionThemeData(
                      cursorColor: accent,
                      selectionColor: accent.withValues(alpha: 0.4),
                      selectionHandleColor: accent,
                    ),
                  ),
                  child: AppTextScaleScope(child: child!),
                );
              },
              routerConfig: _router,
            );
          },
        );
      },
    );
  }
}
