import 'package:flutter/material.dart';

/// PHASE 26 PLACEHOLDER
/// NGO Supervisor/Admin settings.
class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.settings_rounded, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Settings Coming in Phase 26',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
