import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../presentation/logic/admin_notifications_provider.dart';

class AdminNotificationsScreen extends ConsumerWidget {
  const AdminNotificationsScreen({super.key});

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Convert an absolute UTC timestamp to a relative "X ago" string.
  String _timeAgo(DateTime utc) {
    final now = DateTime.now().toUtc();
    final diff = now.difference(utc);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return DateFormat('dd MMM yyyy').format(utc.toLocal());
  }

  /// Pick an icon based on notification type.
  IconData _iconFor(String type) {
    switch (type) {
      case 'new_issue':
        return Icons.add_circle_outline_rounded;
      case 'closure':
        return Icons.check_circle_outline_rounded;
      default:
        return Icons.notifications_outlined;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminNotificationsProvider);
    final notifier = ref.read(adminNotificationsProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (state.unreadCount > 0)
            TextButton.icon(
              onPressed: () => notifier.markAllAsRead(),
              icon: const Icon(Icons.done_all, color: Colors.white, size: 18),
              label: const Text(
                'Mark all read',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
        ],
      ),
      body: Builder(
        builder: (context) {
          // Loading state
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error state
          if (state.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                    const SizedBox(height: 12),
                    Text(
                      state.error!,
                      style: const TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => notifier.fetchNotifications(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Empty state
          if (state.notifications.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_none_rounded, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    'No notifications yet.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'New issues and closures will appear here.',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // Notifications list
          return RefreshIndicator(
            onRefresh: () => notifier.fetchNotifications(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.notifications.length,
              itemBuilder: (context, index) {
                final notif = state.notifications[index];
                final bool isUnread = !notif.isRead;

                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isUnread
                          ? const Color(0xFF2E7D32).withValues(alpha: 0.15)
                          : Colors.grey.withValues(alpha: 0.05),
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF2E7D32)
                          .withValues(alpha: isUnread ? 0.15 : 0.05),
                      child: Icon(
                        _iconFor(notif.type),
                        color: isUnread ? const Color(0xFF2E7D32) : Colors.grey,
                      ),
                    ),
                    title: Text(
                      notif.title,
                      style: TextStyle(
                        fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 3),
                        Text(notif.subtitle, style: const TextStyle(fontSize: 13)),
                        const SizedBox(height: 4),
                        Text(
                          _timeAgo(notif.createdAt.toUtc()),
                          style: TextStyle(
                            fontSize: 12,
                            color: isUnread ? const Color(0xFFE64A19) : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    trailing: isUnread
                        ? Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Color(0xFF2E7D32),
                              shape: BoxShape.circle,
                            ),
                          )
                        : null,
                    onTap: () async {
                      // Capture router and issueId BEFORE any await.
                      // After markAsRead() updates state, the list rebuilds
                      // and this item's BuildContext gets unmounted, making
                      // context.mounted false. The router instance is safe
                      // to use after the await because it is app-level.
                      final router = GoRouter.of(context);
                      final targetIssueId = notif.issueId;

                      // Mark as read (preserves existing read behavior).
                      if (isUnread) {
                        await notifier.markAsRead(notif.id);
                      }

                      // Navigate to the exact existing issue detail screen.
                      if (targetIssueId.isNotEmpty) {
                        router.go('/admin/issues/$targetIssueId');
                      }
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
