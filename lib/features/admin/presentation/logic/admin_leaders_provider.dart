import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ---------------------------------------------------------------------------
// PHASE 27 — Admin Leaders Provider
// ---------------------------------------------------------------------------

class AdminLeadersState {
  final List<Map<String, dynamic>> profiles;
  final bool isLoading;
  final String? error;

  AdminLeadersState({
    this.profiles = const [],
    this.isLoading = false,
    this.error,
  });

  AdminLeadersState copyWith({
    List<Map<String, dynamic>>? profiles,
    bool? isLoading,
    String? error,
  }) {
    return AdminLeadersState(
      profiles: profiles ?? this.profiles,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AdminLeadersNotifier extends StateNotifier<AdminLeadersState> {
  AdminLeadersNotifier() : super(AdminLeadersState()) {
    fetchLeaders();
  }

  Future<void> fetchLeaders() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final client = Supabase.instance.client;
      // Fetch all profiles (including supervisors/admins for completeness)
      final response = await client
          .from('profiles')
          .select('*, villages(name)')
          .order('role', ascending: true)
          .order('full_name', ascending: true);

      state = state.copyWith(
        profiles: List<Map<String, dynamic>>.from(response),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to load users: $e');
    }
  }

  /// Toggle the 'active' status of a user
  Future<void> toggleUserStatus(String profileId, bool currentStatus) async {
    try {
      final client = Supabase.instance.client;
      await client
          .from('profiles')
          .update({'active': !currentStatus})
          .eq('id', profileId);
          
      // Update local state
      final updated = state.profiles.map((p) {
        if (p['id'] == profileId) {
          return {...p, 'active': !currentStatus};
        }
        return p;
      }).toList();
      
      state = state.copyWith(profiles: updated);
    } catch (e) {
      state = state.copyWith(error: 'Failed to update user status: $e');
    }
  }

  /// Change role and village of a user
  Future<void> updateUser(String profileId, String newRole, String? newVillageId) async {
    try {
      final client = Supabase.instance.client;
      await client
          .from('profiles')
          .update({
            'role': newRole,
            'village_id': newVillageId,
          })
          .eq('id', profileId);
          
      // Refresh list to get joined village name
      await fetchLeaders();
    } catch (e) {
      state = state.copyWith(error: 'Failed to update user: $e');
    }
  }

  /// Create a new user via RPC
  Future<bool> createUser({
    required String username,
    required String password,
    required String fullName,
    required String role,
    required String villageId,
  }) async {
    try {
      state = state.copyWith(isLoading: true);
      final client = Supabase.instance.client;
      
      await client.rpc('admin_create_user', params: {
        'p_username': username,
        'p_password': password,
        'p_full_name': fullName,
        'p_role': role,
        'p_village_id': villageId,
      });

      await fetchLeaders();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to create user: $e');
      return false;
    }
  }
}

final adminLeadersProvider = StateNotifierProvider<AdminLeadersNotifier, AdminLeadersState>((ref) {
  return AdminLeadersNotifier();
});
