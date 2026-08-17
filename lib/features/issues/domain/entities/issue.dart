import '../../../../core/sync/sync_status.dart';

// ---------------------------------------------------------------------------
// PHASE 05 — Issue Data Model (FINAL v3 compliant)
// ---------------------------------------------------------------------------
// Fields exactly match §39 PostgreSQL schema and §42 of project_documentation.md.
// categoryId and subcategoryId are UUIDs (data-driven), not enums.
// Enum categories removed here — Phase 06 adds the category/subcategory data layer.
// ---------------------------------------------------------------------------

/// The business lifecycle status of an Issue.
///
/// These are INDEPENDENT of SyncStatus. Example:
///   IssueStatus.closed + SyncStatus.pending = closed locally, not yet synced.
///
/// User-facing labels (§15 of project_documentation.md):
///   reported    → "New" or "Holding"
///   inProgress  → "Ongoing"
///   completed   → "Completed" (100%, not yet formally closed)
///   closed      → "Closed" (Leader pressed END PROJECT → locked forever)
enum IssueStatus {
  reported,
  inProgress,
  completed,
  closed,
}

/// Extension for user-facing label strings.
extension IssueStatusLabel on IssueStatus {
  String get displayLabel {
    switch (this) {
      case IssueStatus.reported:
        return 'New';
      case IssueStatus.inProgress:
        return 'Ongoing';
      case IssueStatus.completed:
        return 'Completed';
      case IssueStatus.closed:
        return 'Closed';
    }
  }

  /// The snake_case string stored in Supabase.
  String get dbValue {
    switch (this) {
      case IssueStatus.reported:
        return 'reported';
      case IssueStatus.inProgress:
        return 'in_progress';
      case IssueStatus.completed:
        return 'completed';
      case IssueStatus.closed:
        return 'closed';
    }
  }

  static IssueStatus fromDbValue(String value) {
    switch (value) {
      case 'reported':
        return IssueStatus.reported;
      case 'in_progress':
        return IssueStatus.inProgress;
      case 'completed':
        return IssueStatus.completed;
      case 'closed':
        return IssueStatus.closed;
      default:
        return IssueStatus.reported;
    }
  }
}

/// A single village issue — the central business object of the application.
///
/// Matches the `issues` table in PostgreSQL (§39).
/// UUID is generated client-side before saving. The same UUID is used in Supabase.
///
/// Rules (§15–21):
/// - progress can only increase (0 → 20 → 50 → 100)
/// - When progress = 100 → status automatically becomes [IssueStatus.completed]
/// - [locked] = true only after Leader confirms END PROJECT
/// - Once [locked], no field can be edited by the Leader
///
/// NOTE: ProgressUpdate records (Phase 11) are stored separately in Isar.
///       They are linked by [id] (issue UUID).
class Issue {
  /// Client-generated UUID. Used as primary key both locally and in Supabase.
  final String id;

  /// UUID of the Leader who reported this issue (from auth session).
  final String leaderId;

  /// UUID of the village this issue belongs to.
  final String villageId;

  /// Display name of the village (denormalized for offline display).
  final String villageName;

  /// UUID of the top-level category (Water, Education, Road, Community).
  /// Resolved to display name via the category data layer (Phase 06).
  final String categoryId;

  /// UUID of the subcategory. Nullable — required in create form but stored
  /// here as nullable to handle future schema evolution gracefully.
  final String? subcategoryId;

  /// Short title describing the problem. Required.
  final String title;

  /// Detailed description of the problem. Required.
  final String description;

  /// Current lifecycle status. See [IssueStatus] for values and rules.
  final IssueStatus status;

  /// Current progress percentage (0–100). Only increases.
  /// Automatically drives status transitions (100 → completed).
  final int currentProgress;

  /// True after Leader confirms END PROJECT. Makes the issue read-only.
  final bool locked;

  /// When the issue was first created on the device.
  final DateTime createdAt;

  /// When the issue was last modified locally.
  final DateTime updatedAt;

  /// Timestamp of formal closure (set when locked = true).
  final DateTime? closedAt;

  /// UUID of the leader who closed the project (matches leaderId in v1, but
  /// kept separate to allow future admin-initiated closure).
  final String? closedBy;

  /// Synchronization state with Supabase. Independent of [status].
  final SyncStatus syncStatus;

  const Issue({
    required this.id,
    required this.leaderId,
    required this.villageId,
    required this.villageName,
    required this.categoryId,
    this.subcategoryId,
    required this.title,
    required this.description,
    this.status = IssueStatus.reported,
    this.currentProgress = 0,
    this.locked = false,
    required this.createdAt,
    required this.updatedAt,
    this.closedAt,
    this.closedBy,
    this.syncStatus = SyncStatus.pending,
  });

  /// Creates a new Issue with default values.
  /// UUID must be generated by the caller (use uuid package).
  factory Issue.create({
    required String id,
    required String leaderId,
    required String villageId,
    required String villageName,
    required String categoryId,
    String? subcategoryId,
    required String title,
    required String description,
  }) {
    final now = DateTime.now();
    return Issue(
      id: id,
      leaderId: leaderId,
      villageId: villageId,
      villageName: villageName,
      categoryId: categoryId,
      subcategoryId: subcategoryId,
      title: title,
      description: description,
      status: IssueStatus.reported,
      currentProgress: 0,
      locked: false,
      createdAt: now,
      updatedAt: now,
      syncStatus: SyncStatus.pending,
    );
  }

  /// Business rule: cannot edit if locked.
  bool get isEditable => !locked;

  /// Business rule: can add progress if not locked.
  bool get canAddProgress => !locked;

  /// Business rule: can close (END PROJECT) only if at 100% and not yet closed.
  bool get canClose => currentProgress == 100 && !locked;

  Issue copyWith({
    String? id,
    String? leaderId,
    String? villageId,
    String? villageName,
    String? categoryId,
    String? subcategoryId,
    String? title,
    String? description,
    IssueStatus? status,
    int? currentProgress,
    bool? locked,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? closedAt,
    String? closedBy,
    SyncStatus? syncStatus,
  }) {
    return Issue(
      id: id ?? this.id,
      leaderId: leaderId ?? this.leaderId,
      villageId: villageId ?? this.villageId,
      villageName: villageName ?? this.villageName,
      categoryId: categoryId ?? this.categoryId,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      currentProgress: currentProgress ?? this.currentProgress,
      locked: locked ?? this.locked,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      closedAt: closedAt ?? this.closedAt,
      closedBy: closedBy ?? this.closedBy,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}
