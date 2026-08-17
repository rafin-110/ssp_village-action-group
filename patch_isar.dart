import 'dart:io';

void main() {
  final dir = Directory('lib');
  final files = dir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.g.dart'))
      .toList();

  for (var file in files) {
    var content = file.readAsStringSync();
    var modified = false;

    // Isar 3 generates large integers for `id: XXXXX` and `propertyId: XXXXX`
    // We will truncate any integer > 15 digits to 15 digits so it fits in JS.
    content = content.replaceAllMapped(RegExp(r'([:-]\s*)(-?\d{16,})'), (match) {
      modified = true;
      final prefix = match.group(1)!;
      final numStr = match.group(2)!;
      
      // Keep only first 15 chars (including minus sign if negative)
      final truncated = numStr.substring(0, 15);
      return '$prefix$truncated';
    });

    if (modified) {
      file.writeAsStringSync(content);
      print('Patched ${file.path}');
    }
  }
}
