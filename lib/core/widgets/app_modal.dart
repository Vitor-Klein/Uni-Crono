import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_tokens.dart';

/// Data model for a single item in [showAppModal].
class AppModalItem {
  final String title;
  final String subtitle;
  final Widget icon;
  final VoidCallback onTap;

  /// Whether to render a divider below this item.
  final bool showDivider;

  const AppModalItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.showDivider = true,
  });
}

/// Shows a blurred modal bottom sheet with a list of [AppModalItem]s, grouped
/// in a white rounded card, each with its icon on a soft gold badge.
///
/// [backgroundColor] overrides the default `colorScheme.surface` of the
/// sheet behind the card.
///
/// Example:
/// ```dart
/// showAppModal(
///   context,
///   title: 'MORE',
///   items: [
///     AppModalItem(
///       title: 'SHARE',
///       subtitle: 'Send this app to a friend',
///       icon: const Icon(Icons.share_outlined),
///       onTap: () => Share.share(...),
///     ),
///   ],
/// );
/// ```
void showAppModal(
  BuildContext context, {
  required String title,
  required List<AppModalItem> items,
  Color? backgroundColor,
  WidgetBuilder? footerBuilder,
}) {
  HapticFeedback.selectionClick();
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: ConstrainedBox(
        // Caps the sheet's height instead of letting it grow past the
        // viewport — on short viewports (landscape phones) the content
        // would otherwise overflow the bottom instead of scrolling.
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(ctx).size.height * 0.9,
        ),
        child: DecoratedBox(
          decoration: _sheetDecoration(ctx, backgroundColor),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.xl,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const _Handle(),
                    _ModalTitle(title),
                    const SizedBox(height: AppSpacing.lg),
                    _ItemsCard(items: items),
                    if (footerBuilder != null) ...[
                      const SizedBox(height: AppSpacing.xl),
                      footerBuilder(ctx),
                    ],
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

// ─── Private helpers ──────────────────────────────────────────────────────────

BoxDecoration _sheetDecoration(BuildContext context, Color? backgroundColor) {
  final cs = Theme.of(context).colorScheme;
  return BoxDecoration(
    color: backgroundColor ?? cs.surface,
    borderRadius: const BorderRadius.vertical(
      top: Radius.circular(AppRadii.xl),
    ),
    boxShadow: AppShadows.lg,
  );
}

class _Handle extends StatelessWidget {
  const _Handle();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.lg),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: cs.outlineVariant,
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
        child: const SizedBox(width: AppSpacing.xxxl, height: AppSpacing.xs),
      ),
    );
  }
}

class _ModalTitle extends StatelessWidget {
  const _ModalTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      header: true,
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          letterSpacing: 2,
        ),
      ),
    );
  }
}

/// The items in one white rounded card, split by thin dividers.
class _ItemsCard extends StatelessWidget {
  const _ItemsCard({required this.items});

  final List<AppModalItem> items;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(AppRadii.xl);
    return DecoratedBox(
      decoration: BoxDecoration(borderRadius: radius, boxShadow: AppShadows.md),
      // The items' ink (ListTile splash) paints on this Material, above the
      // card's color.
      child: Material(
        color: cs.surfaceContainerLowest,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            for (final (i, item) in items.indexed) ...[
              _Item(item: item),
              if (item.showDivider && i < items.length - 1)
                Divider(
                  height: 1,
                  indent: AppSpacing.lg + _Item.badgeSize + AppSpacing.lg,
                  color: cs.outlineVariant,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.item});

  final AppModalItem item;

  static const double badgeSize = 44;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      leading: DecoratedBox(
        decoration: BoxDecoration(
          color: cs.primaryContainer.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
        child: SizedBox.square(
          dimension: badgeSize,
          child: IconTheme(
            data: IconThemeData(color: cs.onPrimaryContainer),
            child: item.icon,
          ),
        ),
      ),
      title: Text(
        item.title,
        style: theme.textTheme.labelLarge?.copyWith(
          color: cs.onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.xs),
        child: Text(
          item.subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: cs.onSurfaceVariant,
          ),
        ),
      ),
      trailing: Icon(Icons.chevron_right_outlined, color: cs.onSurfaceVariant),
      onTap: () {
        Navigator.pop(context);
        item.onTap();
      },
    );
  }
}
