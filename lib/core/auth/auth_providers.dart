import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'user_role.dart';

// ---------------------------------------------------------------------------
// PHASE 04 — Leader Profile & Village Scope
// ---------------------------------------------------------------------------
// Mock users now carry full profile data: username, village, district, state.
// Real profile data fetched from Supabase `profiles` table in Phase 16.
// ---------------------------------------------------------------------------

/// Mock Leader user — used during Phase 03–15 development.
const _mockLeader = AppUser(
  id: 'leader-001',
  username: 'sunita.kumar',
  name: 'Sunita Kumar',
  initials: 'SK',
  role: UserRole.leader,
  villageId: 'village-chandpur',
  villageName: 'Chandpur',
  district: 'Pune',
  state: 'Maharashtra',
);

/// Mock Admin user — used when RBAC toggle is switched during development.
const _mockAdmin = AppUser(
  id: 'admin-001',
  username: 'priya.deshmukh',
  name: 'Priya Deshmukh',
  initials: 'PD',
  role: UserRole.admin,
  villageId: null,
  villageName: null,
  district: null,
  state: 'Maharashtra',
);

/// The currently authenticated user.
/// Set at login; cleared on logout. Mutable only by auth/logout actions.
final currentUserProvider = StateProvider<AppUser>((ref) => _mockLeader);

/// Convenience provider: current user's role.
final userRoleProvider = Provider<UserRole>((ref) {
  return ref.watch(currentUserProvider).role;
});

/// Convenience provider: is the current user an admin/supervisor?
final isAdminProvider = Provider<bool>((ref) {
  return ref.watch(userRoleProvider) == UserRole.admin;
});

/// Returns the mock admin user (dev only).
AppUser get mockAdminUser => _mockAdmin;

/// Returns the mock leader user (dev only).
AppUser get mockLeaderUser => _mockLeader;
