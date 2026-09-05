import 'dart:io';

void main() {
  var models = [
    'lib/core/auth/cached_user_model.dart',
    'lib/features/issues/data/models/issue_model.dart',
    'lib/features/issues/data/models/issue_category_model.dart',
    'lib/features/issues/data/models/progress_update_model.dart',
    'lib/features/meetings/data/models/meeting_model.dart',
    'lib/features/villages/data/models/village_model.dart',
  ];

  for (var path in models) {
    if (!File(path).existsSync()) continue;
    var content = File(path).readAsStringSync();
    if (content.contains('export ')) continue; // Already processed
    
    // Create native
    File(path.replaceAll('.dart', '_native.dart')).writeAsStringSync(content);
    
    // Create web
    var webContent = content
        .replaceAll(RegExp(r"part '.*?\.g\.dart';"), "")
        .replaceAll('@collection', '')
        .replaceAll('@embedded', '')
        .replaceAll(RegExp(r"@Index\(.*?\)"), "")
        .replaceAll('@Index()', '')
        .replaceAll(RegExp(r"@Name\(.*?\)"), "")
        .replaceAll(RegExp(r"@Ignore\(\)"), "")
        .replaceAll('@enumerated', '')
        .replaceAll(RegExp(r"Id get isarId.*?;"), "")
        .replaceAll(RegExp(r"Id isarId.*?;"), "")
        .replaceAll('import \'package:isar/isar.dart\';', '');
    
    File(path.replaceAll('.dart', '_web.dart')).writeAsStringSync(webContent);
    
    // Create export
    var basename = path.split('/').last.replaceAll('.dart', '');
    File(path).writeAsStringSync("export '${basename}_web.dart' if (dart.library.io) '${basename}_native.dart';");
  }
}
