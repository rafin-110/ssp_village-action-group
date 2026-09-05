import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ---------------------------------------------------------------------------
// PHASE 16+ — Sync State for UI (Upload Donut)
// ---------------------------------------------------------------------------
// Bridges the SyncManager (internal singleton) to the Riverpod UI layer.
//
// The SyncManager runs uploads internally and calls notifyUploadProgress()
// after each successful/failed item upload. SyncStateNotifier holds the
// current state and rebuilds any listening widgets.
//
// State fields:
//   isUploading  — true while a sync cycle is actively running
//   total        — total items to upload in this cycle
//   completed    — successfully uploaded items so far
//   failed       — items that failed (remain in retry queue)
//
// Progress formula:
//   completed / total  (guarded against total == 0)
// ---------------------------------------------------------------------------

/// Immutable snapshot of the current upload state.
class SyncUiState {
  final bool isUploading;
  final int total;
  final int completed;
  final int failed;

  const SyncUiState({
    this.isUploading = false,
    this.total = 0,
    this.completed = 0,
    this.failed = 0,
  });

  /// Upload progress 0.0 – 1.0. Safe when total == 0.
  double get progress => total == 0 ? 0.0 : (completed / total).clamp(0.0, 1.0);

  /// Percentage 0 – 100 (for display).
  int get percent => (progress * 100).round();

  /// Items still pending (neither completed nor failed).
  int get pending => (total - completed - failed).clamp(0, total);

  /// True when all items in this cycle finished (success or failure).
  bool get isDone => isUploading == false && total > 0 && (completed + failed) >= total;

  SyncUiState copyWith({
    bool? isUploading,
    int? total,
    int? completed,
    int? failed,
  }) {
    return SyncUiState(
      isUploading: isUploading ?? this.isUploading,
      total: total ?? this.total,
      completed: completed ?? this.completed,
      failed: failed ?? this.failed,
    );
  }

  @override
  String toString() =>
      'SyncUiState(uploading=$isUploading total=$total '
      'completed=$completed failed=$failed $percent%)';
}

/// Notifier that exposes SyncManager upload progress to the UI.
/// Widgets watch [syncStateProvider] and rebuild as uploads progress.
class SyncStateNotifier extends StateNotifier<SyncUiState> {
  SyncStateNotifier() : super(const SyncUiState());

  // ── Called by SyncManager during a sync cycle ─────────────────────────────

  /// Called at the start of a sync cycle with the total number of items.
  void onCycleStarted(int total) {
    debugPrint('[SyncUI] Upload started — $total items pending');
    state = SyncUiState(isUploading: true, total: total, completed: 0, failed: 0);
  }

  /// Called after each SUCCESSFUL item upload.
  void onItemUploaded(String id) {
    final newCompleted = state.completed + 1;
    debugPrint('[SyncUI] Uploaded $newCompleted/${state.total} ($id)');
    state = state.copyWith(completed: newCompleted);
  }

  /// Called after each FAILED item upload.
  void onItemFailed(String id) {
    final newFailed = state.failed + 1;
    debugPrint('[SyncUI] Upload failed ${state.completed}/${state.total} ($id)');
    state = state.copyWith(failed: newFailed);
  }

  /// Called when the sync cycle completes (all items attempted).
  void onCycleComplete() {
    debugPrint(
      '[SyncUI] Upload complete: ${state.completed}/${state.total} uploaded, '
      '${state.failed} failed',
    );
    state = state.copyWith(isUploading: false);
  }

  /// Resets state to idle (nothing uploading, no counts).
  void reset() {
    state = const SyncUiState();
  }
}

/// Global provider — watch this in any widget to observe upload progress.
final syncStateProvider =
    StateNotifierProvider<SyncStateNotifier, SyncUiState>(
  (ref) => SyncStateNotifier(),
);
