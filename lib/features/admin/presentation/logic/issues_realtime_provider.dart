import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'admin_analytics_provider.dart';
import 'admin_issues_provider.dart';

// ---------------------------------------------------------------------------
// SHARED REALTIME — Issues table watcher (diagnostic build)
// ---------------------------------------------------------------------------
// Opens ONE Supabase realtime channel on the `issues` table.
// On every INSERT or UPDATE it calls fetchAnalytics() and fetchIssues() so
// both the Dashboard and the Verify/Issue List refresh automatically.
//
// REQUIREMENTS (server-side):
//   ALTER PUBLICATION supabase_realtime ADD TABLE public.issues;
//
// Usage: ref.watch(issuesRealtimeProvider) in any ConsumerWidget.
// ---------------------------------------------------------------------------

class _IssuesRealtimeNotifier extends AsyncNotifier<void> {
  RealtimeChannel? _channel;

  @override
  Future<void> build() async {
    debugPrint('[REALTIME] ▶ build() started — creating channel');

    // Keep alive for the whole session.
    ref.keepAlive();

    ref.onDispose(() {
      debugPrint('[REALTIME] ♻ onDispose() — removing channel');
      final ch = _channel;
      _channel = null;
      if (ch != null) {
        Supabase.instance.client.removeChannel(ch);
      }
    });

    final client = Supabase.instance.client;

    _channel = client
        .channel('admin_issues_realtime')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'issues',
          callback: (payload) {
            debugPrint('[REALTIME] ✅ INSERT event received — payload: $payload');
            _refresh();
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'issues',
          callback: (payload) {
            debugPrint('[REALTIME] ✅ UPDATE event received — payload: $payload');
            _refresh();
          },
        );

    debugPrint('[REALTIME] ▶ subscribe() called');
    _channel!.subscribe((RealtimeSubscribeStatus status, [Object? error]) {
      debugPrint('[REALTIME] 📡 subscribe status: $status  |  error: $error');

      // If subscription fails, clean up so the channel doesn't linger.
      if (status == RealtimeSubscribeStatus.channelError ||
          status == RealtimeSubscribeStatus.timedOut) {
        debugPrint('[REALTIME] ❌ subscription FAILED — status=$status error=$error');
        final ch = _channel;
        _channel = null;
        if (ch != null) {
          Supabase.instance.client.removeChannel(ch);
        }
      } else if (status == RealtimeSubscribeStatus.subscribed) {
        debugPrint('[REALTIME] ✅ channel SUBSCRIBED — listening for issues changes');
      }
    });

    debugPrint('[REALTIME] ▶ build() complete — channel reference: $_channel');
  }

  void _refresh() {
    debugPrint('[REALTIME] 🔄 _refresh() called — triggering fetchAnalytics + fetchIssues');
    try {
      ref.read(adminAnalyticsProvider.notifier).fetchAnalytics();
      debugPrint('[REALTIME] 🔄 fetchAnalytics() invoked');
    } catch (e) {
      debugPrint('[REALTIME] ❌ fetchAnalytics() threw: $e');
    }
    try {
      ref.read(adminIssuesProvider.notifier).fetchIssues();
      debugPrint('[REALTIME] 🔄 fetchIssues() invoked');
    } catch (e) {
      debugPrint('[REALTIME] ❌ fetchIssues() threw: $e');
    }
  }
}

/// Watch this provider in any admin screen that should react to `issues` changes.
final issuesRealtimeProvider =
    AsyncNotifierProvider<_IssuesRealtimeNotifier, void>(
  _IssuesRealtimeNotifier.new,
);
