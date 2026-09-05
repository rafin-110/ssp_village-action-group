import 'package:isar/isar.dart';
import '../../../../core/database/isar_utils.dart';
import '../../../../core/sync/sync_status.dart';
import '../../domain/entities/progress_update.dart';

part 'progress_update_model.g.dart';

// ---------------------------------------------------------------------------
// PHASE 11 — ProgressUpdate Isar Model
// ---------------------------------------------------------------------------
// Mirrors the ProgressUpdate domain entity exactly.
// Uses fastHash(id) for the Isar integer primary key — same pattern as
// IssueModel so UUIDs stay consistent across Isar + Supabase.
// ---------------------------------------------------------------------------

@collection
class ProgressUpdateModel {
  /// Isar integer ID derived from the UUID string via fastHash.
  Id get isarId => fastHash(id);

  /// Client-generated UUID — primary key in both Isar and Supabase.
  @Index(unique: true, replace: true)
  late String id;

  /// UUID of the parent issue.
  /// Indexed for fast lookup of all updates belonging to one issue.
  @Index()
  late String issueId;

  /// The progress percentage this update sets (1–100).
  late int progressPercent;

  /// What was done — required, non-empty.
  late String notes;

  /// UUID of the leader who created this update.
  late String createdBy;

  /// When this update was created on the device.
  late DateTime createdAt;

  /// Sync state with Supabase. Marked pending on creation,
  /// updated by SyncManager (Phase 15).
  @enumerated
  @Index()
  late SyncStatus syncStatus;

  // ─────────────────────────────────────────────────────────────────────────
  // Mapping
  // ─────────────────────────────────────────────────────────────────────────

  ProgressUpdate toDomain() {
    return ProgressUpdate(
      id: id,
      issueId: issueId,
      progressPercent: progressPercent,
      notes: notes,
      createdBy: createdBy,
      createdAt: createdAt,
      syncStatus: syncStatus,
    );
  }

  static ProgressUpdateModel fromDomain(ProgressUpdate update) {
    return ProgressUpdateModel()
      ..id = update.id
      ..issueId = update.issueId
      ..progressPercent = update.progressPercent
      ..notes = update.notes
      ..createdBy = update.createdBy
      ..createdAt = update.createdAt
      ..syncStatus = update.syncStatus;
  }
}
