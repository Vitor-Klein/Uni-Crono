import 'dart:async';

import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/app_bootstrap.dart';
import 'app/app_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final bootstrap = await AppBootstrap.initialize();

  runApp(
    AppProviders(
      initialSession: bootstrap.session,
      child: MyApp(firebaseWarningMessage: bootstrap.firebaseWarningMessage),
    ),
  );

  unawaited(
    AppBootstrap.runDeferred(
      firebaseInitialized: bootstrap.firebaseInitialized,
    ),
  );
}
