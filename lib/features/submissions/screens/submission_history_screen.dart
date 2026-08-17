import 'package:flutter/material.dart';

/// PHASE 02 PLACEHOLDER
/// The old submission history (photo-based) has been removed per FINAL v3 spec.
/// This screen will be replaced by the IssueListScreen in Phase 09.
class SubmissionHistoryScreen extends StatelessWidget {
  const SubmissionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Issues')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.list_alt_rounded, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Coming in Phase 09',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Issue list with filters will be built here.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
