import 'package:flutter/material.dart';

/// PHASE 02 PLACEHOLDER
/// The old admin dashboard was built around the photo verification workflow.
/// It has been replaced as part of Phase 02 photo removal.
/// The NGO Supervisor/Admin dashboard will be fully rebuilt in Phase 20.
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NGO Dashboard'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.dashboard_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Coming in Phase 20',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'NGO Supervisor/Admin dashboard will be built here.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
