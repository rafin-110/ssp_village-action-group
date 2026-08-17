import 'package:flutter/material.dart';

/// PHASE 02 PLACEHOLDER
/// The old submission detail screen (which showed before/after photos) has been
/// removed per FINAL v3 spec. Will be rebuilt as IssueDetailScreen in Phase 10.
class SubmissionDetailScreen extends StatelessWidget {
  final String submissionId;

  const SubmissionDetailScreen({
    super.key,
    required this.submissionId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Issue Details')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.article_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Coming in Phase 10',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              'Issue detail for: $submissionId',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
