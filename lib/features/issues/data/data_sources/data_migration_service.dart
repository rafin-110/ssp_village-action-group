import 'package:flutter/foundation.dart' show debugPrint;
import 'package:isar/isar.dart';
import '../../../../core/database/local_db.dart';
import '../../../../core/sync/sync_status.dart';
import '../models/issue_model.dart';
import '../models/progress_update_model.dart';

// ---------------------------------------------------------------------------
// DATA MIGRATION SERVICE
// ---------------------------------------------------------------------------
// Runs once at app startup (after LocalDb.init) to repair stale records
// that were written by older app versions with incorrect IDs.
//
// Migration 1 — Category UUID fix:
//   Old issues in Isar have categoryId / subcategoryId in the broken
//   'cat-00000001-0000-0000-0000-000000000001' format.
//   We map them to the correct Supabase UUIDs and re-mark the issue
//   as pending so SyncManager will upload the corrected version.
//
// Migration 2 — Leader ID fix:
//   Old progress_updates have createdBy = 'leader-001' (mock auth era).
//   We replace with the real authenticated user UUID.
//   Also re-marks progress records as pending.
//
// Both migrations are IDEMPOTENT — safe to run every startup.
// ---------------------------------------------------------------------------

/// Maps old fake category IDs → real Supabase UUIDs.
const _kCategoryIdMap = {
  'cat-00000001-0000-0000-0000-000000000001': '00000000-0000-0000-0001-000000000001',
  'cat-00000002-0000-0000-0000-000000000002': '00000000-0000-0000-0001-000000000002',
  'cat-00000003-0000-0000-0000-000000000003': '00000000-0000-0000-0001-000000000003',
  'cat-00000004-0000-0000-0000-000000000004': '00000000-0000-0000-0001-000000000004',
};

/// Maps old fake subcategory IDs → real Supabase UUIDs.
const _kSubcategoryIdMap = {
  // Water subcategories
  'sub-w01-0000-0000-0000-000000000001': '00000000-0000-0000-0002-000000000001',
  'sub-w02-0000-0000-0000-000000000002': '00000000-0000-0000-0002-000000000002',
  'sub-w03-0000-0000-0000-000000000003': '00000000-0000-0000-0002-000000000003',
  'sub-w04-0000-0000-0000-000000000004': '00000000-0000-0000-0002-000000000004',
  'sub-w05-0000-0000-0000-000000000005': '00000000-0000-0000-0002-000000000005',
  'sub-w06-0000-0000-0000-000000000006': '00000000-0000-0000-0002-000000000006',
  'sub-w07-0000-0000-0000-000000000007': '00000000-0000-0000-0002-000000000007',
  // Education subcategories
  'sub-e01-0000-0000-0000-000000000001': '00000000-0000-0000-0002-000000000011',
  'sub-e02-0000-0000-0000-000000000002': '00000000-0000-0000-0002-000000000012',
  'sub-e03-0000-0000-0000-000000000003': '00000000-0000-0000-0002-000000000013',
  'sub-e04-0000-0000-0000-000000000004': '00000000-0000-0000-0002-000000000014',
  'sub-e05-0000-0000-0000-000000000005': '00000000-0000-0000-0002-000000000015',
  'sub-e06-0000-0000-0000-000000000006': '00000000-0000-0000-0002-000000000016',
  'sub-e07-0000-0000-0000-000000000007': '00000000-0000-0000-0002-000000000017',
  // Road & Infrastructure subcategories
  'sub-r01-0000-0000-0000-000000000001': '00000000-0000-0000-0002-000000000021',
  'sub-r02-0000-0000-0000-000000000002': '00000000-0000-0000-0002-000000000022',
  'sub-r03-0000-0000-0000-000000000003': '00000000-0000-0000-0002-000000000023',
  'sub-r04-0000-0000-0000-000000000004': '00000000-0000-0000-0002-000000000024',
  'sub-r05-0000-0000-0000-000000000005': '00000000-0000-0000-0002-000000000025',
  'sub-r06-0000-0000-0000-000000000006': '00000000-0000-0000-0002-000000000026',
  'sub-r07-0000-0000-0000-000000000007': '00000000-0000-0000-0002-000000000027',
  // Community Problems subcategories
  'sub-c01-0000-0000-0000-000000000001': '00000000-0000-0000-0002-000000000031',
  'sub-c02-0000-0000-0000-000000000002': '00000000-0000-0000-0002-000000000032',
  'sub-c03-0000-0000-0000-000000000003': '00000000-0000-0000-0002-000000000033',
  'sub-c04-0000-0000-0000-000000000004': '00000000-0000-0000-0002-000000000034',
  'sub-c05-0000-0000-0000-000000000005': '00000000-0000-0000-0002-000000000035',
  'sub-c06-0000-0000-0000-000000000006': '00000000-0000-0000-0002-000000000036',
};

