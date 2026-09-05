import 'package:isar/isar.dart';

extension IsarWebStub on Isar {
  dynamic get cachedUserModels => throw UnsupportedError('Isar not on web');
  dynamic get issueModels => throw UnsupportedError('Isar not on web');
  dynamic get issueCategoryModels => throw UnsupportedError('Isar not on web');
  dynamic get issueSubcategoryModels => throw UnsupportedError('Isar not on web');
  dynamic get progressUpdateModels => throw UnsupportedError('Isar not on web');
  dynamic get meetingModels => throw UnsupportedError('Isar not on web');
  dynamic get villageModels => throw UnsupportedError('Isar not on web');
}
