import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/admin_issue_model.dart';

// ---------------------------------------------------------------------------
// PHASE 23 — Admin Issue Detail Provider
// ---------------------------------------------------------------------------

class AdminIssueDetailState {
  final AdminIssueModel? issue;
  final List<Map<String, dynamic>> progressUpdates;
  final List<Map<String, dynamic>> attachments;
  final bool isLoading;
  final String? error;

  AdminIssueDetailState({
    this.issue,
    this.progressUpdates = const [],
    this.attachments = const [],
    this.isLoading = false,
    this.error,
  });

  AdminIssueDetailState copyWith({
    AdminIssueModel? issue,
    List<Map<String, dynamic>>? progressUpdates,
    List<Map<String, dynamic>>? attachments,
    bool? isLoading,
    String? error,
  }) {
    return AdminIssueDetailState(
      issue: issue ?? this.issue,
      progressUpdates: progressUpdates ?? this.progressUpdates,
      attachments: attachments ?? this.attachments,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AdminIssueDetailNotifier extends StateNotifier<AdminIssueDetailState> {
  final String issueId;

  AdminIssueDetailNotifier(this.issueId) : super(AdminIssueDetailState()) {
    fetchDetail();
  }

  Future<void> fetchDetail() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final client = Supabase.instance.client;

      // 1. Fetch Issue Data
      final issueResponse = await client
          .from('issues')
          .select('*, leader:profiles!issues_leader_id_fkey(full_name), villages(name), issue_categories(name)')
          .eq('id', issueId)
          .maybeSingle();

      if (issueResponse == null) {
        state = state.copyWith(isLoading: false, error: 'Issue not found');
        return;
      }

      final issue = AdminIssueModel.fromJson(issueResponse);

      // 2. Fetch Progress Updates
      final progressResponse = await client
          .from('progress_updates')
          .select('*, profiles(full_name)')
          .eq('issue_id', issueId)
          .order('created_at', ascending: true);

      // 3. Fetch Attachments (if the table exists and has data)
      // We will catch exceptions specifically for the attachments query
      // in case the table hasn't been created yet in dev.
      List<Map<String, dynamic>> attachments = [];
      try {
        final attachmentResponse = await client
            .from('issue_attachments')
            .select('*')
            .eq('issue_id', issueId);
        attachments = List<Map<String, dynamic>>.from(attachmentResponse);
      } catch (_) {
        // Table might not exist or be accessible, ignore safely
      }

      state = state.copyWith(
        issue: issue,
        progressUpdates: List<Map<String, dynamic>>.from(progressResponse),
        attachments: attachments,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to load issue details: $e');
    }
  }
}

final adminIssueDetailProvider = StateNotifierProvider.family<AdminIssueDetailNotifier, AdminIssueDetailState, String>((ref, issueId) {
  return AdminIssueDetailNotifier(issueId);
});
