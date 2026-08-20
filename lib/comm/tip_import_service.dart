import 'package:drift/drift.dart';

import '../database.dart';
import '../model/tip_file.dart';

enum TipImportConflictStrategy { skip, updateExisting, saveAsNew }

enum TipImportStatus { imported, skipped, failed }

class TipImportSource {
  const TipImportSource({required this.fileName, required this.bytes});

  final String fileName;
  final Uint8List bytes;
}

class TipImportPreview {
  const TipImportPreview({
    required this.fileName,
    this.bookName,
    this.recordCount = 0,
    this.conflictCount = 0,
    this.error,
  });

  final String fileName;
  final String? bookName;
  final int recordCount;
  final int conflictCount;
  final String? error;
}

class TipImportItemResult {
  const TipImportItemResult({
    required this.fileName,
    required this.status,
    required this.message,
  });

  final String fileName;
  final TipImportStatus status;
  final String message;
}

class TipBatchImportResult {
  const TipBatchImportResult(this.items);

  final List<TipImportItemResult> items;
  int get imported =>
      items.where((item) => item.status == TipImportStatus.imported).length;
  int get skipped =>
      items.where((item) => item.status == TipImportStatus.skipped).length;
  int get failed =>
      items.where((item) => item.status == TipImportStatus.failed).length;
}

class TipImportService {
  const TipImportService(this.db, {this.codec = const TipFileCodec()});

  static const maxFilesPerBatch = 15;

  final AppDatabase db;
  final TipFileCodec codec;

  Future<List<TipImportPreview>> preview(List<TipImportSource> sources) async {
    _checkBatchSize(sources);
    final result = <TipImportPreview>[];
    for (final source in sources) {
      try {
        final file = codec.decodeBytes(source.bytes);
        final existing = await _findExistingBook(file.book);
        var conflictCount = existing == null ? 0 : 1;
        if (existing != null) {
          final ids =
              (await (db.select(
                    db.tipRecord,
                  )..where((row) => row.bookId.equals(existing.id))).get())
                  .map((row) => row.jsonId)
                  .whereType<String>()
                  .toSet();
          conflictCount += file.book.records
              .where((row) => ids.contains(row.jsonId))
              .length;
        }
        result.add(
          TipImportPreview(
            fileName: source.fileName,
            bookName: file.book.name,
            recordCount: file.book.records.length,
            conflictCount: conflictCount,
          ),
        );
      } catch (error) {
        result.add(
          TipImportPreview(fileName: source.fileName, error: error.toString()),
        );
      }
    }
    return result;
  }

  Future<TipBatchImportResult> importBatch(
    List<TipImportSource> sources, {
    TipImportConflictStrategy strategy = TipImportConflictStrategy.skip,
  }) async {
    _checkBatchSize(sources);
    final items = <TipImportItemResult>[];
    for (final source in sources) {
      try {
        final imported = await importBytes(source.bytes, strategy: strategy);
        items.add(
          TipImportItemResult(
            fileName: source.fileName,
            status: imported
                ? TipImportStatus.imported
                : TipImportStatus.skipped,
            message: imported ? '导入成功' : '存在冲突，已按策略跳过',
          ),
        );
      } catch (error) {
        items.add(
          TipImportItemResult(
            fileName: source.fileName,
            status: TipImportStatus.failed,
            message: error.toString(),
          ),
        );
      }
    }
    return TipBatchImportResult(items);
  }

  Future<bool> importBytes(
    Uint8List bytes, {
    TipImportConflictStrategy strategy = TipImportConflictStrategy.skip,
  }) async {
    final file = codec.decodeBytes(bytes);
    return db.transaction(() async {
      final existing = await _findExistingBook(file.book);
      if (existing == null) {
        await _insertBook(file.book);
        return true;
      }
      switch (strategy) {
        case TipImportConflictStrategy.skip:
          return false;
        case TipImportConflictStrategy.updateExisting:
          await _updateBook(existing, file.book);
          return true;
        case TipImportConflictStrategy.saveAsNew:
          await _insertBook(_asCopy(file.book));
          return true;
      }
    });
  }

