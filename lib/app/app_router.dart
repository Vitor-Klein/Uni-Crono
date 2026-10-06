import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/navigation/app_routes.dart';
import '../core/navigation/app_transitions.dart';
import '../core/navigation/stream_listenable.dart';
import '../core/webview/web_view_page.dart';
import '../core/webview/webview_args.dart';
import '../features/auth/presentation/login_page.dart';
import '../features/auth/presentation/session_cubit.dart';
import '../features/auth/presentation/sign_up_page.dart';
import '../features/hours/presentation/dashboard_page.dart';
import '../features/splash/presentation/splash_screen.dart';
import '../features/upload/data/certificate_launcher.dart';
import '../features/upload/data/certificate_picker.dart';
import '../features/upload/presentation/manual_entry_page.dart';
import '../features/upload/presentation/upload_cubit.dart';
import '../features/upload/presentation/upload_page.dart';
import '../features/upgrade/domain/upgrade_gate_controller.dart';
import '../features/upgrade/presentation/upgrade_required_page.dart';
import '../l10n/app_localizations.dart';
import 'shell/app_shell.dart';
import 'shell/tab_placeholder_page.dart';

class AppRouter {
  AppRouter._();

  static final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  static final navigatorKey = GlobalKey<NavigatorState>();

  static GoRouter build({
    required bool enforceUpgradeGate,
    required UpgradeGateController upgradeGate,
    required SessionCubit session,
    Duration splashDuration = const Duration(seconds: 3),
  }) {
    return GoRouter(
      navigatorKey: navigatorKey,
      initialLocation: AppRoutes.splash,
      refreshListenable: Listenable.merge([
        upgradeGate,
        StreamListenable(session.stream),
      ]),
      redirect: (context, state) => resolveRedirect(
        location: state.matchedLocation,
        enforceUpgradeGate: enforceUpgradeGate,
        shouldBlock: upgradeGate.shouldBlock,
        signedIn: session.state != null,
      ),
      routes: [
        GoRoute(
          path: AppRoutes.splash,
          pageBuilder: (context, state) => AppTransitions.fade(
            context: context,
            state: state,
            hideNavBar: true,
            child: SplashScreen(duration: splashDuration),
          ),
        ),
        GoRoute(
          path: AppRoutes.login,
          pageBuilder: (context, state) => AppTransitions.fade(
            context: context,
            state: state,
            child: const LoginPage(),
          ),
        ),
        GoRoute(
          path: AppRoutes.signup,
          pageBuilder: (context, state) => AppTransitions.fade(
            context: context,
            state: state,
            child: const SignUpPage(),
          ),
        ),
        StatefulShellRoute.indexedStack(
          pageBuilder: (context, state, navigationShell) => AppTransitions.fade(
            context: context,
            state: state,
            // One Upload state for the whole shell: the form at
            // /upload/manual works on the file chosen at /upload, and signing
            // out (which leaves the shell) drops it.
            child: BlocProvider(
              create: (context) => UploadCubit(
                context.read<CertificatePicker>(),
                context.read<CertificateLauncher>(),
              ),
              child: AppShell(navigationShell: navigationShell),
            ),
          ),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.dashboard,
                  builder: (context, state) => const DashboardPage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.upload,
                  builder: (context, state) => const UploadPage(),
                  routes: [
                    GoRoute(
                      path: 'manual',
                      builder: (context, state) => const ManualEntryPage(),
                    ),
                  ],
                ),
              ],
            ),
            for (final (path, title)
                in <(String, String Function(AppLocalizations))>[
                  (AppRoutes.activities, (l) => l.navActivities),
                  (AppRoutes.profile, (l) => l.navProfile),
                ])
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: path,
                    builder: (context, state) => TabPlaceholderPage(
                      key: ValueKey(path),
                      title: title(AppLocalizations.of(context)!),
                    ),
                  ),
                ],
              ),
          ],
        ),
        GoRoute(
          path: AppRoutes.upgradeRequired,
          pageBuilder: (context, state) => AppTransitions.fade(
            context: context,
            state: state,
            hideNavBar: true,
            child: UpgradeRequiredPage(onUpdate: upgradeGate.onUpdate),
          ),
        ),
        GoRoute(
          path: AppRoutes.webview,
          pageBuilder: (context, state) {
            final args = state.extra! as WebViewArgs;
            return AppTransitions.fade(
              context: context,
              state: state,
              hideNavBar: true,
              child: WebViewPage(url: args.url, title: args.title),
            );
          },
        ),
      ],
    );
  }

  /// Where to send [location], or null to stay. Order: the splash always
  /// completes its run; a blocking upgrade gate wins over everything; without
  /// a session only /login and /signup are reachable; with one, both go to
  /// the dashboard.
  /// The routes only for who is signed out.
  static const _publicRoutes = {AppRoutes.login, AppRoutes.signup};

  static String? resolveRedirect({
    required String location,
    required bool enforceUpgradeGate,
    required bool shouldBlock,
    required bool signedIn,
  }) {
    if (location == AppRoutes.splash) return null;

    if (enforceUpgradeGate) {
      if (shouldBlock) {
        return location == AppRoutes.upgradeRequired
            ? null
            : AppRoutes.upgradeRequired;
      }
      if (location == AppRoutes.upgradeRequired) {
        return signedIn ? AppRoutes.dashboard : AppRoutes.login;
      }
    }

    final isPublic = _publicRoutes.contains(location);
    if (!signedIn) return isPublic ? null : AppRoutes.login;
    return isPublic ? AppRoutes.dashboard : null;
  }
}
