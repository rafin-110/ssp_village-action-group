/// Abstract base class for all sync strategies.
abstract class SyncStrategy {
  /// Name of this sync strategy (e.g. 'Issues', 'Meetings')
  String get name;

  /// Returns a list of IDs for items waiting to be synced.
  Future<List<String>> getPendingIds();

  /// Attempts to upload a specific item to Supabase by its ID.
  Future<void> uploadItem(String id);

  /// Attempts to upload a batch of items to Supabase by their IDs.
  Future<void> uploadBatch(List<String> ids);

  /// Marks an item as actively syncing.
  Future<void> markSyncing(String id);

  /// Marks an item as successfully synced.
  Future<void> markSynced(String id);

  /// Marks an item sync as failed (to be retried later).
  Future<void> markFailed(String id);
}
