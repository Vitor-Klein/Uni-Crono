import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

class UpgradeRequiredPage extends StatelessWidget {
  const UpgradeRequiredPage({required this.onUpdate, super.key});

  final VoidCallback onUpdate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                  child: Column(
                    children: [
                      const Spacer(),
                      Icon(
                        Icons.system_update_rounded,
                        size: MediaQuery.textScalerOf(context).scale(64),
                        color: colorScheme.onSurface,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        l10n.upgradeRequiredTitle,
                        textAlign: TextAlign.center,
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        l10n.upgradeRequiredBody,
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium,
                      ),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: onUpdate,
                          child: Text(l10n.upgradeNowButton),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
