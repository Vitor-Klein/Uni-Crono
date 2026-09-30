import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:next_widgets_service/next_widgets_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/theme/app_tokens.dart';
import '../../features/home/presentation/home_more_modal.dart';
import '../../features/notifications/presentation/notifications_cubit.dart';
import '../../features/profile/domain/demo_student.dart';
import '../../l10n/app_localizations.dart';
import '../app_info.dart';

/// App bar of the shell: the brand, and the student's avatar, which opens the
/// More modal (messages, settings, share/legal, app version).
class ShellAppBar extends StatefulWidget implements PreferredSizeWidget {
  const ShellAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

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
      onNotificationsTap: () {},
      appNameLabel: kAppName,
      appVersionLabel: _versionLabel,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return NextAppBar(
      title: kAppName,
      showLeading: false,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.lg),
          child: Semantics(
            button: true,
            label: AppLocalizations.of(context)!.shellMenuSemantics,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: _openMore,
              child: CircleAvatar(
                radius: 18,
                backgroundColor: cs.primaryContainer,
                child: Text(
                  DemoStudent.initials,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onPrimaryContainer,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
