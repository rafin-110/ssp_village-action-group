import 'package:dio/dio.dart';
import '../../../../core/network/supabase_config.dart';
import '../../../../core/network/supabase_rest_client.dart';
import '../models/progress_update_model.dart';

// ---------------------------------------------------------------------------
// PHASE 17 — Progress Update Remote Data Source
// ---------------------------------------------------------------------------
// Converts ProgressUpdateModel (Isar) to the exact Supabase
// `progress_updates` table column names defined in §39 of
// project_documentation.md.
//
// Column mapping (Dart field → Supabase column):
//   id              → id               (client UUID — PK, idempotent upsert)
//   issueId         → issue_id
//   createdBy       → created_by
//   progressPercent → progress_percentage
//   notes           → description
//   createdAt       → created_at, client_created_at
//   now()           → updated_at, synced_at
//
// Idempotency: uses ON CONFLICT (id) DO UPDATE — safe to retry N times.
// ---------------------------------------------------------------------------

class ProgressUpdateRemoteDataSource {
  final SupabaseRestClient _client;

  ProgressUpdateRemoteDataSource({SupabaseRestClient? client})
      : _client = client ?? SupabaseRestClient.instance;

  /// Pushes [model] to the Supabase `progress_updates` table using upsert.
  ///
  /// Idempotent: calling this multiple times with the same [model.id]
  /// will update in place — no duplicate rows created.
  ///
  /// Throws [DioException] on network/server error.
  Future<void> upsertProgressUpdate(ProgressUpdateModel model) async {
    await _client.upsert(
      SupabaseConfig.progressUpdatesTable,
      _toSupabasePayload(model),
    );
  }

  // ── Mapping ───────────────────────────────────────────────────────────────

  static Map<String, dynamic> _toSupabasePayload(ProgressUpdateModel model) {
    final now = DateTime.now().toUtc().toIso8601String();
    final createdAtUtc = model.createdAt.toUtc().toIso8601String();

    return {
      // Primary key — same UUID used locally and in Supabase
      'id': model.id,

      // Foreign keys
      'issue_id': model.issueId,
      'created_by': model.createdBy,

      // Progress data
      // Dart field is `progressPercent`, Supabase column is `progress_percentage`
      'progress_percentage': model.progressPercent,

      // Dart field is `notes`, Supabase column is `description`
      'description': model.notes,

      // Timestamps (ISO 8601 UTC)
      'created_at': createdAtUtc,
      'updated_at': now,

      // Audit: original device creation time (never changes on re-sync)
      'client_created_at': createdAtUtc,

      // When SyncManager last pushed this record
      'synced_at': now,
    };
  }
}
