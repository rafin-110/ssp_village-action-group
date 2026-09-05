import '../../../../core/sync/sync_status.dart';

// ---------------------------------------------------------------------------
// PHASE 11 — ProgressUpdate Domain Entity
// ---------------------------------------------------------------------------
// A ProgressUpdate records a single milestone in an issue's lifecycle.
// Multiple updates are allowed per issue. Progress can only increase.
//
// Business rules (§15–21 of project_documentation.md):
//  • progressPercent must be GREATER than issue.currentProgress
//  • Valid steps: any value from 1–100 that is > current
//  • When progressPercent = 100 → IssueStatus transitions to completed
//  • notes (what was done) is REQUIRED — cannot submit empty
//  • No photos allowed (FINAL v3 removes all camera workflows)
//
// Stored in Isar as ProgressUpdateModel.
// Linked to Issue by issueId (UUID string).
// ---------------------------------------------------------------------------

class ProgressUpdate {
  /// Client-generated UUID. Same UUID used in Supabase.
  final String id;

  /// UUID of the parent issue.
  final String issueId;

  /// The new progress percentage this update sets (1–100).
  /// Must be strictly greater than the issue's currentProgress at the time
  /// of creation.
  final int progressPercent;

  /// What was done / what action was taken. Required — min 5 characters.
  final String notes;

  /// UUID of the leader who created this update.
  final String createdBy;

  /// When this update was created on the device.
  final DateTime createdAt;

  /// Sync state with Supabase. Independent of the parent issue's SyncStatus.
  final SyncStatus syncStatus;

  const ProgressUpdate({
    required this.id,
    required this.issueId,
    required this.progressPercent,
    required this.notes,
    required this.createdBy,
    required this.createdAt,
    this.syncStatus = SyncStatus.pending,
  });

  /// Factory for creating a new update. UUID must be pre-generated
  /// using [generateUuid] from core/utils/uuid_generator.dart.
  factory ProgressUpdate.create({
    required String id,
    required String issueId,
    required int progressPercent,
    required String notes,
    required String createdBy,
  }) {
    return ProgressUpdate(
      id: id,
      issueId: issueId,
      progressPercent: progressPercent,
      notes: notes,
      createdBy: createdBy,
      createdAt: DateTime.now(),
      syncStatus: SyncStatus.pending,
    );
  }

  ProgressUpdate copyWith({
    String? id,
    String? issueId,
    int? progressPercent,
    String? notes,
    String? createdBy,
    DateTime? createdAt,
    SyncStatus? syncStatus,
  }) {
    return ProgressUpdate(
      id: id ?? this.id,
      issueId: issueId ?? this.issueId,
      progressPercent: progressPercent ?? this.progressPercent,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}
