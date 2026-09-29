import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

/// Shows a blurred modal bottom sheet with a list of [AppModalItem]s.
///
/// The blur, border, border-radius and handle are fixed.
/// [backgroundColor] overrides the default `colorScheme.surface` — useful
/// when the template uses a branded color instead of the theme surface.
///
/// Example:
/// ```dart
/// showAppModal(
///   context,
///   title: 'MORE',
///   backgroundColor: Color(0xDD1a1a2e), // optional branded override
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
        child: Container(
          decoration: _modalDecoration(ctx, backgroundColor),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          // The items' ink (ListTile splash) paints on the nearest Material.
          // Without this one, that is the sheet's own Material, below the
          // decoration above — so every tap feedback would be hidden by it.
          child: Material(
            type: MaterialType.transparency,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHandle(ctx),
                  _buildModalTitle(ctx, title),
                  const SizedBox(height: 25),
                  ...items.map((item) => _buildItem(ctx, item)),
                  if (footerBuilder != null) ...[
                    const SizedBox(height: 12),
                    Divider(
                      color: Theme.of(
                        ctx,
                      ).colorScheme.outlineVariant.withValues(alpha: 0.5),
                      height: 1,
                      indent: 40,
                      endIndent: 40,
                    ),
                    const SizedBox(height: 10),
                    footerBuilder(ctx),
                  ],
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

// ─── Private helpers ──────────────────────────────────────────────────────────

BoxDecoration _modalDecoration(BuildContext context, [Color? backgroundColor]) {
  final cs = Theme.of(context).colorScheme;
  return BoxDecoration(
    color: backgroundColor ?? cs.surface.withValues(alpha: 0.95),
    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
    border: Border.all(color: cs.outline.withValues(alpha: 0.12), width: 1),
  );
}

Widget _buildHandle(BuildContext context) => Container(
  margin: const EdgeInsets.only(top: 8, bottom: 12),
  width: 40,
  height: 4,
  decoration: BoxDecoration(
    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.24),
    borderRadius: BorderRadius.circular(2),
  ),
);

Widget _buildModalTitle(BuildContext context, String text) => Text(
  text,
  style: Theme.of(context).textTheme.labelSmall?.copyWith(
    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54),
    fontWeight: FontWeight.w600,
    letterSpacing: 3.0,
  ),
);

Widget _buildItem(BuildContext ctx, AppModalItem item) {
  final cs = Theme.of(ctx).colorScheme;
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        leading: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: cs.onSurface.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconTheme(
            data: IconThemeData(color: cs.onSurface),
            child: item.icon,
          ),
        ),
        title: Text(
          item.title,
          style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
            color: cs.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          item.subtitle,
          style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.5),
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: cs.onSurface.withValues(alpha: 0.24),
          size: 20,
        ),
        onTap: () {
          Navigator.pop(ctx);
          item.onTap();
        },
      ),
      if (item.showDivider)
        Divider(color: cs.outlineVariant, height: 1, indent: 70),
    ],
  );
}
