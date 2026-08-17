import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';

class VillageDetailScreen extends StatefulWidget {
  final String villageId;

  const VillageDetailScreen({super.key, required this.villageId});

  @override
  State<VillageDetailScreen> createState() => _VillageDetailScreenState();
}

class _VillageDetailScreenState extends State<VillageDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const List<String> _villageNames = [
    'Chandpur',
    'Kothrud',
    'Ambegaon',
    'Mandvi',
    'Shirur',
    'Baramati',
    'Phaltan',
    'Wai',
    'Karad',
    'Satara',
  ];

  String get _villageName {
    final index = int.tryParse(widget.villageId) ?? 0;
    if (index >= 0 && index < _villageNames.length) {
      return _villageNames[index];
    }
    return 'Village';
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 220,
              pinned: true,
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: AppColors.textOnPrimary,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primaryGreen,
                        AppColors.primaryGreenDark,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppConstants.spacingMd,
                        60,
                        AppConstants.spacingMd,
                        AppConstants.spacingMd,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _villageName,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textOnPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Pune District, Maharashtra',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textOnPrimary
                                  .withValues(alpha: 0.8),
                            ),
                          ),
                          const Spacer(),
                          // Stats Row
                          Row(
                            children: [
                              _StatBadge(
                                icon: Icons.people_rounded,
                                label: 'Members',
                                value: '24',
                              ),
                              const SizedBox(width: AppConstants.spacingSm + 4),
                              _StatBadge(
                                icon: Icons.report_problem_rounded,
                                label: 'Issues',
                                value: '3',
                              ),
                              const SizedBox(width: AppConstants.spacingSm + 4),
                              _StatBadge(
                                icon: Icons.groups_rounded,
                                label: 'Meetings',
                                value: '8',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              title: Text(
                _villageName,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: AppColors.textOnPrimary,
                indicatorWeight: 3,
                labelColor: AppColors.textOnPrimary,
                unselectedLabelColor:
                    AppColors.textOnPrimary.withValues(alpha: 0.6),
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 13,
                ),
                tabs: const [
                  Tab(text: 'Overview'),
                  Tab(text: 'Members'),
                  Tab(text: 'Issues'),
                  Tab(text: 'Meetings'),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _OverviewTab(villageName: _villageName),
            const _MembersTab(),
            const _IssuesTab(),
            const _MeetingsTab(),
          ],
        ),
      ),
    );
  }
}

