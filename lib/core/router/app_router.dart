import 'package:go_router/go_router.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/shell/screens/app_shell.dart';

import 'leader_routes.dart';









// ── Admin screens ─────────────────────────────────────────────────────────────
import '../../features/admin/screens/admin_analytics_screen.dart';
import '../../features/admin/screens/admin_issue_list_screen.dart';
import '../../features/admin/screens/admin_issue_detail_screen.dart';
import '../../features/admin/screens/admin_leaders_screen.dart';
import '../../features/admin/screens/admin_villages_screen.dart';
import '../../features/admin/screens/verification_center_screen.dart';
import '../../features/admin/screens/admin_review_screen.dart';
import '../../features/admin/screens/admin_notifications_screen.dart';
import '../../features/admin/screens/admin_settings_screen.dart';



// ── Shared ────────────────────────────────────────────────────────────────────
import '../../features/profile/screens/profile_screen.dart';

// ---------------------------------------------------------------------------
// PHASE 08 — App Router (updated for Report Issue screen)
// ---------------------------------------------------------------------------
// Route changes:
//   /leader/submit  →  /leader/report  (ReportIssueScreen — Phase 08)
//   /leader/history →  /leader/issues  (issue list — Phase 09, placeholder for now)
//   /leader/submit  kept as redirect for backward compatibility
// ---------------------------------------------------------------------------

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_providers.dart';
import '../auth/user_role.dart';

/// GoRouter configuration for VAG-DMP exposed as a provider.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final user = ref.read(currentUserProvider);
      final isLogin = state.uri.path == '/login';
      
      if (user == null) {
        return isLogin ? null : '/login';
      }
      
      if (isLogin) {
        if (user.role == UserRole.admin) {
          return '/admin/dashboard';
        } else {
          return '/leader/submit';
        }
      }
      return null;
    },
    routes: [
    // ── Authentication ────────────────────────────────────────────────────
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      name: 'forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),

    // ── Leader Shell ──────────────────────────────────────────────────────
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        // Report Issue (Phase 08) — primary leader entry point
        GoRoute(
          path: '/leader/report',
          name: 'leader-report',
          builder: (context, state) => const ReportIssueScreen(),
        ),

        // Backward-compat: /leader/submit redirects to /leader/report
        GoRoute(
          path: '/leader/submit',
          name: 'leader-submit',
          redirect: (_, __) => '/leader/report',
        ),

        // Issue list (Phase 09 — real IssueListScreen)
        GoRoute(
          path: '/leader/issues',
          name: 'leader-issues',
          builder: (context, state) => const IssueListScreen(),
          routes: [
            GoRoute(
              path: ':issueId',
              name: 'issue-detail',
              builder: (context, state) {
                final issueId = state.pathParameters['issueId']!;
                return IssueDetailScreen(issueId: issueId);
              },
            ),
          ],
        ),

        // Old history route — redirect to new issues route
        GoRoute(
          path: '/leader/history',
          name: 'leader-history',
          redirect: (_, __) => '/leader/issues',
        ),

        // Meetings
        GoRoute(
          path: '/leader/meetings',
          name: 'leader-meetings',
          builder: (context, state) => const MeetingListScreen(),
          routes: [
            GoRoute(
              path: 'create',
              name: 'leader-create-meeting',
              builder: (context, state) => const CreateMeetingScreen(),
            ),
            GoRoute(
              path: ':meetingId',
              name: 'leader-meeting-detail',
              builder: (context, state) {
                final meetingId = state.pathParameters['meetingId']!;
                return MeetingDetailScreen(meetingId: meetingId);
              },
            ),
          ],
        ),

        // Profile
        GoRoute(
          path: '/leader/profile',
          name: 'leader-profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),

    // ── Admin Shell ───────────────────────────────────────────────────────
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: '/admin/dashboard',
          name: 'admin-dashboard',
          builder: (context, state) => const AdminAnalyticsScreen(),
        ),
        GoRoute(
          path: '/admin/issues',
          name: 'admin-issues',
          builder: (context, state) => const AdminIssueListScreen(),
          routes: [
            GoRoute(
              path: ':issueId',
              name: 'admin-issue-detail',
              builder: (context, state) {
                final issueId = state.pathParameters['issueId']!;
                return AdminIssueDetailScreen(issueId: issueId);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/admin/leaders',
          name: 'admin-leaders',
          builder: (context, state) => const AdminLeadersScreen(),
        ),
        GoRoute(
          path: '/admin/settings',
          name: 'admin-settings',
          builder: (context, state) => const AdminSettingsScreen(),
        ),
        GoRoute(
          path: '/admin/verify',
          name: 'admin-verify',
          builder: (context, state) => const VerificationCenterScreen(),
          routes: [
            GoRoute(
              path: ':submissionId',
              name: 'admin-review',
              builder: (context, state) {
                final submissionId = state.pathParameters['submissionId']!;
                return AdminReviewScreen(submissionId: submissionId);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/admin/notifications',
          name: 'admin-notifications',
          builder: (context, state) => const AdminNotificationsScreen(),
        ),
        GoRoute(
          path: '/admin/villages',
          name: 'admin-villages',
          builder: (context, state) => const AdminVillagesScreen(),
          routes: [
            GoRoute(
              path: ':villageId',
              name: 'admin-village-detail',
              builder: (context, state) {
                final villageId = state.pathParameters['villageId']!;
                return VillageDetailScreen(villageId: villageId);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/admin/profile',
          name: 'admin-profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
  ],
);
});
