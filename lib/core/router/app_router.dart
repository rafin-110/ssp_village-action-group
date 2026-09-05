import 'package:go_router/go_router.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/shell/screens/app_shell.dart';

import 'leader_routes.dart';









// ── Admin screens ─────────────────────────────────────────────────────────────
import '../../features/admin/screens/admin_dashboard_screen.dart';
import '../../features/admin/screens/admin_villages_screen.dart';
import '../../features/admin/screens/verification_center_screen.dart';
import '../../features/admin/screens/admin_review_screen.dart';
import '../../features/admin/screens/admin_notifications_screen.dart';



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

/// GoRouter configuration for VAG-DMP.
/// Two ShellRoutes: Leader (mobile) and Admin (dashboard).
final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  debugLogDiagnostics: true,
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
          builder: (context, state) => const AdminDashboardScreen(),
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
          builder: (context, state) => state.matchedLocation.startsWith('/admin') ? const AdminVillagesScreen() : const VillageListScreen(),
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
