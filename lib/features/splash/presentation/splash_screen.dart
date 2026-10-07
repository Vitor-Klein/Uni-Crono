import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:next_core_service/next_core_service.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/theme/template_theme_provider.dart';

/// The splash image, which zooms in as it fades in, then the app opens.
class SplashScreen extends StatefulWidget {
  const SplashScreen({this.duration = const Duration(seconds: 3), super.key});

  /// How long the splash stays before opening the app.
  final Duration duration;

  /// The zoom applied to the image.
  static const zoomKey = ValueKey('splash-zoom');

  /// Size the image starts at, before it grows to full size.
  static const double startScale = 0.85;

  static const zoomDuration = Duration(milliseconds: 1200);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(widget.duration);

      if (!mounted) return;

      context.go(AppRoutes.dashboard);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: TemplateBrandColors.splashBackground,
      body: SizedBox.expand(
        child: TweenAnimationBuilder<double>(
          // With reduced animations the image starts where the zoom ends.
          tween: Tween(begin: isAnimationDisabled(context) ? 1 : 0, end: 1),
          duration: SplashScreen.zoomDuration,
          curve: Curves.easeOutCubic,
          builder: (context, t, child) => Opacity(
            opacity: t,
            child: Transform.scale(
              key: SplashScreen.zoomKey,
              scale:
                  SplashScreen.startScale + (1 - SplashScreen.startScale) * t,
              child: child,
            ),
          ),
          child: Image.asset('assets/splash_uni_cronos.png', fit: BoxFit.cover),
        ),
      ),
    );
  }
}
