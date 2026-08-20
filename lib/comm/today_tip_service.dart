import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database.dart';

enum TodayTipMode { sequential, random }

class TodayTipSelection {
  const TodayTipSelection({required this.book, required this.record});

  final TipBookData book;
  final TipRecordData record;
}

class TodayTipSettings {
  static const _modeKey = 'gongke.todayTip.mode';
  static const _startDateKey = 'gongke.todayTip.startDate';

  static Future<TodayTipMode> loadMode() async {
    final stored = (await SharedPreferences.getInstance()).getString(_modeKey);
    return stored == TodayTipMode.random.name
        ? TodayTipMode.random
        : TodayTipMode.sequential;
  }

  static Future<void> saveMode(TodayTipMode mode) async {
    await (await SharedPreferences.getInstance()).setString(
      _modeKey,
      mode.name,
    );
  }

  static Future<DateTime> loadStartDate({DateTime? fallback}) async {
    final preferences = await SharedPreferences.getInstance();
    final parsed = DateTime.tryParse(
      preferences.getString(_startDateKey) ?? '',
    );
    if (parsed != null) return _localDay(parsed);
    final startDate = _localDay(fallback ?? DateTime.now());
    await preferences.setString(_startDateKey, startDate.toIso8601String());
    return startDate;
  }

  static DateTime _localDay(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}

class TodayTipService {
  const TodayTipService(this.db);

  final AppDatabase db;

  Future<List<TodayTipSelection>> loadCandidates() async {
    final books =
        await (db.select(db.tipBook)..orderBy([
              (row) => OrderingTerm.desc(row.favoriteDateTime),
              (row) => OrderingTerm.desc(row.createDateTime),
              (row) => OrderingTerm.asc(row.id),
            ]))
            .get();
    final candidates = <TodayTipSelection>[];
    for (final book in books) {
      final records =
          await (db.select(db.tipRecord)
                ..where((row) => row.bookId.equals(book.id))
                ..orderBy([
                  (row) => OrderingTerm.asc(row.sortOrder),
                  (row) => OrderingTerm.asc(row.id),
                ]))
              .get();
      candidates.addAll(
        records.map((record) => TodayTipSelection(book: book, record: record)),
      );
    }
    return candidates;
  }

  Future<TodayTipSelection?> select({
    required DateTime now,
    required DateTime startDate,
    required TodayTipMode mode,
    String seedScope = 'app',
    int refreshSequence = 0,
    int? previousRecordId,
  }) async {
    final candidates = await loadCandidates();
    if (candidates.isEmpty) return null;
    var index = selectIndex(
      length: candidates.length,
      now: now,
      startDate: startDate,
      mode: mode,
      seedScope: seedScope,
      refreshSequence: refreshSequence,
    );
    if (refreshSequence > 0 &&
        candidates.length > 1 &&
        candidates[index].record.id == previousRecordId) {
      index = (index + 1) % candidates.length;
    }
    return candidates[index];
  }

  static int selectIndex({
    required int length,
    required DateTime now,
    required DateTime startDate,
    required TodayTipMode mode,
    String seedScope = 'app',
    int refreshSequence = 0,
  }) {
    if (length <= 0) throw ArgumentError.value(length, 'length', '必须大于 0');
    final localDay = DateTime(now.year, now.month, now.day);
    final firstDay = DateTime(startDate.year, startDate.month, startDate.day);
    if (mode == TodayTipMode.sequential && refreshSequence == 0) {
      return _positiveModulo(localDay.difference(firstDay).inDays, length);
    }
    return _positiveModulo(
      _stableHash('${localDay.toIso8601String()}|$seedScope|$refreshSequence'),
      length,
    );
  }

  static int _positiveModulo(int value, int divisor) =>
      (value % divisor + divisor) % divisor;

  static int _stableHash(String value) {
    var hash = 0x811c9dc5;
    for (final codeUnit in value.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 0x01000193) & 0x7fffffff;
    }
    return hash;
  }
}
