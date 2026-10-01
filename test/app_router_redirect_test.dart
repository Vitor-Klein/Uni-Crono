import 'package:flutter_test/flutter_test.dart';

import 'package:uni_cronos/app/app_router.dart';
import 'package:uni_cronos/core/navigation/app_routes.dart';

void main() {
  test('CA-06: once the upgrade gate releases, /upgrade-required goes to '
      '/dashboard', () {
    expect(
      AppRouter.resolveRedirect(
        location: AppRoutes.upgradeRequired,
        enforceUpgradeGate: true,
        shouldBlock: false,
        signedIn: true,
      ),
      AppRoutes.dashboard,
    );
  });

  test('CA-06: a blocking gate still sends everything but the splash to '
      '/upgrade-required', () {
    expect(
      AppRouter.resolveRedirect(
        location: AppRoutes.dashboard,
        enforceUpgradeGate: true,
        shouldBlock: true,
        signedIn: true,
      ),
      AppRoutes.upgradeRequired,
    );
    expect(
      AppRouter.resolveRedirect(
        location: AppRoutes.splash,
        enforceUpgradeGate: true,
        shouldBlock: true,
        signedIn: true,
      ),
      isNull,
    );
  });

  test('CA-06: without a blocking gate, or with the gate off, a tab path '
      'stays where it is', () {
    for (final enforce in [true, false]) {
      expect(
        AppRouter.resolveRedirect(
          location: AppRoutes.dashboard,
          enforceUpgradeGate: enforce,
          shouldBlock: false,
          signedIn: true,
        ),
        isNull,
      );
    }
    expect(
      AppRouter.resolveRedirect(
        location: AppRoutes.upgradeRequired,
        enforceUpgradeGate: true,
        shouldBlock: true,
        signedIn: true,
      ),
      isNull,
    );
  });

  test('CA-01: without a session, every shell path goes to /login', () {
    for (final path in [
      AppRoutes.dashboard,
      AppRoutes.upload,
      AppRoutes.activities,
      AppRoutes.profile,
    ]) {
      expect(
        AppRouter.resolveRedirect(
          location: path,
          enforceUpgradeGate: true,
          shouldBlock: false,
          signedIn: false,
        ),
        AppRoutes.login,
        reason: path,
      );
    }
  });

  test('CA-01: without a session, the splash and /login stay where they '
      'are', () {
    for (final path in [AppRoutes.splash, AppRoutes.login]) {
      expect(
        AppRouter.resolveRedirect(
          location: path,
          enforceUpgradeGate: true,
          shouldBlock: false,
          signedIn: false,
        ),
        isNull,
        reason: path,
      );
    }
  });

  test('CA-06: with a session, /login goes to /dashboard', () {
    expect(
      AppRouter.resolveRedirect(
        location: AppRoutes.login,
        enforceUpgradeGate: true,
        shouldBlock: false,
        signedIn: true,
      ),
      AppRoutes.dashboard,
    );
  });

  test('CA-09: a blocking gate wins over the session, signed in or not', () {
    for (final signedIn in [true, false]) {
      expect(
        AppRouter.resolveRedirect(
          location: AppRoutes.login,
          enforceUpgradeGate: true,
          shouldBlock: true,
          signedIn: signedIn,
        ),
        AppRoutes.upgradeRequired,
        reason: 'signedIn: $signedIn',
      );
    }
  });

  test('CA-09: when the gate releases without a session, /upgrade-required '
      'goes to /login', () {
    expect(
      AppRouter.resolveRedirect(
        location: AppRoutes.upgradeRequired,
        enforceUpgradeGate: true,
        shouldBlock: false,
        signedIn: false,
      ),
      AppRoutes.login,
    );
  });
}
