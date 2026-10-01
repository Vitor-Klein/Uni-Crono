import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:uni_cronos/app/shell/app_shell.dart';
import 'package:uni_cronos/core/navigation/app_routes.dart';
import 'package:uni_cronos/features/auth/presentation/session_cubit.dart';

import 'app_harness.dart';

void main() {
  testWidgets('CA-01: without a saved session, after the splash the app is '
      'on /login with no bottom bar', (tester) async {
    await pumpRoutedApp(tester, signedIn: false);

    expect(currentPath(), AppRoutes.login);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('CA-05: with a saved session, after the splash the app is on '
      '/dashboard', (tester) async {
    await pumpRoutedApp(tester);

    expect(currentPath(), AppRoutes.dashboard);
  });

  testWidgets('CA-07: signing out clears the session and goes to /login', (
    tester,
  ) async {
    await pumpRoutedApp(tester);

    await tester.element(find.byType(AppShell)).read<SessionCubit>().signOut();
    await tester.pumpAndSettle();

    expect(currentPath(), AppRoutes.login);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.containsKey('session_email'), isFalse);
  });
}
