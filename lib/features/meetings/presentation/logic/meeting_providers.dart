import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/data_sources/meeting_local_data_source.dart';

import '../../domain/entities/meeting.dart';

final meetingLocalDataSourceProvider = Provider<MeetingLocalDataSource>((ref) {
  return MeetingLocalDataSource();
});

/// A future provider that fetches all meetings and maps them to domain entities
final meetingsProvider = FutureProvider<List<Meeting>>((ref) async {
  final dataSource = ref.watch(meetingLocalDataSourceProvider);
  final models = await dataSource.getAllMeetings();
  return models.map((e) => e.toDomain()).toList();
});

/// A future provider that fetches a specific meeting by ID
final meetingByIdProvider = FutureProvider.family<Meeting?, String>((ref, id) async {
  final dataSource = ref.watch(meetingLocalDataSourceProvider);
  final model = await dataSource.getMeetingById(id);
  return model?.toDomain();
});

/// Provider for UI to track upcoming meetings
final upcomingMeetingsProvider = FutureProvider<List<Meeting>>((ref) async {
  final meetings = await ref.watch(meetingsProvider.future);
  final now = DateTime.now();
  return meetings.where((m) => m.date.isAfter(now) || m.status == MeetingStatus.scheduled).toList()
    ..sort((a, b) => a.date.compareTo(b.date));
});
