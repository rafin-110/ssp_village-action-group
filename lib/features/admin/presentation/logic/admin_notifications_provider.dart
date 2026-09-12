import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ---------------------------------------------------------------------------
// PHASE 25 — Admin Notifications Provider
// Shows two real event types:
//   1. New Issue Created  — read from the `issues` table (leader creates issue)
//   2. Issue Closed       — read from the `closure_notifications` table (leader closes)
//
// Read/unread for new-issue events is tracked locally in memory (Set of seen IDs)
// because the `issues` table has no is_read column.
// Read/unread for closure events is persisted in `closure_notifications.is_read`.
// ---------------------------------------------------------------------------

// Unified notification model used by the UI.
class AdminNotif {
  final String id;
  final String type; // 'new_issue' | 'closure'
  final String title;
  final String subtitle;
  final DateTime createdAt;
  bool isRead;
  /// The UUID of the related issue — used for tap-to-navigate.
  final String issueId;

  AdminNotif({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.createdAt,
    required this.isRead,
    required this.issueId,
  });
}

class AdminNotificationsState {
  final List<AdminNotif> notifications;
  final int unreadCount;
  final bool isLoading;
  final String? error;

  AdminNotificationsState({
    this.notifications = const [],
    this.unreadCount = 0,
    this.isLoading = false,
    this.error,
  });

  AdminNotificationsState copyWith({
    List<AdminNotif>? notifications,
    int? unreadCount,
    bool? isLoading,
    String? error,
  }) {
    return AdminNotificationsState(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AdminNotificationsNotifier extends StateNotifier<AdminNotificationsState> {
  // Tracks IDs of new-issue notifications the admin has tapped (local only).
  final Set<String> _locallyReadNewIssueIds = {};

  AdminNotificationsNotifier() : super(AdminNotificationsState()) {
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final client = Supabase.instance.client;
      final List<AdminNotif> merged = [];

      // ── 1. New issues (leader created) ─────────────────────────────────────
      // We simply read the `issues` table newest-first and treat each row as
      // a "New issue reported" notification. No schema change needed.
      try {
        final issuesResp = await client
            .from('issues')
            .select('id, title, created_at, leader:profiles!issues_leader_id_fkey(full_name), villages(name)')
            .order('created_at', ascending: false)
            .limit(30);

        for (final row in List<Map<String, dynamic>>.from(issuesResp)) {
          final id = row['id'] as String;
          final title = row['title'] as String? ?? 'Untitled issue';
          final leaderName = (row['leader'] as Map<String, dynamic>?)?['full_name'] as String? ?? 'A leader';
          final villageName = (row['villages'] as Map<String, dynamic>?)?['name'] as String? ?? 'a village';
          final createdAt = DateTime.parse(row['created_at'] as String);

          merged.add(AdminNotif(
            id: 'issue_$id',
            type: 'new_issue',
            title: 'New issue reported',
            subtitle: '"$title" by $leaderName from $villageName.',
            createdAt: createdAt,
            isRead: _locallyReadNewIssueIds.contains(id),
            issueId: id,
          ));
        }
      } catch (_) {
        // If this query fails, skip new-issue notifications gracefully.
      }

      // ── 2. Closure notifications (leader closed an issue) ──────────────────
      try {
        final closureResp = await client
            .from('closure_notifications')
            .select('*, closer:profiles!closed_by(full_name)')
            .order('created_at', ascending: false)
            .limit(30);

        for (final row in List<Map<String, dynamic>>.from(closureResp)) {
          final id = row['id'] as String;
          final issueTitle = row['issue_title'] as String? ?? 'An issue';
          final villageName = row['village_name'] as String? ?? 'a village';
          final closerName = (row['closer'] as Map<String, dynamic>?)?['full_name'] as String? ?? 'A leader';
          final createdAt = DateTime.parse(row['created_at'] as String);
          final isRead = row['is_read'] as bool? ?? false;
          // issue_id links back to the actual issue for tap-to-navigate.
          final issueId = row['issue_id'] as String? ?? '';

          merged.add(AdminNotif(
            id: id,
            type: 'closure',
            title: 'Issue closed',
            subtitle: '"$issueTitle" closed by $closerName from $villageName.',
            createdAt: createdAt,
            isRead: isRead,
            issueId: issueId,
          ));
        }
      } catch (_) {
        // If closure_notifications table isn't set up, skip gracefully.
      }

      // Sort merged list newest-first.
      merged.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      final unread = merged.where((n) => !n.isRead).length;

      state = state.copyWith(
        notifications: merged,
        unreadCount: unread,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to load notifications: $e');
    }
  }

  /// Mark a single notification as read.
  /// For closure events: persists to Supabase.
  /// For new-issue events: stores in memory only.
  Future<void> markAsRead(String notifId) async {
    if (notifId.startsWith('issue_')) {
      // Local-only read tracking for new-issue events.
      final rawId = notifId.replaceFirst('issue_', '');
      _locallyReadNewIssueIds.add(rawId);

      final updated = state.notifications.map((n) {
        if (n.id == notifId) {
          n.isRead = true;
        }
        return n;
      }).toList();
      final unread = updated.where((n) => !n.isRead).length;
      state = state.copyWith(notifications: updated, unreadCount: unread);
    } else {
      // Persist closure read state to Supabase.
      try {
        final client = Supabase.instance.client;
        await client
            .from('closure_notifications')
            .update({'is_read': true, 'read_at': DateTime.now().toUtc().toIso8601String()})
            .eq('id', notifId);
      } catch (_) {
        // Ignore write error; local state still updated below.
      }

      final updated = state.notifications.map((n) {
        if (n.id == notifId) {
          n.isRead = true;
        }
        return n;
      }).toList();
      final unread = updated.where((n) => !n.isRead).length;
      state = state.copyWith(notifications: updated, unreadCount: unread);
    }
  }

  /// Mark ALL notifications as read.
  Future<void> markAllAsRead() async {
    // Persist all unread closure IDs to Supabase.
    final closureUnreadIds = state.notifications
        .where((n) => n.type == 'closure' && !n.isRead)
        .map((n) => n.id)
        .toList();

    if (closureUnreadIds.isNotEmpty) {
      try {
        final client = Supabase.instance.client;
        await client
            .from('closure_notifications')
            .update({'is_read': true, 'read_at': DateTime.now().toUtc().toIso8601String()})
            .inFilter('id', closureUnreadIds);
      } catch (_) {}
    }

    // Mark all new-issue IDs locally.
    for (final n in state.notifications) {
      if (n.type == 'new_issue') {
        _locallyReadNewIssueIds.add(n.id.replaceFirst('issue_', ''));
      }
    }

    final updated = state.notifications.map((n) {
      n.isRead = true;
      return n;
    }).toList();
    state = state.copyWith(notifications: updated, unreadCount: 0);
  }
}

final adminNotificationsProvider =
    StateNotifierProvider<AdminNotificationsNotifier, AdminNotificationsState>((ref) {
  return AdminNotificationsNotifier();
});
