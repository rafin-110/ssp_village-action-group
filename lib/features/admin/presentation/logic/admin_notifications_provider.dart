import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ---------------------------------------------------------------------------
// PHASE 25 — Admin Notifications Provider
// ---------------------------------------------------------------------------

class AdminNotificationsState {
  final List<Map<String, dynamic>> notifications;
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
    List<Map<String, dynamic>>? notifications,
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
  AdminNotificationsNotifier() : super(AdminNotificationsState()) {
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final client = Supabase.instance.client;
      
      // closure_notifications schema:
      // id, issue_id, issue_title, village_id, village_name, category_id, closed_by, closed_at, final_progress, is_read, read_at, created_at
      final response = await client
          .from('closure_notifications')
          .select('*, profiles!closed_by(full_name)')
          .order('created_at', ascending: false)
          .limit(50); // Get latest 50 notifications

      final data = List<Map<String, dynamic>>.from(response);
      
      // Calculate unread count
      int unread = data.where((n) => n['is_read'] == false).length;

      state = state.copyWith(
        notifications: data,
        unreadCount: unread,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to load notifications: $e');
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      final client = Supabase.instance.client;
      await client
          .from('closure_notifications')
          .update({'is_read': true, 'read_at': DateTime.now().toUtc().toIso8601String()})
          .eq('id', notificationId);
      
      // Update local state without re-fetching
      final updatedList = state.notifications.map((n) {
        if (n['id'] == notificationId) {
          return {...n, 'is_read': true};
        }
        return n;
      }).toList();
      
      final unread = updatedList.where((n) => n['is_read'] == false).length;
      
      state = state.copyWith(notifications: updatedList, unreadCount: unread);
    } catch (e) {
      // Ignore error and let next fetch correct it
    }
  }

  Future<void> markAllAsRead() async {
    final unreadIds = state.notifications
        .where((n) => n['is_read'] == false)
        .map((n) => n['id'] as String)
        .toList();
        
    if (unreadIds.isEmpty) return;

    try {
      final client = Supabase.instance.client;
      await client
          .from('closure_notifications')
          .update({'is_read': true, 'read_at': DateTime.now().toUtc().toIso8601String()})
          .inFilter('id', unreadIds);

      final updatedList = state.notifications.map((n) {
        return {...n, 'is_read': true};
      }).toList();

      state = state.copyWith(notifications: updatedList, unreadCount: 0);
    } catch (e) {
      // Ignore error
    }
  }
}

final adminNotificationsProvider = StateNotifierProvider<AdminNotificationsNotifier, AdminNotificationsState>((ref) {
  return AdminNotificationsNotifier();
});
