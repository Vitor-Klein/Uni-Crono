import 'dart:async';

import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/app_bootstrap.dart';
import 'app/app_providers.dart';
import 'app/config_missing_app.dart';
import 'core/config/app_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!AppConfig.isConfigured) {
    runApp(const ConfigMissingApp());
    return;
  }

  final bootstrap = await AppBootstrap.initialize();
  await AppBootstrap.connectAccountServer();

  runApp(
    AppProviders(
      child: MyApp(firebaseWarningMessage: bootstrap.firebaseWarningMessage),
    ),
  );

  unawaited(
    AppBootstrap.runDeferred(
      firebaseInitialized: bootstrap.firebaseInitialized,
    ),
  );
}
