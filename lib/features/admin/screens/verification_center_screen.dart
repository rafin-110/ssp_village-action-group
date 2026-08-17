import 'package:flutter/material.dart';

/// PHASE 05 PLACEHOLDER
/// The verification center was rebuilt in Phase 02 but still referenced the
/// old IssueCategory enum. Now that categories are data-driven UUID strings
/// (Phase 06), this screen is replaced with a clean placeholder.
///
/// This screen will be rebuilt in Phase 21 (NGO Issue List & Search).
class VerificationCenterScreen extends StatelessWidget {
  const VerificationCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Issue Monitor'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.monitor_heart_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Coming in Phase 21',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'NGO Issue list, search, and filters will be built here.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
