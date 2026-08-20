import '../comm/today_tip_service.dart';
import '../main.dart';

class CurrentRecord {
  CurrentRecord({
    this.content = '暂时无数据',
    this.bookId = 0,
    this.id = 0,
    this.bookName = '',
    this.bookImage = '',
    this.favoriteDateTime,
    this.completedDateTime,
    this.comments = '',
  });

  String content;
  int bookId;
  String bookName;
  String bookImage;
  int id;
  DateTime? favoriteDateTime;
  DateTime? completedDateTime;
  String comments;

  bool get hasData => id > 0;
}

Future<CurrentRecord> getCurrentRecord({
  DateTime? now,
  TodayTipMode? mode,
  int refreshSequence = 0,
  int? previousRecordId,
}) async {
  final currentTime = now ?? DateTime.now();
  final selected = await TodayTipService(globalDB).select(
    now: currentTime,
    startDate: await TodayTipSettings.loadStartDate(fallback: currentTime),
    mode: mode ?? await TodayTipSettings.loadMode(),
    refreshSequence: refreshSequence,
    previousRecordId: previousRecordId,
  );
  if (selected == null) return CurrentRecord();
  return CurrentRecord(
    id: selected.record.id,
    content: selected.record.content,
    bookId: selected.book.id,
    bookName: selected.book.name,
    bookImage: selected.book.image,
    favoriteDateTime: selected.record.favoriteDateTime,
    completedDateTime: selected.record.completedDateTime,
    comments: selected.record.comments,
  );
}
