import 'dart:async';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../features/issues/data/data_sources/issue_local_data_source.dart';
import '../../features/meetings/data/data_sources/meeting_local_data_source.dart';
import '../../features/villages/data/data_sources/village_local_data_source.dart';
import '../database/local_db.dart';
import 'sync_status.dart';

/// Manages background synchronization when the device comes online.
/// On web, this is a no-op since offline sync is handled differently.
class SyncManager {
  static StreamSubscription<List<ConnectivityResult>>? _subscription;

  /// Starts listening for network changes to trigger background sync.
  static void initialize() {
    if (!LocalDb.isAvailable) return;
    
    final connectivity = Connectivity();
    _subscription = connectivity.onConnectivityChanged.listen((results) {
      if (results.isNotEmpty && results.first != ConnectivityResult.none) {
        _processSyncQueue();
      }
    });
  }

  static Future<void> _processSyncQueue() async {
    if (!LocalDb.isAvailable) return;
    debugPrint('SyncManager: Network connected. Processing pending queue...');
    
    final isar = LocalDb.instance;
    if (isar == null) return;

    try {
      // 1. Sync Issues
      final issueDs = IssueLocalDataSource();
      final pendingIssues = await issueDs.getPendingSyncIssues();
      for (final issue in pendingIssues) {
        debugPrint('Syncing issue: ${issue.id} ...');
        await Future.delayed(const Duration(milliseconds: 500)); // Simulate API call
        issue.syncStatus = SyncStatus.synced;
        await issueDs.saveIssue(issue);
      }

      // 2. Sync Meetings
      final meetingDs = MeetingLocalDataSource();
      final pendingMeetings = await meetingDs.getPendingSyncMeetings();
      for (final meeting in pendingMeetings) {
        debugPrint('Syncing meeting: ${meeting.id} ...');
        await Future.delayed(const Duration(milliseconds: 500)); // Simulate API call
        meeting.syncStatus = SyncStatus.synced;
        await meetingDs.saveMeeting(meeting);
      }

      // 3. Sync Villages
      final villageDs = VillageLocalDataSource();
      final pendingVillages = await villageDs.getPendingSyncVillages();
      for (final village in pendingVillages) {
        debugPrint('Syncing village: ${village.id} ...');
        await Future.delayed(const Duration(milliseconds: 500)); // Simulate API call
        village.syncStatus = SyncStatus.synced;
        await villageDs.saveVillage(village);
      }
      
      debugPrint('SyncManager: Queue processing complete.');
    } catch (e) {
      debugPrint('SyncManager: Error processing queue: $e');
    }
  }

  static void dispose() {
    _subscription?.cancel();
  }
}
