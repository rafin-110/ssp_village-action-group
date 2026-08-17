import 'package:flutter/material.dart';

/// PHASE 02 PLACEHOLDER
/// The old photo-based submission flow has been removed per FINAL v3 spec.
/// This screen will be replaced by ReportIssueScreen in Phase 08.
class SubmissionFlowScreen extends StatelessWidget {
  const SubmissionFlowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report an Issue')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction_rounded, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Coming in Phase 08',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Report Issue UI will be built here.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
