import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/navigation/app_routes.dart';
import '../core/navigation/app_transitions.dart';
import '../core/navigation/stream_listenable.dart';
import '../core/webview/web_view_page.dart';
import '../core/webview/webview_args.dart';
import '../features/auth/presentation/login_page.dart';
import '../features/auth/presentation/session_cubit.dart';
import '../features/hours/presentation/dashboard_page.dart';
import '../features/splash/presentation/splash_screen.dart';
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
        StatefulShellRoute.indexedStack(
          pageBuilder: (context, state, navigationShell) => AppTransitions.fade(
            context: context,
            state: state,
            child: AppShell(navigationShell: navigationShell),
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
            for (final (path, title)
                in <(String, String Function(AppLocalizations))>[
                  (AppRoutes.upload, (l) => l.navUpload),
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
  /// a session only /login is reachable; with one, /login goes to the
  /// dashboard.
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

    if (!signedIn) {
      return location == AppRoutes.login ? null : AppRoutes.login;
    }
    return location == AppRoutes.login ? AppRoutes.dashboard : null;
  }
}
