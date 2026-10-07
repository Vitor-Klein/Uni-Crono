import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/theme/app_tokens.dart';
import '../../features/home/presentation/home_more_modal.dart';
import '../../features/notifications/presentation/notifications_cubit.dart';
import '../../features/notifications/presentation/open_notifications_sheet.dart';
import '../../features/profile/presentation/profile_cubit.dart';
import '../../l10n/app_localizations.dart';
import '../app_info.dart';

/// Header of the shell: the cap badge and the brand, left-aligned, and the
/// student's avatar, which opens the More modal (messages, settings,
/// share/legal, app version).
///
/// Built without `AppBar`: `NextAppBar` only centers a plain title, and the
/// brand here sits at the left next to its badge.
class ShellAppBar extends StatefulWidget implements PreferredSizeWidget {
  const ShellAppBar({super.key});

  static const double height = 72;

  @override
  Size get preferredSize => const Size.fromHeight(height);

  @override
  State<ShellAppBar> createState() => _ShellAppBarState();
}

class _ShellAppBarState extends State<ShellAppBar> {
  // Empty until the bundle finishes loading: preferable to a hardcoded value
  // that could lie about the installed version.
  String _versionLabel = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (!mounted) return;
      setState(() => _versionLabel = 'v${info.version}+${info.buildNumber}');
    } catch (e) {
      debugPrint('Error loading package info: $e');
    }
  }

  void _openMore() {
    showHomeMoreModal(
      context,
      notificationsEnabled: context.read<NotificationsCubit>().state,
      onNotificationsTap: () => openNotificationsSheet(context),
      appNameLabel: kAppName,
      appVersionLabel: _versionLabel,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Material(
        color: cs.surface,
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: ShellAppBar.height,
            child: Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.screenGutter,
                right: AppSpacing.lg,
              ),
              child: Row(
                children: [
                  const _CapBadge(),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Semantics(header: true, child: const _Wordmark()),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _Avatar(onTap: _openMore),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The brand in two colors: the first word ("Uni") in dark blue, the rest
/// ("Cronos") in gold, large and bold. It scales down to fit a narrow header
/// rather than being cut short.
class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final space = kAppName.indexOf(' ');
    final style = theme.textTheme.headlineSmall?.copyWith(
      fontWeight: FontWeight.w700,
    );
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: kAppName.substring(0, space),
              style: style?.copyWith(color: cs.tertiary),
            ),
            TextSpan(
              text: kAppName.substring(space),
              style: style?.copyWith(color: cs.primaryFixedDim),
            ),
          ],
        ),
        maxLines: 1,
      ),
    );
  }
}

/// The brand mark: a filled dark-blue graduation cap on a round gold badge.
class _CapBadge extends StatelessWidget {
  const _CapBadge();

  static const double _size = 44;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ExcludeSemantics(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: cs.primaryContainer,
          shape: BoxShape.circle,
          boxShadow: AppShadows.sm,
        ),
        child: SizedBox.square(
          dimension: _size,
          child: Icon(Icons.school, color: cs.tertiary),
        ),
      ),
    );
  }
}

/// The student's avatar inside a gold ring: a 48dp target announced as
/// "Abrir menu".
class _Avatar extends StatelessWidget {
  const _Avatar({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Semantics(
      button: true,
      label: AppLocalizations.of(context)!.shellMenuSemantics,
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox.square(
          dimension: kMinInteractiveDimension,
          child: Center(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: cs.primaryContainer, width: 2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: CircleAvatar(
                  radius: 17,
                  backgroundColor: cs.surfaceContainerLow,
                  child: _Initials(
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: cs.primary,
                    ),
                    iconColor: cs.primary,
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

/// The student's initials once the profile is loaded; a person icon before.
class _Initials extends StatelessWidget {
  const _Initials({required this.style, required this.iconColor});

  final TextStyle? style;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileCubit>().state.profile;
    if (profile == null) return Icon(Icons.person_outline, color: iconColor);
    return Text(profile.initials, style: style);
  }
}
