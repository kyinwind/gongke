import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gongke/database.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  test('a new database uses schema v2 defaults', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final bookId = await database
        .into(database.tipBook)
        .insert(TipBookCompanion.insert(name: '测试书', image: ''));
    await database
        .into(database.tipRecord)
        .insert(TipRecordCompanion.insert(content: '测试记录', bookId: bookId));

    final book = await database.select(database.tipBook).getSingle();
    final record = await database.select(database.tipRecord).getSingle();

    expect(database.schemaVersion, 2);
    expect(book.sourceType, 'userCreated');
    expect(book.updatedDateTime, isNotNull);
    expect(record.comments, '');
    expect(record.sortOrder, 0);
  });

  test('v1 upgrade preserves data and backfills stable fields', () async {
    final sqlite = sqlite3.openInMemory();
    sqlite.execute('''
      CREATE TABLE tip_book (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        create_date_time INTEGER NOT NULL,
        favorite_date_time INTEGER NULL,
        remarks TEXT NULL,
        bk1 TEXT NULL,
        bk2 TEXT NULL,
        name TEXT NOT NULL,
        image TEXT NOT NULL
      );
      CREATE TABLE tip_record (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        create_date_time INTEGER NOT NULL,
        remarks TEXT NULL,
        bk1 TEXT NULL,
        bk2 TEXT NULL,
        content TEXT NOT NULL,
        book_id INTEGER NOT NULL
      );
      INSERT INTO tip_book
        (id, create_date_time, name, image)
        VALUES (7, 1700000000, '旧书', 'old.png');
      INSERT INTO tip_record
        (id, create_date_time, content, book_id)
        VALUES (11, 1700000001, '旧记录一', 7),
               (12, 1700000002, '旧记录二', 7);
      PRAGMA user_version = 1;
    ''');

    final database = AppDatabase(NativeDatabase.opened(sqlite));
    addTearDown(database.close);

    final books = await database.select(database.tipBook).get();
    final records = await (database.select(
      database.tipRecord,
    )..orderBy([(row) => OrderingTerm.asc(row.id)])).get();

    expect(books, hasLength(1));
    expect(books.single.name, '旧书');
    expect(books.single.updatedDateTime, books.single.createDateTime);
    expect(records.map((row) => row.content), ['旧记录一', '旧记录二']);
    expect(records.map((row) => row.jsonId), ['legacy-7-11', 'legacy-7-12']);
    expect(records.map((row) => row.sortOrder), [11, 12]);

    await expectLater(
      database.customStatement(
        '''
        INSERT INTO tip_record
          (create_date_time, content, book_id, json_id, comments, sort_order)
        VALUES (?, ?, ?, ?, ?, ?)
        ''',
        [1700000003, '重复', 7, 'legacy-7-11', '', 13],
      ),
      throwsA(anything),
    );
  });
}
