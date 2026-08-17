import 'package:flutter/material.dart';

/// PHASE 02 PLACEHOLDER
/// The old admin review screen was built around photo proof verification
/// (before/after photos, expenditureDetails, resolutionNotes, adminReviewNote,
/// timeline, documentPaths). All removed per FINAL v3 spec.
/// This screen will be rebuilt as part of the NGO issue detail view in Phase 23.
class AdminReviewScreen extends StatelessWidget {
  final String submissionId;

  const AdminReviewScreen({
    super.key,
    required this.submissionId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Issue Review'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.fact_check_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Coming in Phase 23',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              'NGO issue detail for: $submissionId',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
