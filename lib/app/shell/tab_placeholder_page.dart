import 'package:flutter/material.dart';

import '../../core/theme/app_tokens.dart';

/// Body of a tab whose screen is not built yet: just the tab title.
class TabPlaceholderPage extends StatelessWidget {
  const TabPlaceholderPage({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenGutter),
      children: [Text(title, style: Theme.of(context).textTheme.headlineSmall)],
    );
  }
}
