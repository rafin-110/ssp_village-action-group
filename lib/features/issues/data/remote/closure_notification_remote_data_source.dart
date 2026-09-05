import '../../../../core/network/supabase_config.dart';
import '../../../../core/network/supabase_rest_client.dart';
import '../../data/models/issue_model.dart';
import '../../domain/entities/issue.dart';

// ---------------------------------------------------------------------------
// PHASE 19 — Closure Notification Remote Data Source
// ---------------------------------------------------------------------------
// Creates a closure_notifications row in Supabase when a closed issue syncs.
//
// Idempotency guarantee:
//   The closure_notifications table has UNIQUE(issue_id).
//   We use 'Prefer: resolution=ignore-duplicates' which maps to:
//     INSERT ... ON CONFLICT (issue_id) DO NOTHING
//   This means retrying the same closed issue NEVER creates a duplicate row.
//
// When is this called?
//   IssuesSyncStrategy.uploadItem() calls upsertIssue() first (updates the
//   issues table). After success, if the issue is locked (closed), this class
//   is called to create/ensure the notification row exists.
//
// What does the NGO dashboard read?
//   SELECT * FROM closure_notifications WHERE is_read = false
//   ORDER BY created_at DESC
//   → Shows unread closure alerts to Supervisors/Admins (Phase 25).
// ---------------------------------------------------------------------------

class ClosureNotificationRemoteDataSource {
  final SupabaseRestClient _client;

  ClosureNotificationRemoteDataSource({SupabaseRestClient? client})
      : _client = client ?? SupabaseRestClient.instance;

  /// Creates a closure notification row for [model] if it is closed (locked).
  ///
  /// Safe to call multiple times — UNIQUE(issue_id) + ON CONFLICT DO NOTHING
  /// guarantees exactly one notification per issue.
  ///
  /// Does nothing if the issue is NOT closed (not locked).
  Future<void> createIfClosed(IssueModel model) async {
    // Only create a notification for closed (locked) issues
    if (!model.locked || model.closedAt == null || model.closedBy == null) {
      return;
    }

    await _client.insertIgnoreDuplicate(
      SupabaseConfig.closureNotificationsTable,
      _toPayload(model),
    );
  }

  // ── Mapping ───────────────────────────────────────────────────────────────

  static Map<String, dynamic> _toPayload(IssueModel model) {
    return {
      // issue_id is the idempotency key — UNIQUE constraint prevents duplicates
      'issue_id': model.id,

      // Denormalized fields for fast dashboard display
      'issue_title': model.title,
      'village_id': model.villageId,
      'village_name': model.villageName,
      'category_id': model.categoryId,

      // Closure metadata
      'closed_by': model.closedBy,
      'closed_at': model.closedAt!.toUtc().toIso8601String(),
      'final_progress': model.currentProgress,

      // Dashboard state — starts unread
      'is_read': false,
    };
  }
}
