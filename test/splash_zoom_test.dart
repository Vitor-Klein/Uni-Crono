import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:uni_cronos/core/navigation/app_routes.dart';
import 'package:uni_cronos/features/splash/presentation/splash_screen.dart';

import 'app_harness.dart';

const _splash = Duration(seconds: 3);

/// Scale and opacity of the splash image right now.
(double, double) _zoom(WidgetTester tester) {
  final transform = tester.widget<Transform>(find.byKey(SplashScreen.zoomKey));
  final opacity = tester.widget<Opacity>(
    find.ancestor(
      of: find.byKey(SplashScreen.zoomKey),
      matching: find.byType(Opacity),
    ),
  );
  return (transform.transform.entry(0, 0), opacity.opacity);
}

Future<void> _finishSplash(WidgetTester tester) async {
  await tester.pump(_splash);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('CA-01: the splash image zooms in from 85% and fades in over '
      '1.2 s', (tester) async {
    await pumpRoutedApp(tester, splashDuration: _splash, settle: false);
    await tester.pump();

    final (startScale, startOpacity) = _zoom(tester);
    expect(startScale, closeTo(0.85, 0.01));
    expect(startOpacity, closeTo(0, 0.01));

    await tester.pump(const Duration(milliseconds: 1200));

    final (endScale, endOpacity) = _zoom(tester);
    expect(endScale, closeTo(1, 0.001));
    expect(endOpacity, closeTo(1, 0.001));

    await _finishSplash(tester);
  });

  testWidgets('CA-02: with reduced animations the image is whole from the '
      'first frame', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

    await pumpRoutedApp(tester, splashDuration: _splash, settle: false);
    await tester.pump();

    final (scale, opacity) = _zoom(tester);
    expect(scale, 1);
    expect(opacity, 1);

    await _finishSplash(tester);
  });

  testWidgets('CA-03: after the splash time the app still goes to the '
      'dashboard', (tester) async {
    await pumpRoutedApp(tester, splashDuration: _splash, settle: false);
    await tester.pump();

    await _finishSplash(tester);

    expect(currentPath(), AppRoutes.dashboard);
  });

  testWidgets('CA-03: without a saved session, after the splash the app goes '
      'to the login', (tester) async {
    await pumpRoutedApp(
      tester,
      signedIn: false,
      splashDuration: _splash,
      settle: false,
    );
    await tester.pump();

    await _finishSplash(tester);

    expect(currentPath(), AppRoutes.login);
  });
}
