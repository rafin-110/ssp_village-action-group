import 'package:dio/dio.dart';
import '../../../../core/network/supabase_config.dart';
import '../../../../core/network/supabase_rest_client.dart';
import '../models/issue_model.dart';

// ---------------------------------------------------------------------------
// PHASE 16 — Issue Remote Data Source
// ---------------------------------------------------------------------------
// Converts IssueModel (Isar snake_case fields) to the exact Supabase
// `issues` table column names defined in §39 of project_documentation.md.
//
// Key design decisions:
//   • Uses upsert (ON CONFLICT DO UPDATE) — repeated calls are idempotent
//   • The client-generated UUID is the PRIMARY KEY in both Isar AND Supabase
//   • 'synced_at' is set server-side via a Postgres trigger or here
//   • Does NOT read back from Supabase — local Isar is the source of truth
//   • Throws on network error — caller (SyncStrategy) handles retry
// ---------------------------------------------------------------------------

class IssueRemoteDataSource {
  final SupabaseRestClient _client;

  IssueRemoteDataSource({SupabaseRestClient? client})
      : _client = client ?? SupabaseRestClient.instance;

  // ── Upsert issue ───────────────────────────────────────────────────────────

  /// Pushes [model] to the Supabase `issues` table using upsert.
  ///
  /// Idempotent: calling this multiple times with the same [model.id]
  /// will update in place — no duplicate rows created.
  ///
  /// Throws [DioException] on network/server error.
  /// Throws [StateError] if Supabase client is not initialized.
  Future<void> upsertIssue(IssueModel model) async {
    await _client.upsert(
      SupabaseConfig.issuesTable,
      _toSupabasePayload(model),
    );
  }

  // ── Mapping: IssueModel → Supabase column names ───────────────────────────

  /// Maps IssueModel fields to the exact column names in the Supabase
  /// `issues` table (see project_documentation.md §39).
  ///
  /// Notable conversions:
  ///   • Dart enums → lowercase string (matches Postgres CHECK constraint)
  ///   • DateTime → ISO 8601 string (Postgres timestamptz)
  ///   • bool → bool (JSON boolean)
  ///   • client_created_at = original createdAt (audit trail, never changes)
  ///   • synced_at = DateTime.now() (marks when this device last pushed)
  static Map<String, dynamic> _toSupabasePayload(IssueModel model) {
    return {
      // Primary key — same UUID used locally and in Supabase
      'id': model.id,

      // Foreign keys
      'leader_id': model.leaderId,
      'village_id': model.villageId,
      'category_id': model.categoryId,
      'subcategory_id': model.subcategoryId,

      // Core fields
      'title': model.title,
      'description': model.description,

      // Status: Supabase CHECK expects lowercase snake_case values
      // e.g. IssueStatus.inProgress → 'in_progress'
      'status': _statusToString(model.status),
      'current_progress': model.currentProgress,
      'locked': model.locked,

      // Timestamps (ISO 8601 with timezone)
      'created_at': model.createdAt.toUtc().toIso8601String(),
      'updated_at': model.updatedAt.toUtc().toIso8601String(),
      'closed_at': model.closedAt?.toUtc().toIso8601String(),
      'closed_by': model.closedBy,

      // Sync metadata
      'client_created_at': model.createdAt.toUtc().toIso8601String(),
      'synced_at': DateTime.now().toUtc().toIso8601String(),
    };
  }

  /// Converts [IssueStatus] enum to the string stored in Supabase.
  /// Matches the Postgres CHECK constraint:
  ///   check (status in ('reported', 'in_progress', 'completed', 'closed'))
  static String _statusToString(dynamic status) {
    // status is IssueStatus enum
    switch (status.toString()) {
      case 'IssueStatus.reported':
        return 'reported';
      case 'IssueStatus.inProgress':
        return 'in_progress';
      case 'IssueStatus.completed':
        return 'completed';
      case 'IssueStatus.closed':
        return 'closed';
      default:
        return 'reported';
    }
  }
}
