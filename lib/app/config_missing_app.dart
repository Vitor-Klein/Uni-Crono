import 'package:flutter/material.dart';

import '../core/theme/app_tokens.dart';
import '../l10n/app_localizations.dart';

/// Shown instead of the app when the build has no server settings, so a
/// missing `--dart-define-from-file` is a message and not a black screen.
class ConfigMissingApp extends StatelessWidget {
  const ConfigMissingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: const Locale('pt'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) => Scaffold(
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.screenGutter),
                child: Text(
                  AppLocalizations.of(context)!.configMissingMessage,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