  void _checkBatchSize(List<TipImportSource> sources) {
    if (sources.length > maxFilesPerBatch) {
      throw ArgumentError('单次最多选择 $maxFilesPerBatch 个文件');
    }
  }

  Future<TipBookData?> _findExistingBook(TipBookDto incoming) async {
    final books = await db.select(db.tipBook).get();
    String? normalized(String? value) {
      final result = value?.trim().toLowerCase();
      return result == null || result.isEmpty ? null : result;
    }

    final sourceId = normalized(incoming.sourceId);
    final productId = normalized(incoming.productId);
    for (final book in books) {
      if (sourceId != null && normalized(book.sourceId) == sourceId) {
        return book;
      }
      if (productId != null && normalized(book.productId) == productId) {
        return book;
      }
    }
    return null;
  }

  Future<int> _insertBook(TipBookDto book) async {
    final bookId = await db
        .into(db.tipBook)
        .insert(
          TipBookCompanion.insert(
            name: book.name,
            image: book.image,
            remarks: Value(book.remarks),
            sourceId: Value(book.sourceId),
            version: Value(book.version),
            sourceType: Value(book.sourceType),
            productId: Value(book.productId),
            updatedDateTime: Value(DateTime.now()),
          ),
        );
    for (final record in book.records) {
      await db.into(db.tipRecord).insert(_recordCompanion(bookId, record));
    }
    return bookId;
  }

  Future<void> _updateBook(TipBookData existing, TipBookDto incoming) async {
    await (db.update(
      db.tipBook,
    )..where((row) => row.id.equals(existing.id))).write(
      TipBookCompanion(
        name: Value(incoming.name),
        image: Value(incoming.image),
        remarks: Value(incoming.remarks),
        sourceId: Value(incoming.sourceId ?? existing.sourceId),
        version: Value(incoming.version),
        sourceType: Value(incoming.sourceType),
        productId: Value(incoming.productId ?? existing.productId),
        updatedDateTime: Value(DateTime.now()),
      ),
    );

    final localRecords = await (db.select(
      db.tipRecord,
    )..where((row) => row.bookId.equals(existing.id))).get();
    final byJsonId = {for (final row in localRecords) row.jsonId: row};
    for (final incomingRecord in incoming.records) {
      final local = byJsonId[incomingRecord.jsonId];
      if (local == null) {
        await db
            .into(db.tipRecord)
            .insert(_recordCompanion(existing.id, incomingRecord));
      } else {
        // Imported content changes; personal states deliberately remain local.
        await (db.update(
          db.tipRecord,
        )..where((row) => row.id.equals(local.id))).write(
          TipRecordCompanion(
            content: Value(incomingRecord.content),
            tag: Value(incomingRecord.tag),
          ),
        );
      }
    }
  }

  TipRecordCompanion _recordCompanion(int bookId, TipRecordDto record) =>
      TipRecordCompanion.insert(
        content: record.content,
        bookId: bookId,
        jsonId: Value(record.jsonId),
        favoriteDateTime: Value(record.favoriteDateTime),
        completedDateTime: Value(record.completedDateTime),
        comments: Value(record.comments),
        tag: Value(record.tag),
        sortOrder: Value(record.sortOrder),
      );

  TipBookDto _asCopy(TipBookDto book) {
    final suffix = DateTime.now().microsecondsSinceEpoch;
    return TipBookDto(
      sourceId: '${book.sourceId ?? 'imported'}-copy-$suffix',
      name: '${book.name}（副本）',
      remarks: book.remarks,
      image: book.image,
      version: book.version,
      sourceType: book.sourceType,
      productId: null,
      records: book.records,
    );
  }
}
