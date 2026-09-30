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
      ),
      AppRoutes.upgradeRequired,
    );
    expect(
      AppRouter.resolveRedirect(
        location: AppRoutes.splash,
        enforceUpgradeGate: true,
        shouldBlock: true,
      ),
      isNull,
    );
  });
}
