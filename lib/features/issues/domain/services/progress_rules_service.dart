// ---------------------------------------------------------------------------
// PHASE 13 — Progress Rules Service
// ---------------------------------------------------------------------------
// Pure domain service — no Flutter, no Isar, no Riverpod dependencies.
// All progress business rules are centralized here so they are enforced
// consistently regardless of which layer calls them.
//
// Any code that creates or validates a ProgressUpdate MUST call this service.
//
// Rules (§15–21 of project_documentation.md):
//   R1. progressPercent must be in range [1..100]
//   R2. progressPercent must be STRICTLY GREATER than currentProgress
//   R3. notes must be non-empty and at least 5 characters
//   R4. The parent issue must not be locked (isEditable = true)
//   R5. When progressPercent reaches 100 → IssueStatus becomes completed
//       (The status transition is performed by ProgressUpdateNotifier, not here)
//   R6. A completed issue (100%) can still receive updates ONLY if not locked
//       (e.g. Leader accidentally said 100% → can't fix; they must End Project)
// ---------------------------------------------------------------------------

import '../entities/issue.dart';

/// Result of a progress validation check.
/// Use [isValid] to check outcome, [errorMessage] to surface to UI.
class ProgressValidationResult {
  final bool isValid;
  final String? errorMessage;

  const ProgressValidationResult.ok()
      : isValid = true,
        errorMessage = null;

  const ProgressValidationResult.fail(String message)
      : isValid = false,
        errorMessage = message;

  @override
  String toString() =>
      isValid ? 'ProgressValidationResult.ok' : 'ProgressValidationResult.fail($errorMessage)';
}

/// Centralizes all progress business rules.
///
/// Usage:
/// ```dart
/// final result = ProgressRulesService.validate(
///   newProgress: 50,
///   currentIssue: issue,
///   notes: 'Road base laid',
/// );
/// if (!result.isValid) throw ProgressRuleException(result.errorMessage!);
/// ```
class ProgressRulesService {
  // Private constructor — this is a static utility class.
  ProgressRulesService._();

  /// Validates that adding a progress update with [newProgress] is allowed
  /// given the current state of [issue].
  ///
  /// Returns [ProgressValidationResult.ok()] if all rules pass.
  /// Returns [ProgressValidationResult.fail(message)] with a user-readable
  /// message if any rule is violated.
  static ProgressValidationResult validate({
    required int newProgress,
    required Issue issue,
    required String notes,
  }) {
    // R4 — Issue must not be locked
    if (issue.locked) {
      return const ProgressValidationResult.fail(
        'This project is closed and cannot be updated.',
      );
    }

    // R1 — Progress must be in range 1..100
    if (newProgress < 1 || newProgress > 100) {
      return ProgressValidationResult.fail(
        'Progress must be between 1% and 100%. Got $newProgress%.',
      );
    }

    // R2 — Must be strictly greater than current progress
    if (newProgress <= issue.currentProgress) {
      return ProgressValidationResult.fail(
        'New progress ($newProgress%) must be higher than the current '
        'progress (${issue.currentProgress}%). Progress can only increase.',
      );
    }

    // R3 — Notes must be non-empty and at least 5 characters
    final trimmedNotes = notes.trim();
    if (trimmedNotes.isEmpty) {
      return const ProgressValidationResult.fail(
        'Please describe what was done. Notes cannot be empty.',
      );
    }
    if (trimmedNotes.length < 5) {
      return const ProgressValidationResult.fail(
        'Notes must be at least 5 characters long.',
      );
    }

    return const ProgressValidationResult.ok();
  }

  /// Computes the [IssueStatus] that should result from setting [newProgress].
  ///
  /// Rule R5: 100% → completed. Otherwise → inProgress.
  /// (Closed / reported are driven by other operations, not progress.)
  static IssueStatus computeNewStatus(int newProgress) {
    return newProgress >= 100
        ? IssueStatus.completed
        : IssueStatus.inProgress;
  }

  /// Returns true if a progress update is theoretically possible on [issue].
  /// Does NOT validate the specific percentage — use [validate] for that.
  static bool canAddProgress(Issue issue) {
    return !issue.locked;
  }

  /// Returns true if this issue is eligible to be closed (END PROJECT).
  ///
  /// Rule: progress must be 100% AND issue must not already be locked.
  static bool canClose(Issue issue) {
    return issue.currentProgress == 100 && !issue.locked;
  }
}

/// Thrown when a progress update violates a business rule.
/// Caught by [ProgressUpdateNotifier] and surfaced as [AsyncError].
class ProgressRuleException implements Exception {
  final String message;
  const ProgressRuleException(this.message);

  @override
  String toString() => 'ProgressRuleException: $message';
}