class DataMigrationService {
  DataMigrationService._();
  static final DataMigrationService instance = DataMigrationService._();

  Isar? get _isar => LocalDb.instance;

  // ── Main entry point ──────────────────────────────────────────────────────

  /// Run all pending migrations at app startup.
  /// Pass [realUserId] = the authenticated user's Supabase UUID (e.g.
  /// '2731bf83-fa67-4726-9ab1-ba153844a144'). If null, skips leader-id fix.
  Future<void> runAll({String? realUserId}) async {
    if (!LocalDb.isAvailable) return;

    await _migrateIssueCategoryIds();
    if (realUserId != null && realUserId.isNotEmpty) {
      await _migrateProgressUpdateLeaderIds(realUserId);
    }
  }

  // ── Migration 1: Fix issue categoryId / subcategoryId ────────────────────

  /// Finds issues where categoryId or subcategoryId is in old 'cat-'/'sub-'
  /// format and replaces with the correct Supabase UUID.
  /// Re-marks the issue as pending so SyncManager re-uploads it.
  Future<void> _migrateIssueCategoryIds() async {
    final allIssues = await _isar!.issueModels.where().findAll();
    final toFix = allIssues.where((m) =>
        _kCategoryIdMap.containsKey(m.categoryId) ||
        (m.subcategoryId != null && _kSubcategoryIdMap.containsKey(m.subcategoryId))).toList();

    if (toFix.isEmpty) {
      debugPrint('[Migration] Category IDs: all issues already have correct UUIDs.');
      return;
    }

    debugPrint('[Migration] Fixing category UUIDs in ${toFix.length} issue(s)…');

    await _isar!.writeTxn(() async {
      for (final model in toFix) {
        final oldCat = model.categoryId;
        final oldSub = model.subcategoryId;

        model.categoryId = _kCategoryIdMap[model.categoryId] ?? model.categoryId;
        if (model.subcategoryId != null) {
          model.subcategoryId = _kSubcategoryIdMap[model.subcategoryId] ?? model.subcategoryId;
        }

        // Re-queue for upload so Supabase gets the corrected payload
        if (model.syncStatus == SyncStatus.synced) {
          model.syncStatus = SyncStatus.pending;
        }

        await _isar!.issueModels.put(model);

        debugPrint(
          '[Migration] Issue ${model.id}: '
          'categoryId $oldCat → ${model.categoryId} | '
          'subcategoryId $oldSub → ${model.subcategoryId}',
        );
      }
    });

    debugPrint('[Migration] ✓ Category UUID migration complete. ${toFix.length} issues fixed.');
  }

  // ── Migration 2: Fix progress update createdBy ────────────────────────────

  /// Finds progress updates where createdBy is a mock ID (not a real UUID)
  /// and replaces with the authenticated user's real Supabase UUID.
  /// Re-marks the record as pending so SyncManager re-uploads it.
  Future<void> _migrateProgressUpdateLeaderIds(String realUserId) async {
    // A real UUID is 36 chars: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
    // Mock IDs like 'leader-001' are short and don't match UUID format.
    final allUpdates = await _isar!.progressUpdateModels.where().findAll();
    final toFix = allUpdates.where((m) => !_isValidUuid(m.createdBy)).toList();

    if (toFix.isEmpty) {
      debugPrint('[Migration] createdBy: all progress updates have valid UUIDs.');
      return;
    }

    debugPrint('[Migration] Fixing createdBy in ${toFix.length} progress update(s)…');

    await _isar!.writeTxn(() async {
      for (final model in toFix) {
        final oldId = model.createdBy;
        model.createdBy = realUserId;

        // Re-queue for upload so Supabase gets the corrected payload
        if (model.syncStatus == SyncStatus.synced) {
          model.syncStatus = SyncStatus.pending;
        }

        await _isar!.progressUpdateModels.put(model);

        debugPrint(
          '[Migration] ProgressUpdate ${model.id}: createdBy "$oldId" → "$realUserId"',
        );
      }
    });

    debugPrint('[Migration] ✓ createdBy migration complete. ${toFix.length} records fixed.');
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Returns true if [s] looks like a standard UUID (8-4-4-4-12 hex chars).
  static bool _isValidUuid(String s) {
    return RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      caseSensitive: false,
    ).hasMatch(s);
  }
}
