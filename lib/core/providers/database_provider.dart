import 'package:path_provider/path_provider.dart';
import 'package:powersync/powersync.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:enki_finance/shared/data/schema.dart';

part 'database_provider.g.dart';

@riverpod
Future<PowerSyncDatabase> database(Ref ref) async {
  final db = PowerSyncDatabase(
    schema: schema,
    path: '${(await getApplicationDocumentsDirectory()).path}/powersync.db',
  );
  await db.initialize();
  return db;
}
