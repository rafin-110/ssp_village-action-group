import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vag_dmp_frontend/core/sync/sync_state_notifier.dart';
import 'package:vag_dmp_frontend/core/theme/app_colors.dart';

// ---------------------------------------------------------------------------
// PHASE 16+ — Sync Upload Donut Widget
// ---------------------------------------------------------------------------
// A compact circular progress indicator that appears ONLY when data is
// actively being uploaded to Supabase via the SyncManager.
//
// Rules:
//   • Hidden when isUploading = false AND total == 0
//   • Shows real progress: completed / total
//   • Shows "Upload complete" briefly at 100%, then fades out
//   • Does NOT show when there is nothing to upload
//   • Does NOT show an online/offline label
//   • Connects to syncStateProvider — updated by real SyncManager callbacks
//
// Usage:
//   Place SyncUploadDonut() as an overlay or in a Stack on any screen.
//   It self-hides when there is nothing to upload.
// ---------------------------------------------------------------------------

class SyncUploadDonut extends ConsumerStatefulWidget {
  const SyncUploadDonut({super.key});

  @override
  ConsumerState<SyncUploadDonut> createState() => _SyncUploadDonutState();
}

class _SyncUploadDonutState extends ConsumerState<SyncUploadDonut>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  // Tracks whether we're in "upload complete" hold phase
  bool _showingComplete = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sync = ref.watch(syncStateProvider);

    // Determine visibility
    final shouldShow = sync.isUploading || (sync.total > 0 && !sync.isDone);

    // "Upload complete" ONLY when every item in the batch succeeded.
    // partial = cycle done but not all completed (some failed or still queued)
    final isFullyComplete = !sync.isUploading &&
        sync.total > 0 &&
        sync.completed == sync.total &&
        sync.failed == 0;

    // Manage fade in/out + "upload complete" hold
    if (shouldShow || isFullyComplete) {
      if (!_showingComplete && isFullyComplete) {
        _showingComplete = true;
        _fadeController.forward();
        // Hold "Upload complete" for 2 seconds then fade out
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            _fadeController.reverse().then((_) {
              if (mounted) setState(() => _showingComplete = false);
            });
          }
        });
      } else if (!_showingComplete) {
        _fadeController.forward();
      }
    } else if (!_showingComplete) {
      _fadeController.reverse();
    }

    // If nothing to show and not fading, return empty
    if (sync.total == 0 && !_showingComplete) return const SizedBox.shrink();

    // ── State labels ─────────────────────────────────────────────────────────
    final String label;
    final String countText;
    if (isFullyComplete || _showingComplete) {
      // All done successfully
      label = 'Upload complete';
      countText = '${sync.completed} uploaded';
    } else if (!sync.isUploading && sync.failed > 0) {
      // Cycle done but some items failed
      label = 'Partial upload';
      countText = '${sync.completed} of ${sync.total} (${sync.failed} failed)';
    } else {
      // Actively uploading
      label = 'Uploading...';
      countText = '${sync.completed} of ${sync.total}';
    }

    final progress = sync.progress;
    final percent = sync.percent;

    return FadeTransition(
      opacity: _fadeAnim,
      child: _DonutCard(
        progress: progress,
        percent: percent,
        label: label,
        countText: countText,
        isComplete: isFullyComplete || _showingComplete,
      ),
    );
  }
}

class _DonutCard extends StatelessWidget {
  final double progress;
  final int percent;
  final String label;
  final String countText;
  final bool isComplete;

  const _DonutCard({
    required this.progress,
    required this.percent,
    required this.label,
    required this.countText,
    required this.isComplete,
  });

  @override
  Widget build(BuildContext context) {
    final color = isComplete ? AppColors.success : AppColors.primaryGreen;

    return Container(
      width: 112,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: color.withValues(alpha: 0.18),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Donut ──────────────────────────────────────────────────────
          SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background ring
                CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 6,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    color.withValues(alpha: 0.12),
                  ),
                ),
                // Progress arc
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: progress),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOut,
                  builder: (context, value, _) {
                    return CircularProgressIndicator(
                      value: value,
                      strokeWidth: 6,
                      strokeCap: StrokeCap.round,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    );
                  },
                ),
                // Percentage text in centre
                Text(
                  '$percent%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: color,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ── Status label ────────────────────────────────────────────────
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isComplete ? AppColors.success : AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 2),

          // ── Count text (e.g. "6 of 10") ─────────────────────────────────
          Text(
            countText,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
