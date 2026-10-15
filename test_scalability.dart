import 'dart:io';
import 'package:supabase/supabase.dart';
import 'package:uuid/uuid.dart';

void main() async {
  // Using the credentials from your test_insert.dart
  final supabase = SupabaseClient('https://qbshdypvckqppbhxaneh.supabase.co', 'sb_publishable_qLBDLp0WGEEscPcx8NiG0A_MSrser4B');
  
  print('--- SCALABILITY TEST: BATCH UPLOAD vs SINGLE UPLOADS ---');
  
  try {
    // 1. Fetch valid foreign keys to avoid constraints errors
    final leaders = await supabase.from('profiles').select('id').eq('role', 'VAG Leader').limit(1);
    final villages = await supabase.from('villages').select('id').limit(1);
    final categories = await supabase.from('issue_categories').select('id').limit(1);

    if (leaders.isEmpty || villages.isEmpty || categories.isEmpty) {
      print('Database is missing required setup data (leaders, villages, or categories) for the test.');
      exit(1);
    }
    
    final leaderId = leaders[0]['id'];
    final villageId = villages[0]['id'];
    final categoryId = categories[0]['id'];

    final int testCount = 50; // We'll test with 50 issues
    
    // Generate 50 dummy issues
    final List<Map<String, dynamic>> dummyIssues = List.generate(testCount, (index) {
      return {
        'id': Uuid().v4(),
        'title': 'Scalability Test Issue #$index',
        'description': 'Testing load and batch processing.',
        'status': 'reported',
        'leader_id': leaderId,
        'village_id': villageId,
        'category_id': categoryId,
        'current_progress': 0,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String()
      };
    });

    // TEST A: Sequential Inserts (How it used to work)
    print('\nStarting Test A: Sequential Inserts ($testCount requests)...');
    final stopwatchSequential = Stopwatch()..start();
    for (var issue in dummyIssues) {
       await supabase.from('issues').upsert(issue);
    }
    stopwatchSequential.stop();
    print('✅ Sequential inserts completed in: ${stopwatchSequential.elapsedMilliseconds} ms');

    // Generate 50 MORE dummy issues for Batch testing
    final List<Map<String, dynamic>> batchIssues = List.generate(testCount, (index) {
      return {
        'id': Uuid().v4(),
        'title': 'Scalability Batch Issue #$index',
        'description': 'Testing load and batch processing.',
        'status': 'reported',
        'leader_id': leaderId,
        'village_id': villageId,
        'category_id': categoryId,
        'current_progress': 0,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String()
      };
    });

    // TEST B: Batch Inserts (Our new scalable design)
    print('\nStarting Test B: Batch Inserts (1 request with $testCount items)...');
    final stopwatchBatch = Stopwatch()..start();
    await supabase.from('issues').upsert(batchIssues);
    stopwatchBatch.stop();
    print('✅ Batch insert completed in: ${stopwatchBatch.elapsedMilliseconds} ms');

    // Compare
    print('\n--- RESULTS ---');
    print('Sequential time: ${stopwatchSequential.elapsedMilliseconds} ms');
    print('Batch time:      ${stopwatchBatch.elapsedMilliseconds} ms');
    final speedup = (stopwatchSequential.elapsedMilliseconds / stopwatchBatch.elapsedMilliseconds).toStringAsFixed(1);
    print('Batching is $speedup' 'x faster and uses $testCount times fewer server connections!');

    // Cleanup
    print('\nCleaning up test data...');
    final allIds = [...dummyIssues.map((e) => e['id']), ...batchIssues.map((e) => e['id'])];
    await supabase.from('issues').delete().inFilter('id', allIds);
    print('Cleanup complete.');
    exit(0);

  } catch (e) {
    print('Test Failed: ' + e.toString());
    exit(1);
  }
}
