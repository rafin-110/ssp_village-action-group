import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../domain/entities/meeting.dart';
import '../presentation/logic/meeting_providers.dart';

class MeetingListScreen extends ConsumerStatefulWidget {
  const MeetingListScreen({super.key});

  @override
  ConsumerState<MeetingListScreen> createState() => _MeetingListScreenState();
}

class _MeetingListScreenState extends ConsumerState<MeetingListScreen> {
  bool _showUpcoming = true;

  List<Meeting> _getFilteredMeetings(List<Meeting> meetings) {
    final now = DateTime.now();
    return meetings.where((m) {
      final isUpcoming = m.date.isAfter(now) || m.status == MeetingStatus.scheduled;
      return isUpcoming == _showUpcoming;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final asyncMeetings = ref.watch(meetingsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      appBar: AppBar(
        title: const Text(
          'Meetings',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/meetings/create'),
        backgroundColor: AppColors.secondaryTerracotta,
        foregroundColor: AppColors.textOnPrimary,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'New Meeting',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          // Toggle Header
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(
              AppConstants.spacingMd,
              0,
              AppConstants.spacingMd,
              AppConstants.spacingLg,
            ),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius:
                    BorderRadius.circular(AppConstants.radiusMd),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _ToggleButton(
                      label: 'Upcoming',
                      isSelected: _showUpcoming,
                      onTap: () => setState(() => _showUpcoming = true),
                    ),
                  ),
                  Expanded(
                    child: _ToggleButton(
                      label: 'Past',
                      isSelected: !_showUpcoming,
                      onTap: () => setState(() => _showUpcoming = false),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Meeting count
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.spacingMd,
              AppConstants.spacingMd,
              AppConstants.spacingMd,
              AppConstants.spacingSm,
            ),
            child: asyncMeetings.when(
              data: (meetings) {
                final count = _getFilteredMeetings(meetings).length;
                return Row(
                  children: [
                    Text(
                      '$count ${_showUpcoming ? "upcoming" : "past"} meetings',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),

          // Meeting List
          Expanded(
            child: asyncMeetings.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error loading meetings: $e')),
              data: (allMeetings) {
                final filtered = _getFilteredMeetings(allMeetings);
                
                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.event_busy_rounded,
                            size: 64, color: AppColors.textHint),
                        const SizedBox(height: AppConstants.spacingSm),
                        Text(
                          'No meetings found',
                          style: TextStyle(
                            color: AppColors.textHint,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingMd,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final meeting = filtered[index];
                    return _MeetingCard(
                      meeting: meeting,
                      onTap: () {
                        context.push('/meetings/${meeting.id}');
                      },
                    );
                  },
                );
              },
            ),
          ),

          // FAB spacer
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius:
              BorderRadius.circular(AppConstants.spacingSm + 2),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: isSelected
                  ? AppColors.primaryGreen
                  : AppColors.textOnPrimary.withValues(alpha: 0.8),
            ),
          ),
        ),
      ),
    );
  }
}

class _MeetingCard extends StatelessWidget {
  final Meeting meeting;
  final VoidCallback onTap;

  const _MeetingCard({
    required this.meeting,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = meeting.status == MeetingStatus.completed || meeting.status == MeetingStatus.cancelled;

    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingSm + 4),
      elevation: 0,
      color: AppColors.surfaceCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingMd),
          child: Row(
            children: [
              // Date column
              Container(
                width: 52,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.secondaryTerracotta.withValues(alpha: 0.10)
                      : AppColors.primaryGreen.withValues(alpha: 0.10),
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusMd),
                ),
                child: Column(
                  children: [
                    Text(
                      DateFormat('d').format(meeting.date),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: isCompleted
                            ? AppColors.secondaryTerracotta
                            : AppColors.primaryGreen,
                      ),
                    ),
                    Text(
                      DateFormat('MMM').format(meeting.date),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isCompleted
                            ? AppColors.secondaryTerracotta
                            : AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppConstants.spacingMd),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meeting.villageName, // using villageName as title fallback if title not in Meeting domain model
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: 14, color: AppColors.textHint),
                        const SizedBox(width: 3),
                        Text(
                          meeting.villageName,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: AppConstants.spacingMd),
                        Icon(Icons.people_outline_rounded,
                            size: 14, color: AppColors.textHint),
                        const SizedBox(width: 3),
                        Text(
                          '${meeting.attendeesCount}',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Status chip
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.secondaryTerracotta.withValues(alpha: 0.12)
                      : AppColors.info.withValues(alpha: 0.12),
                  borderRadius:
                      BorderRadius.circular(AppConstants.spacingSm),
                ),
                child: Text(
                  meeting.status.name[0].toUpperCase() + meeting.status.name.substring(1),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isCompleted
                        ? AppColors.secondaryTerracotta
                        : AppColors.info,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
