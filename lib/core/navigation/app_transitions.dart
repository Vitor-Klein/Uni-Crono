import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:next_core_service/next_core_service.dart';

import '../system_ui/hidden_nav_bar.dart';

/// go_router `Page` factory for the shared fade transition.
abstract final class AppTransitions {
  static Page<T> fade<T>({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
    bool hideNavBar = false,
  }) {
    final wrapped = hideNavBar ? HiddenNavBar(child: child) : child;

    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: wrapped,
      transitionDuration: kIsWeb
          ? const Duration(milliseconds: 420)
          : const Duration(milliseconds: 800),
      reverseTransitionDuration: kIsWeb
          ? const Duration(milliseconds: 280)
          : const Duration(milliseconds: 500),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        if (isAnimationDisabled(context)) {
          return child;
        }

        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
          reverseCurve: Curves.easeIn,
        );
        final fade = Tween<double>(
          begin: kIsWeb ? 0.35 : 0.0,
          end: 1.0,
        ).animate(curved);

        return FadeTransition(opacity: fade, child: child);
      },
    );
  }
}
