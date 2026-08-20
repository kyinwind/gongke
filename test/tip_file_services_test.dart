import 'dart:convert';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:gongke/comm/tip_export_service.dart';
import 'package:gongke/comm/tip_import_service.dart';
import 'package:gongke/database.dart';
import 'package:gongke/model/tip_file.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TipFileCodec', () {
    const codec = TipFileCodec();

    test('accepts legacy files and all supported date formats', () {
      final decoded = codec.decode('''
        {
          "quotation": {
            "id": 8,
            "name": "兼容日期",
            "image": "",
            "records": [
              {"content":"Swift", "completedDate": 0},
              {"content":"秒", "completedDate": 1700000000},
              {"content":"毫秒", "completedDate": 1700000000000},
              {"content":"ISO", "completedDate": "2026-08-20T10:00:00Z"}
            ]
          }
        }
      ''');

      expect(decoded.schemaVersion, 1);
      expect(decoded.book.sourceId, '8');
      expect(decoded.book.records[0].completedDateTime, DateTime.utc(2001));
      expect(
        decoded.book.records[1].completedDateTime,
        DateTime.fromMillisecondsSinceEpoch(1700000000000, isUtc: true),
      );
      expect(
        decoded.book.records[2].completedDateTime,
        DateTime.fromMillisecondsSinceEpoch(1700000000000, isUtc: true),
      );
      expect(
        decoded.book.records[3].completedDateTime,
        DateTime.utc(2026, 8, 20, 10),
      );
    });

    test('rejects invalid schema, UTF-8, Base64 and size limits', () {
      expect(
        () => codec.decode('{"schemaVersion":3,"quotation":{}}'),
        throwsA(isA<TipFileFormatException>()),
      );
      expect(
        () => codec.decodeBytes(Uint8List.fromList([0xff, 0xfe])),
        throwsA(isA<TipFileFormatException>()),
      );
      expect(
        () => codec.decode(
          '{"quotation":{"name":"坏图片","image":"***","records":[]}}',
        ),
        throwsA(isA<TipFileFormatException>()),
      );
      const tinyCodec = TipFileCodec(maxFileBytes: 4);
      expect(
        () => tinyCodec.decodeBytes(Uint8List.fromList(utf8.encode('12345'))),
        throwsA(isA<TipFileFormatException>()),
      );
      const tinyImageCodec = TipFileCodec(maxDecodedImageBytes: 3);
      expect(
        () => tinyImageCodec.decode(
          '{"quotation":{"name":"大图片","image":"iVBORw==","records":[]}}',
        ),
        throwsA(isA<TipFileFormatException>()),
      );
    });

    test(
      'the optional Buddhist maxims sample contains seven records',
      () async {
        final source = await rootBundle.loadString(
          'assets/tips/fojiaogeyan.json',
        );
        final decoded = codec.decode(source);
        expect(decoded.book.records, hasLength(7));
        expect(decoded.book.sourceId, 'builtin-buddhist-maxims-7');
      },
    );
  });

  group('tip import and export', () {
    late AppDatabase db;
    late TipImportService importer;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      importer = TipImportService(db);
    });

    tearDown(() => db.close());

    test('round trip preserves ids, order and personal state', () async {
      final source = _file(
        name: '往返测试',
        sourceId: 'book-round-trip',
        records: [
          const TipRecordDto(
            jsonId: 'r2',
            content: '第二条',
            comments: '批注',
            sortOrder: 2,
          ),
          TipRecordDto(
            jsonId: 'r1',
            content: '第一条',
            favoriteDateTime: DateTime.utc(2026, 8, 20),
            completedDateTime: DateTime.utc(2026, 8, 19),
            sortOrder: 1,
          ),
        ],
      );
      expect(
        await importer.importBytes(const TipFileCodec().encodeBytes(source)),
        isTrue,
      );
      final book = await db.select(db.tipBook).getSingle();
      final exported = await const TipExportService().exportBook(db, book.id);
      await db.close();

      final secondDb = AppDatabase(NativeDatabase.memory());
      db = secondDb;
      expect(await TipImportService(secondDb).importBytes(exported), isTrue);
      final records = await (secondDb.select(
        secondDb.tipRecord,
      )..orderBy([(row) => OrderingTerm.asc(row.sortOrder)])).get();
      expect(records.map((row) => row.jsonId), ['r1', 'r2']);
      expect(records.first.favoriteDateTime, isNotNull);
      expect(
        records.first.completedDateTime?.toUtc(),
        DateTime.utc(2026, 8, 19),
      );
      expect(records.last.comments, '批注');
    });

    test(
      'update preserves local favorite completion comments and order',
      () async {
        final initial = _file(
          name: '原书名',
          sourceId: 'same-book',
          records: const [TipRecordDto(jsonId: 'same-record', content: '旧正文')],
        );
        await importer.importBytes(const TipFileCodec().encodeBytes(initial));
        final record = await db.select(db.tipRecord).getSingle();
        final favorite = DateTime.utc(2026, 8, 18);
        final completed = DateTime.utc(2026, 8, 19);
        await (db.update(
          db.tipRecord,
        )..where((row) => row.id.equals(record.id))).write(
          TipRecordCompanion(
            favoriteDateTime: Value(favorite),
            completedDateTime: Value(completed),
            comments: const Value('本机评论'),
            sortOrder: const Value(9),
          ),
        );

        final update = _file(
          name: '新书名',
          sourceId: 'same-book',
          records: [
            TipRecordDto(
              jsonId: 'same-record',
              content: '新正文',
              comments: '导入评论',
              favoriteDateTime: DateTime.utc(2020),
              sortOrder: 1,
            ),
          ],
        );
        await importer.importBytes(
          const TipFileCodec().encodeBytes(update),
          strategy: TipImportConflictStrategy.updateExisting,
        );

        final updatedBook = await db.select(db.tipBook).getSingle();
        final updated = await db.select(db.tipRecord).getSingle();
        expect(updatedBook.name, '新书名');
        expect(updated.content, '新正文');
        expect(updated.favoriteDateTime?.toUtc(), favorite);
        expect(updated.completedDateTime?.toUtc(), completed);
        expect(updated.comments, '本机评论');
        expect(updated.sortOrder, 9);
      },
    );

    test(
      'skip, save-as-new, preview, batch isolation and file limit work',
      () async {
        final validBytes = const TipFileCodec().encodeBytes(
          _file(
            name: '冲突书',
            sourceId: 'conflict-book',
            records: const [TipRecordDto(jsonId: 'r1', content: '正文')],
          ),
        );
        await importer.importBytes(validBytes);
        expect(await importer.importBytes(validBytes), isFalse);
        expect(
          await importer.importBytes(
            validBytes,
            strategy: TipImportConflictStrategy.saveAsNew,
          ),
          isTrue,
        );
        expect(await db.select(db.tipBook).get(), hasLength(2));

        final previews = await importer.preview([
          TipImportSource(fileName: 'valid.json', bytes: validBytes),
          TipImportSource(
            fileName: 'bad.json',
            bytes: Uint8List.fromList([0xff]),
          ),
        ]);
        expect(previews.first.conflictCount, 2);
        expect(previews.last.error, isNotNull);

        final result = await importer.importBatch([
          TipImportSource(
            fileName: 'new.json',
            bytes: const TipFileCodec().encodeBytes(
              _file(name: '新书', sourceId: 'new-book', records: const []),
            ),
          ),
          TipImportSource(
            fileName: 'bad.json',
            bytes: Uint8List.fromList([0xff]),
          ),
        ]);
        expect(result.imported, 1);
        expect(result.failed, 1);
        expect(await db.select(db.tipBook).get(), hasLength(3));

        final tooMany = List.generate(
          16,
          (index) =>
              TipImportSource(fileName: '$index.json', bytes: validBytes),
        );
        expect(() => importer.preview(tooMany), throwsArgumentError);
      },
    );
  });
}

TipBookFileDto _file({
  required String name,
  required String sourceId,
  required List<TipRecordDto> records,
}) => TipBookFileDto(
  book: TipBookDto(sourceId: sourceId, name: name, records: records),
);