// -- Stat Badge Widget ---

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatBadge({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingSm,
          vertical: AppConstants.spacingSm + 2,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.textOnPrimary, size: 22),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textOnPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textOnPrimary.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -- Tab Content Widgets ---

class _OverviewTab extends StatelessWidget {
  final String villageName;

  const _OverviewTab({required this.villageName});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      children: [
        _SectionCard(
          title: 'About',
          icon: Icons.info_outline_rounded,
          child: Text(
            '$villageName is an active village under the SSP program. '
            'The village has been part of the DMP initiative since 2023 and '
            'has shown consistent engagement with community development activities.',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: AppConstants.spacingMd),
        _SectionCard(
          title: 'Recent Activity',
          icon: Icons.history_rounded,
          child: Column(
            children: const [
              _ActivityItem(
                icon: Icons.groups_rounded,
                title: 'Monthly Meeting Conducted',
                subtitle: 'July 10, 2025',
                color: AppColors.secondaryTerracotta,
              ),
              SizedBox(height: AppConstants.spacingSm + 4),
              _ActivityItem(
                icon: Icons.report_rounded,
                title: 'New Issue Reported — Water Supply',
                subtitle: 'July 8, 2025',
                color: AppColors.statusReported,
              ),
              SizedBox(height: AppConstants.spacingSm + 4),
              _ActivityItem(
                icon: Icons.person_add_rounded,
                title: '2 New Members Registered',
                subtitle: 'July 5, 2025',
                color: AppColors.info,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MembersTab extends StatelessWidget {
  const _MembersTab();

  static const List<Map<String, String>> _members = [
    {'name': 'Ramesh Patil', 'role': 'Sarpanch'},
    {'name': 'Sunita Jadhav', 'role': 'Secretary'},
    {'name': 'Ashok Shinde', 'role': 'Member'},
    {'name': 'Priya Kulkarni', 'role': 'Member'},
    {'name': 'Vikram Deshmukh', 'role': 'Member'},
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      children: [
        Text(
          '24 Members',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppConstants.spacingSm + 4),
        ..._members.map((member) => Card(
              elevation: 0,
              color: AppColors.surfaceCard,
              margin: const EdgeInsets.only(bottom: AppConstants.spacingSm),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppConstants.radiusMd),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      AppColors.primaryGreen.withValues(alpha: 0.12),
                  child: Text(
                    member['name']![0],
                    style: const TextStyle(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                title: Text(
                  member['name']!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  member['role']!,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textHint),
              ),
            )),
      ],
    );
  }
}

class _IssuesTab extends StatelessWidget {
  const _IssuesTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      children: [
        _IssueListItem(
          title: 'Water Supply Disruption',
          status: 'Reported',
          statusColor: AppColors.statusReported,
          date: 'Jul 8, 2025',
        ),
        _IssueListItem(
          title: 'Road Repair Needed',
          status: 'In Progress',
          statusColor: AppColors.statusInProgress,
          date: 'Jun 28, 2025',
        ),
        _IssueListItem(
          title: 'School Building Maintenance',
          status: 'Resolved',
          statusColor: AppColors.statusResolved,
          date: 'Jun 15, 2025',
        ),
      ],
    );
  }
}

class _MeetingsTab extends StatelessWidget {
  const _MeetingsTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      children: [
        _MeetingListItem(
          title: 'Monthly Review Meeting',
          date: 'Jul 10, 2025',
          attendees: 18,
          status: 'Completed',
        ),
        _MeetingListItem(
          title: 'Budget Planning Session',
          date: 'Jun 25, 2025',
          attendees: 12,
          status: 'Completed',
        ),
        _MeetingListItem(
          title: 'Community Health Camp',
          date: 'Jul 20, 2025',
          attendees: 0,
          status: 'Scheduled',
        ),
      ],
    );
  }
}

// -- Reusable Card Widgets ---

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.surfaceCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: AppColors.primaryGreen),
                const SizedBox(width: AppConstants.spacingSm),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingMd),
            child,
          ],
        ),
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _ActivityItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppConstants.spacingSm),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: AppConstants.spacingSm + 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textHint,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _IssueListItem extends StatelessWidget {
  final String title;
  final String status;
  final Color statusColor;
  final String date;

  const _IssueListItem({
    required this.title,
    required this.status,
    required this.statusColor,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.surfaceCard,
      margin: const EdgeInsets.only(bottom: AppConstants.spacingSm),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          date,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppConstants.spacingSm),
          ),
          child: Text(
            status,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
        ),
      ),
    );
  }
}

class _MeetingListItem extends StatelessWidget {
  final String title;
  final String date;
  final int attendees;
  final String status;

  const _MeetingListItem({
    required this.title,
    required this.date,
    required this.attendees,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final isScheduled = status == 'Scheduled';

    return Card(
      elevation: 0,
      color: AppColors.surfaceCard,
      margin: const EdgeInsets.only(bottom: AppConstants.spacingSm),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isScheduled
                ? AppColors.info.withValues(alpha: 0.12)
                : AppColors.secondaryTerracotta.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppConstants.spacingSm),
          ),
          child: Icon(
            isScheduled ? Icons.event_rounded : Icons.event_available_rounded,
            color: isScheduled ? AppColors.info : AppColors.secondaryTerracotta,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          '$date • ${attendees > 0 ? '$attendees attendees' : 'Upcoming'}',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
