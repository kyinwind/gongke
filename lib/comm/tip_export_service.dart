import 'package:drift/drift.dart';

import '../database.dart';
import '../model/tip_file.dart';

class TipExportService {
  const TipExportService({this.codec = const TipFileCodec()});

  final TipFileCodec codec;

  Future<Uint8List> exportBook(AppDatabase db, int bookId) async {
    final book = await (db.select(
      db.tipBook,
    )..where((row) => row.id.equals(bookId))).getSingleOrNull();
    if (book == null) throw StateError('找不到要导出的开示录');
    final records =
        await (db.select(db.tipRecord)
              ..where((row) => row.bookId.equals(bookId))
              ..orderBy([
                (row) => OrderingTerm.asc(row.sortOrder),
                (row) => OrderingTerm.asc(row.id),
              ]))
            .get();
    return codec.encodeBytes(
      TipBookFileDto(
        book: TipBookDto(
          sourceId: book.sourceId ?? 'local-book-${book.id}',
          name: book.name,
          remarks: book.remarks ?? '',
          image: book.image,
          version: book.version ?? '1',
          sourceType: book.sourceType,
          productId: book.productId,
          records: records
              .map(
                (record) => TipRecordDto(
                  jsonId: record.jsonId ?? 'local-record-${record.id}',
                  content: record.content,
                  favoriteDateTime: record.favoriteDateTime,
                  completedDateTime: record.completedDateTime,
                  comments: record.comments,
                  tag: record.tag,
                  sortOrder: record.sortOrder,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
