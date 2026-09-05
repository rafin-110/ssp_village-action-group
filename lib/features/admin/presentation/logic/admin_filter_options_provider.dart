import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Holds the available options for the dropdown filters in the Admin Dashboard.
class AdminFilterOptions {
  final List<Map<String, dynamic>> villages;
  final List<Map<String, dynamic>> categories;
  final List<Map<String, dynamic>> leaders;

  AdminFilterOptions({
    this.villages = const [],
    this.categories = const [],
    this.leaders = const [],
  });
}

/// Fetches the distinct villages, categories, and leaders from Supabase
/// to populate the filter dropdowns in the Admin Dashboard.
final adminFilterOptionsProvider = FutureProvider<AdminFilterOptions>((ref) async {
  final client = Supabase.instance.client;

  final villages = await client.from('villages').select('id, name').order('name');
  final categories = await client.from('issue_categories').select('id, name').order('name');
  final leaders = await client.from('profiles').select('id, full_name').eq('role', 'leader').order('full_name');

  return AdminFilterOptions(
    villages: List<Map<String, dynamic>>.from(villages as List),
    categories: List<Map<String, dynamic>>.from(categories as List),
    leaders: List<Map<String, dynamic>>.from(leaders as List),
  );
});
