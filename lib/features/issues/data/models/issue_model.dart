import 'package:isar/isar.dart';
import '../../../../core/database/isar_utils.dart';
import '../../../../core/sync/sync_status.dart';
import '../../domain/entities/issue.dart';

part 'issue_model.g.dart';

// ---------------------------------------------------------------------------
// PHASE 05 — Issue Isar Model (FINAL v3 compliant)
// ---------------------------------------------------------------------------
// Matches the Issue domain entity exactly.
// categoryId and subcategoryId are UUID strings (data-driven).
// No photo fields, no enum-based category, no old submission fields.
// ---------------------------------------------------------------------------

@collection
class IssueModel {
  /// Isar integer ID derived from UUID string via fastHash.
  Id get isarId => fastHash(id);

  /// Client-generated UUID (primary key in both Isar and Supabase).
  @Index(unique: true, replace: true)
  late String id;

  /// UUID of the Leader who reported this issue.
  @Index()
  late String leaderId;

  /// UUID of the assigned village.
  @Index()
  late String villageId;

  /// Village display name (denormalized for offline display without joins).
  late String villageName;

  /// UUID of the top-level category (Water, Education, Road, Community).
  @Index()
  late String categoryId;

  /// UUID of the subcategory. Nullable — required in the create form,
  /// but stored as nullable here to handle schema evolution.
  String? subcategoryId;

  /// Short title. Required.
  late String title;

  /// Detailed description. Required.
  late String description;

  /// Business lifecycle status. Enum stored as index.
  @enumerated
  @Index()
  late IssueStatus status;

  /// Current progress (0–100). Only increases.
  late int currentProgress;

  /// True when Leader has confirmed END PROJECT. Makes record read-only.
  late bool locked;

  /// When this issue was first created on device.
  late DateTime createdAt;

  /// When this issue was last modified locally.
  late DateTime updatedAt;

  /// Set when locked = true (END PROJECT).
  DateTime? closedAt;

  /// UUID of the leader who closed the issue.
  String? closedBy;

  /// Sync state with Supabase. Independent of [status].
  @enumerated
  @Index()
  late SyncStatus syncStatus;

  // ─────────────────────────────────────────────────────────────────────────
  // Mapping
  // ─────────────────────────────────────────────────────────────────────────

  Issue toDomain() {
    return Issue(
      id: id,
      leaderId: leaderId,
      villageId: villageId,
      villageName: villageName,
      categoryId: categoryId,
      subcategoryId: subcategoryId,
      title: title,
      description: description,
      status: status,
      currentProgress: currentProgress,
      locked: locked,
      createdAt: createdAt,
      updatedAt: updatedAt,
      closedAt: closedAt,
      closedBy: closedBy,
      syncStatus: syncStatus,
    );
  }

  static IssueModel fromDomain(Issue issue) {
    return IssueModel()
      ..id = issue.id
      ..leaderId = issue.leaderId
      ..villageId = issue.villageId
      ..villageName = issue.villageName
      ..categoryId = issue.categoryId
      ..subcategoryId = issue.subcategoryId
      ..title = issue.title
      ..description = issue.description
      ..status = issue.status
      ..currentProgress = issue.currentProgress
      ..locked = issue.locked
      ..createdAt = issue.createdAt
      ..updatedAt = issue.updatedAt
      ..closedAt = issue.closedAt
      ..closedBy = issue.closedBy
      ..syncStatus = issue.syncStatus;
  }
}
