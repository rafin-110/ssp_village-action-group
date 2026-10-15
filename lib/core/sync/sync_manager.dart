import 'dart:async';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:connectivity_plus/connectivity_plus.dart';
import '../database/local_db.dart';
import 'sync_strategy.dart';
import '../../features/issues/sync/issues_sync_strategy.dart';
import '../../features/issues/sync/progress_updates_sync_strategy.dart';

/// Manages background synchronization when the device comes online.
/// On web, this is a no-op since offline sync is handled differently.
class SyncManager {
  static StreamSubscription<List<ConnectivityResult>>? _subscription;
  static bool _isSyncing = false;
  static bool _syncRequested = false;

  // Stream controller to notify UI (Riverpod) when an item finishes syncing.
  static final StreamController<void> _syncCompletedController =
      StreamController<void>.broadcast();

  /// Read-only stream that emits whenever an item's sync status changes in the local DB.
  static Stream<void> get onSyncStatusChanged =>
      _syncCompletedController.stream;

  static final List<SyncStrategy> _strategies = [
    IssuesSyncStrategy(),
    ProgressUpdatesSyncStrategy(),
  ];

  /// Starts listening for network changes to trigger background sync.
  static void initialize() {
    if (!LocalDb.isAvailable) return;

    final connectivity = Connectivity();
    _subscription = connectivity.onConnectivityChanged.listen((results) {
      if (results.isNotEmpty && results.first != ConnectivityResult.none) {
        _syncRequested = true;
        _processSyncQueue();
      }
    });
  }

  static Future<void> syncNow() async {
    if (!LocalDb.isAvailable) return;
    debugPrint('SyncManager: Manual sync triggered. Queuing request...');
    _syncRequested = true;
    await _processSyncQueue();
  }

  static Future<void> _processSyncQueue() async {
    if (!LocalDb.isAvailable) return;
    if (_isSyncing) {
      debugPrint('SyncManager: Sync already in progress. Request queued.');
      return;
    }

    _isSyncing = true;

    try {
      final isar = LocalDb.instance;
      if (isar == null) return;

      while (_syncRequested) {
        _syncRequested = false;
        debugPrint('SyncManager: Processing pending queue...');

        for (final strategy in _strategies) {
          final pendingIds = await strategy.getPendingIds();
          
          if (pendingIds.isNotEmpty) {
            debugPrint('SyncManager: [${strategy.name}] Batch syncing ${pendingIds.length} items...');
            for (final id in pendingIds) {
              await strategy.markSyncing(id);
            }
            
            try {
              // Batch upload
              await strategy.uploadBatch(pendingIds);
              
              for (final id in pendingIds) {
                await strategy.markSynced(id);
                _syncCompletedController.add(null);
              }
            } catch (e) {
              debugPrint('SyncManager: [${strategy.name}] Batch failed: $e');
              for (final id in pendingIds) {
                await strategy.markFailed(id);
                _syncCompletedController.add(null);
              }
              // Exponential backoff / circuit breaker logic:
              // If the server fails, stop the queue and wait 5 seconds before allowing next sync.
              debugPrint('SyncManager: Circuit breaker triggered. Waiting 5 seconds before next sync allowed...');
              await Future.delayed(const Duration(seconds: 5));
              // Break out of strategy loop to allow the app to recover
              break; 
            }
          }
        }
      }
      debugPrint('SyncManager: Queue processing complete.');
    } catch (e) {
      debugPrint('SyncManager: Error processing queue: $e');
    } finally {
      _isSyncing = false;
    }
  }

  static void dispose() {
    _subscription?.cancel();
    _syncCompletedController.close();
  }
}
