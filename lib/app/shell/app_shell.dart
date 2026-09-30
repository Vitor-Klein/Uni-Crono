import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';

/// Frame of the signed-in app: the current tab and the bottom navigation.
class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        backgroundColor: cs.surfaceContainerLowest,
        indicatorColor: cs.primaryContainer,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            label: l10n.navDashboard,
          ),
          NavigationDestination(
            icon: const Icon(Icons.upload_file_outlined),
            label: l10n.navUpload,
          ),
          NavigationDestination(
            icon: const Icon(Icons.explore_outlined),
            label: l10n.navActivities,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            label: l10n.navProfile,
          ),
        ],
      ),
    );
  }
}
