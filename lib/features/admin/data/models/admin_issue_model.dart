// ---------------------------------------------------------------------------
// PHASE 21 — Admin Issue Model
// ---------------------------------------------------------------------------
// A lightweight model specific to the Admin Dashboard.
// Maps the joined Supabase data (issues + profiles + villages + categories).
// ---------------------------------------------------------------------------

class AdminIssueModel {
  final String id;
  final String title;
  final String description;
  final String status;
  final int currentProgress;
  final DateTime createdAt;
  final String? leaderName;
  final String? villageName;
  final String? categoryName;

  AdminIssueModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.currentProgress,
    required this.createdAt,
    this.leaderName,
    this.villageName,
    this.categoryName,
  });

  factory AdminIssueModel.fromJson(Map<String, dynamic> json) {
    // Supabase joins return objects for foreign keys
    final profile = json['leader'] as Map<String, dynamic>?;
    final village = json['villages'] as Map<String, dynamic>?;
    final category = json['issue_categories'] as Map<String, dynamic>?;

    return AdminIssueModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      status: json['status'] as String,
      currentProgress: json['current_progress'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      leaderName: profile?['full_name'] as String?,
      villageName: village?['name'] as String?,
      categoryName: category?['name'] as String?,
    );
  }
  
  // Format the status for UI display
  String get displayStatus {
    switch (status) {
      case 'reported':
        return 'New';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'closed':
        return 'Closed';
      default:
        return status;
    }
  }
}
