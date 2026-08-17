import 'package:flutter/material.dart';
import 'package:vag_dmp_frontend/core/theme/app_colors.dart';
import 'package:vag_dmp_frontend/core/constants/app_constants.dart';

class AdminNotificationsScreen extends StatelessWidget {
  const AdminNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock notifications data
    final notifications = [
      {
        'title': 'New submission from Palghar',
        'subtitle': 'Water pump installation completed.',
        'time': '10 mins ago',
        'icon': Icons.water_drop,
        'unread': true,
      },
      {
        'title': 'Revision updated',
        'subtitle': 'Ramesh updated the road repair photos.',
        'time': '1 hr ago',
        'icon': Icons.add_road,
        'unread': true,
      },
      {
        'title': 'Village meeting logged',
        'subtitle': 'Society meeting at Dahanu reported.',
        'time': '2 hrs ago',
        'icon': Icons.people,
        'unread': false,
      },
      {
        'title': 'School supplies delivered',
        'subtitle': 'New submission for Education category.',
        'time': '5 hrs ago',
        'icon': Icons.school,
        'unread': false,
      },
      {
        'title': 'Sync conflict resolved',
        'subtitle': 'Issue #4052 was synced successfully.',
        'time': '1 day ago',
        'icon': Icons.sync,
        'unread': false,
      },
      {
        'title': 'Monthly target reached',
        'subtitle': '100+ verified submissions this month!',
        'time': '1 day ago',
        'icon': Icons.star,
        'unread': false,
      },
      {
        'title': 'New user registered',
        'subtitle': 'Supervisor Suresh joined.',
        'time': '2 days ago',
        'icon': Icons.person_add,
        'unread': false,
      },
      {
        'title': 'System maintenance',
        'subtitle': 'Scheduled downtime on Sunday 2 AM.',
        'time': '3 days ago',
        'icon': Icons.settings,
        'unread': false,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notif = notifications[index];
          final bool isUnread = notif['unread'] as bool;

          return Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF2E7D32).withOpacity(isUnread ? 0.2 : 0.05),
                child: Icon(
                  notif['icon'] as IconData,
                  color: isUnread ? const Color(0xFF2E7D32) : Colors.grey,
                ),
              ),
              title: Text(
                notif['title'] as String,
                style: TextStyle(
                  fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(notif['subtitle'] as String),
                  const SizedBox(height: 4),
                  Text(
                    notif['time'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      color: isUnread ? const Color(0xFFE64A19) : Colors.grey,
                    ),
                  ),
                ],
              ),
              trailing: isUnread
                  ? Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2E7D32),
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
              onTap: () {
                // Mark as read logic
              },
            ),
          );
        },
      ),
    );
  }
}
