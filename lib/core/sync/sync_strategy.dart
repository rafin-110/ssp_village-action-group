/// Abstract base class for all sync strategies.
abstract class SyncStrategy {
  /// Name of this sync strategy (e.g. 'Issues', 'Meetings')
  String get name;

  /// Returns a list of IDs for items waiting to be synced.
  Future<List<String>> getPendingIds();

  /// Attempts to upload a specific item to Supabase by its ID.
  Future<void> uploadItem(String id);
}
