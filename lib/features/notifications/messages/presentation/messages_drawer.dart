import 'dart:ui' show ImageFilter;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/app_routes.dart';
import '../../../../core/theme/template_theme_provider.dart';
import '../../../../core/utils/url_utils.dart';
import '../../../../core/webview/webview_args.dart';
import '../data/shared_preferences_message_repository.dart';
import '../domain/message_repository.dart';
import 'messages_drawer_body.dart';
import 'messages_drawer_header.dart';

/// Opens the messages drawer as a modal bottom sheet.
Future<void> openMessagesDrawer(
  BuildContext context, {
  Color? backgroundColor,
  MessageRepository? repository,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: TemplateOverlayColors.scrim,
    builder: (_) => MessagesDrawerSheet(
      backgroundColor: backgroundColor,
      repository: repository,
    ),
  );
}

/// Draggable modal sheet that lists locally stored push notifications.
class MessagesDrawerSheet extends StatefulWidget {
  const MessagesDrawerSheet({
    super.key,
    this.title,
    this.backgroundColor,
    this.repository,
  });

  final String? title;
  final Color? backgroundColor;
  final MessageRepository? repository;

  @override
  State<MessagesDrawerSheet> createState() => _MessagesDrawerSheetState();
}

class _MessagesDrawerSheetState extends State<MessagesDrawerSheet> {
  bool _loading = true;
  MessageFilter _filter = MessageFilter.all;
  final List<StoredPushMessage> _items = [];

  MessageRepository get _repository =>
      widget.repository ?? const SharedPreferencesMessageRepository();

  int get _unreadCount => _items.where((i) => !i.message.read).length;

  List<StoredPushMessage> get _visibleItems => _filter == MessageFilter.all
      ? _items
      : _items.where((i) => !i.message.read).toList();

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    setState(() => _loading = true);

    final loaded = await _repository.loadMessages();
    if (!mounted) return;

    setState(() {
      _items
        ..clear()
        ..addAll(loaded);
      _loading = false;
    });
  }

  Future<void> _delete(StoredPushMessage item) async {
    await _repository.deleteMessage(item);
    if (!mounted) return;
    setState(() => _items.removeWhere((i) => i.id == item.id));
  }

  Future<void> _clearAll() async {
    await _repository.clearMessages();
    if (!mounted) return;
    setState(() => _items.clear());
  }

  /// Always marks [item] as read. If it has a link, opens it:
  /// - Mobile: closes the drawer and navigates to the in-app WebViewPage —
  ///   capturing the router *before* popping, because the card's
  ///   BuildContext belongs to this sheet's subtree and doesn't survive the
  ///   pop.
  /// - Web: `webview_flutter` has no web implementation
  ///   (`WebViewController()` throws there), so the link opens in a new
  ///   browser tab instead and the drawer stays open, same as a
  ///   link-less message.
  Future<void> _open(StoredPushMessage item) async {
    final updated = await _repository.markAsRead(item);
    if (!mounted) return;

    final hasLink = item.message.link.isNotEmpty;

    if (hasLink && !kIsWeb) {
      final router = GoRouter.of(context);
      Navigator.pop(context);
      router.push(
        AppRoutes.webview,
        extra: WebViewArgs(url: item.message.link, title: item.message.title),
      );
      return;
    }

    if (hasLink) {
      await launchExternalUrl(item.message.link);
    }

    final index = _items.indexWhere((i) => i.id == item.id);
    if (index == -1) return;
    setState(() => _items[index] = updated);
  }

  Future<void> _markAllAsRead() async {
    await _repository.markAllAsRead();
    if (!mounted) return;
    await _loadMessages();
  }

  void _setFilter(MessageFilter filter) => setState(() => _filter = filter);

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: SafeArea(
        top: false,
        child: DraggableScrollableSheet(
          initialChildSize: 0.68,
          minChildSize: 0.35,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            final cs = Theme.of(context).colorScheme;
            return Container(
              decoration: BoxDecoration(
                color:
                    widget.backgroundColor ??
                    cs.surface.withValues(alpha: 0.97),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(22),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  const _DrawerHandle(),
                  const SizedBox(height: 8),
                  MessagesDrawerHeader(
                    title: widget.title,
                    hasMessages: _items.isNotEmpty,
                    unreadCount: _unreadCount,
                    filter: _filter,
                    onFilterChanged: _setFilter,
                    onClearAll: _clearAll,
                    onMarkAllAsRead: _markAllAsRead,
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: MessagesDrawerBody(
                      loading: _loading,
                      items: _visibleItems,
                      hasAnyMessages: _items.isNotEmpty,
                      showingUnreadFilter: _filter == MessageFilter.unread,
                      scrollController: scrollController,
                      onRefresh: _loadMessages,
                      onDelete: _delete,
                      onOpen: _open,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DrawerHandle extends StatelessWidget {
  const _DrawerHandle();

  @override
  Widget build(BuildContext context) => Container(
    width: 44,
    height: 5,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.24),
      borderRadius: BorderRadius.circular(999),
    ),
  );
}
