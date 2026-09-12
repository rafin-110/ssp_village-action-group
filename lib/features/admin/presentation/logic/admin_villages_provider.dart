import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class AdminVillagesState {
  final List<Map<String, dynamic>> villages;
  final bool isLoading;
  final String? error;

  AdminVillagesState({
    this.villages = const [],
    this.isLoading = false,
    this.error,
  });

  AdminVillagesState copyWith({
    List<Map<String, dynamic>>? villages,
    bool? isLoading,
    String? error,
  }) {
    return AdminVillagesState(
      villages: villages ?? this.villages,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AdminVillagesNotifier extends StateNotifier<AdminVillagesState> {
  AdminVillagesNotifier() : super(AdminVillagesState()) {
    fetchVillages();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  Future<void> fetchVillages() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final client = Supabase.instance.client;
      final response = await client
          .from('villages')
          .select('id, name, district, state')
          .order('name', ascending: true);

      state = state.copyWith(
        villages: List<Map<String, dynamic>>.from(response),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to load villages: $e');
    }
  }

  Future<bool> createVillage({
    required String name,
    required String district,
    required String stateName,
  }) async {
    try {
      state = state.copyWith(isLoading: true);
      final client = Supabase.instance.client;
      
      final newId = const Uuid().v4();
      await client.from('villages').insert({
        'id': newId,
        'name': name,
        'district': district,
        'state': stateName,
      });

      await fetchVillages();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to create village: $e');
      return false;
    }
  }
}

final adminVillagesProvider = StateNotifierProvider<AdminVillagesNotifier, AdminVillagesState>((ref) {
  return AdminVillagesNotifier();
});
