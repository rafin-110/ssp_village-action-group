import 'package:isar/isar.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';

import '../../features/issues/data/models/issue_model.dart';
import '../../features/issues/data/models/issue_category_model.dart';
import '../../features/meetings/data/models/meeting_model.dart';
import '../../features/villages/data/models/village_model.dart';

// ---------------------------------------------------------------------------
// PHASE 06 — LocalDb updated with category collections
// ---------------------------------------------------------------------------

/// Centralized manager for the Isar local database.
/// On web, Isar is not available so we skip initialization.
class LocalDb {
  static Isar? _instance;

  /// Returns the Isar instance, or null if running on web.
  static Isar? get instance => _instance;

  /// Returns true if the local database is available (native platforms only).
  static bool get isAvailable => _instance != null;

  /// Initializes the local Isar database.
  /// On web, this is a no-op because Isar uses dart:ffi which is unavailable.
  static Future<void> init() async {
    if (kIsWeb) {
      // Isar uses dart:ffi and path_provider filesystem access,
      // neither of which work on web. Skip initialization.
      return;
    }

    final dir = await getApplicationDocumentsDirectory();
    _instance = await Isar.open(
      [
        IssueModelSchema,
        IssueCategoryModelSchema,
        IssueSubcategoryModelSchema,
        MeetingModelSchema,
        VillageModelSchema,
      ],
      directory: dir.path,
    );
  }
}
