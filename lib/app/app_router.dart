import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/navigation/app_routes.dart';
import '../core/navigation/app_transitions.dart';
import '../core/webview/web_view_page.dart';
import '../core/webview/webview_args.dart';
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
    Duration splashDuration = const Duration(seconds: 3),
  }) {
    return GoRouter(
      navigatorKey: navigatorKey,
      initialLocation: AppRoutes.splash,
      refreshListenable: upgradeGate,
      redirect: (context, state) => resolveRedirect(
        location: state.matchedLocation,
        enforceUpgradeGate: enforceUpgradeGate,
        shouldBlock: upgradeGate.shouldBlock,
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
        StatefulShellRoute.indexedStack(
          pageBuilder: (context, state, navigationShell) => AppTransitions.fade(
            context: context,
            state: state,
            child: AppShell(navigationShell: navigationShell),
          ),
          branches: [
            for (final (path, title)
                in <(String, String Function(AppLocalizations))>[
                  (AppRoutes.dashboard, (l) => l.navDashboard),
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

  /// Where to send [location], or null to stay. The splash always completes
  /// its run, with or without a pending gate — explicit decision, validated
  /// in device QA.
  static String? resolveRedirect({
    required String location,
    required bool enforceUpgradeGate,
    required bool shouldBlock,
  }) {
    if (!enforceUpgradeGate) return null;
    if (location == AppRoutes.splash) return null;

    if (shouldBlock) {
      return location == AppRoutes.upgradeRequired
          ? null
          : AppRoutes.upgradeRequired;
    }
    return location == AppRoutes.upgradeRequired ? AppRoutes.dashboard : null;
  }
}
