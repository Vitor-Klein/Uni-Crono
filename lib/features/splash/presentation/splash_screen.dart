import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/theme/template_theme_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({this.duration = const Duration(seconds: 3), super.key});

  /// How long the splash stays before opening the app.
  final Duration duration;

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
        child: Image.asset('assets/splash.png', fit: BoxFit.cover),
      ),
    );
  }
}
