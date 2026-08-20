import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'model/tables.dart';
part 'database.g.dart';

@DriftDatabase(
  tables: [
    FaYuan,
    GongKeItemsOneDay,
    GongKeItem,
    JingShu,
    TipBook,
    TipRecord,
    BaiChan,
  ],
)
class AppDatabase extends _$AppDatabase {
  // After generating code, this class needs to define a `schemaVersion` getter
  // and a constructor telling drift where the database should be stored.
  // These are described in the getting started guide: https://drift.simonbinder.eu/setup/
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await transaction(() async {
          await m.addColumn(tipBook, tipBook.sourceId);
          await m.addColumn(tipBook, tipBook.version);
          await m.addColumn(tipBook, tipBook.sourceType);
          await m.addColumn(tipBook, tipBook.productId);

          // SQLite cannot add a column with CURRENT_TIMESTAMP as its
          // default. Add a constant-backed column and preserve the old
          // creation date before Drift starts using the v2 definition.
          await customStatement(
            'ALTER TABLE tip_book ADD COLUMN '
            'updated_date_time INTEGER NOT NULL DEFAULT 0',
          );
          await customStatement(
            'UPDATE tip_book SET updated_date_time = create_date_time '
            'WHERE updated_date_time = 0',
          );

          await m.addColumn(tipRecord, tipRecord.jsonId);
          await m.addColumn(tipRecord, tipRecord.favoriteDateTime);
          await m.addColumn(tipRecord, tipRecord.completedDateTime);
          await m.addColumn(tipRecord, tipRecord.comments);
          await m.addColumn(tipRecord, tipRecord.tag);
          await m.addColumn(tipRecord, tipRecord.sortOrder);

          // Every legacy row gets a deterministic identifier. Including
          // both the book and row id keeps it stable and collision-free.
          await customStatement(
            "UPDATE tip_record SET json_id = "
            "'legacy-' || book_id || '-' || id "
            "WHERE json_id IS NULL OR json_id = ''",
          );
          await customStatement(
            'UPDATE tip_record SET sort_order = id '
            'WHERE sort_order = 0',
          );

          // A unique index is the non-destructive SQLite equivalent of
          // the v2 table-level unique key for an existing v1 table.
          await customStatement(
            'CREATE UNIQUE INDEX IF NOT EXISTS '
            'tip_record_book_json_id_unique '
            'ON tip_record (book_id, json_id)',
          );
        });
      }
    },
  );

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
