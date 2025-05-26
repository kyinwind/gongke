import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

class JingShu extends Table
    with AutoIncrementingPrimaryKey, CreateDateTimeColumn, RemarksColumn {
  TextColumn get name => text()();
  TextColumn get type => text()();
  TextColumn get image => text()();
  TextColumn get fileUrl => text()();
  TextColumn get fileType => text()();
  DateTimeColumn get favoriteDateTime => dateTime().nullable()();
  BoolColumn get muyu => boolean().withDefault(const Constant(false))();
  BoolColumn get bkMusic => boolean().withDefault(const Constant(false))();
  TextColumn get bkMusicname => text().nullable()();
  TextColumn get muyuName => text().nullable()();
  TextColumn get muyuImage => text().nullable()();
  TextColumn get muyuType => text().nullable()();
  IntColumn get muyuCount => integer().nullable()();
  RealColumn get muyuInterval => real().nullable()();
  RealColumn get muyuDuration => real().nullable()();
}

class TipBook extends Table
    with AutoIncrementingPrimaryKey, CreateDateTimeColumn, RemarksColumn {
  TextColumn get name => text()();
  TextColumn get image => text()();
  DateTimeColumn get favoriteDateTime => dateTime().nullable()();
}

class TipRecord extends Table
    with AutoIncrementingPrimaryKey, CreateDateTimeColumn, RemarksColumn {
  TextColumn get content => text()();
  IntColumn get bookId => integer()();
}

mixin AutoIncrementingPrimaryKey on Table {
  IntColumn get id => integer().autoIncrement()();
}

mixin CreateDateTimeColumn on Table {
  DateTimeColumn get createDateTime =>
      dateTime().withDefault(currentDateAndTime)();
}

mixin RemarksColumn on Table {
  TextColumn get remarks => text()();
}

@DriftDatabase(tables: [JingShu, TipBook, TipRecord])
class AppDatabase extends _$AppDatabase {
  // After generating code, this class needs to define a `schemaVersion` getter
  // and a constructor telling drift where the database should be stored.
  // These are described in the getting started guide: https://drift.simonbinder.eu/setup/
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'my_database',
      native: const DriftNativeOptions(
        // By default, `driftDatabase` from `package:drift_flutter` stores the
        // database files in `getApplicationDocumentsDirectory()`.
        databaseDirectory: getApplicationSupportDirectory,
      ),
      // If you need web support, see https://drift.simonbinder.eu/platforms/web/
    );
  }
}
