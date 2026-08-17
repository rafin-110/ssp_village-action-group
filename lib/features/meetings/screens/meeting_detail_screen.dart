import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';

class MeetingDetailScreen extends StatelessWidget {
  final String meetingId;

  const MeetingDetailScreen({super.key, required this.meetingId});

  static const List<Map<String, dynamic>> _attendees = [
    {'name': 'Ramesh Patil', 'present': true},
    {'name': 'Sunita Jadhav', 'present': true},
    {'name': 'Ashok Shinde', 'present': true},
    {'name': 'Priya Kulkarni', 'present': false},
    {'name': 'Vikram Deshmukh', 'present': true},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      appBar: AppBar(
        title: const Text(
          'Meeting Details',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Meeting Info Card
            Card(
              elevation: 0,
              color: AppColors.surfaceCard,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppConstants.radiusXl),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spacingLg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primaryGreen,
                                AppColors.primaryGreenDark,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(
                                AppConstants.radiusMd),
                          ),
                          child: const Icon(
                            Icons.groups_rounded,
                            color: AppColors.textOnPrimary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: AppConstants.spacingMd),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Monthly Gram Sabha',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Regular monthly meeting',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryTerracotta
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(
                                AppConstants.spacingSm),
                          ),
                          child: const Text(
                            'Completed',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.secondaryTerracotta,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spacingLg),

                    // Details Grid
                    Container(
                      padding: const EdgeInsets.all(AppConstants.spacingMd),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundCream,
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusMd),
                      ),
                      child: Column(
                        children: [
                          _DetailRow(
                            icon: Icons.calendar_today_rounded,
                            label: 'Date',
                            value: 'July 10, 2025',
                          ),
                          const Divider(height: AppConstants.spacingMd * 2),
                          _DetailRow(
                            icon: Icons.location_city_rounded,
                            label: 'Village',
                            value: 'Chandpur',
                          ),
                          const Divider(height: AppConstants.spacingMd * 2),
                          _DetailRow(
                            icon: Icons.people_rounded,
                            label: 'Attendees',
                            value: '4 of 5 present',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingMd),

                    // Notes
                    const Text(
                      'Notes',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingSm),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppConstants.spacingMd),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundCream,
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusMd),
                      ),
                      child: const Text(
                        'Discussed water supply improvements, reviewed budget allocations for road repair, '
                        'and planned the upcoming health camp. All members agreed on the proposed timeline '
                        'for infrastructure projects.',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spacingLg),

            // Attendance Section
            Row(
              children: [
                const Icon(Icons.how_to_reg_rounded,
                    size: 20, color: AppColors.primaryGreen),
                const SizedBox(width: AppConstants.spacingSm),
                const Text(
                  'Attendance',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryTerracotta.withValues(alpha: 0.12),
                    borderRadius:
                        BorderRadius.circular(AppConstants.spacingSm),
                  ),
                  child: const Text(
                    '4/5 Present',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondaryTerracotta,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingMd),

            // Attendance List
            Card(
              elevation: 0,
              color: AppColors.surfaceCard,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppConstants.radiusLg),
              ),
              child: Column(
                children: List.generate(_attendees.length, (index) {
                  final attendee = _attendees[index];
                  final isPresent = attendee['present'] as bool;
                  final isLast = index == _attendees.length - 1;

                  return Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.spacingMd,
                          vertical: 4,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: isPresent
                              ? AppColors.secondaryTerracotta
                                  .withValues(alpha: 0.12)
                              : AppColors.error.withValues(alpha: 0.12),
                          child: Text(
                            (attendee['name'] as String)[0],
                            style: TextStyle(
                              color: isPresent
                                  ? AppColors.secondaryTerracotta
                                  : AppColors.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        title: Text(
                          attendee['name'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                            fontSize: 15,
                          ),
                        ),
                        trailing: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isPresent
                                ? AppColors.secondaryTerracotta
                                : AppColors.error
                                    .withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isPresent
                                ? Icons.check_rounded
                                : Icons.close_rounded,
                            color: isPresent
                                ? AppColors.textOnPrimary
                                : AppColors.error,
                            size: 18,
                          ),
                        ),
                      ),
                      if (!isLast)
                        const Divider(
                          height: 1,
                          indent: AppConstants.spacingMd + 56,
                          endIndent: AppConstants.spacingMd,
                        ),
                    ],
                  );
                }),
              ),
            ),
            const SizedBox(height: AppConstants.spacingLg),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primaryGreen),
        const SizedBox(width: AppConstants.spacingSm + 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
