import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gongke/comm/today_tip_service.dart';
import 'package:gongke/database.dart';

void main() {
  test(
    'sequential selection is stable, wraps, and handles dates before start',
    () {
      final start = DateTime(2026, 8, 20);
      expect(
        TodayTipService.selectIndex(
          length: 3,
          now: start,
          startDate: start,
          mode: TodayTipMode.sequential,
        ),
        0,
      );
      expect(
        TodayTipService.selectIndex(
          length: 3,
          now: DateTime(2026, 8, 23),
          startDate: start,
          mode: TodayTipMode.sequential,
        ),
        0,
      );
      expect(
        TodayTipService.selectIndex(
          length: 3,
          now: DateTime(2026, 8, 19),
          startDate: start,
          mode: TodayTipMode.sequential,
        ),
        2,
      );
    },
  );

  test('random mode is stable during a day and changes seed across days', () {
    int index(DateTime date) => TodayTipService.selectIndex(
      length: 1000,
      now: date,
      startDate: DateTime(2026),
      mode: TodayTipMode.random,
    );
    expect(index(DateTime(2026, 8, 20, 1)), index(DateTime(2026, 8, 20, 23)));
    expect(index(DateTime(2026, 8, 20)), isNot(index(DateTime(2026, 8, 21))));
  });

  test(
    'empty, one and multiple candidates work; refresh avoids repetition',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final service = TodayTipService(db);
      final now = DateTime(2026, 8, 20);
      expect(
        await service.select(
          now: now,
          startDate: now,
          mode: TodayTipMode.sequential,
        ),
        isNull,
      );
      final bookId = await db
          .into(db.tipBook)
          .insert(TipBookCompanion.insert(name: '书', image: ''));
      await db
          .into(db.tipRecord)
          .insert(
            TipRecordCompanion.insert(
              content: '一',
              bookId: bookId,
              jsonId: const Value('one'),
            ),
          );
      final only = await service.select(
        now: now,
        startDate: now,
        mode: TodayTipMode.sequential,
      );
      expect(only?.record.content, '一');
      await db
          .into(db.tipRecord)
          .insert(
            TipRecordCompanion.insert(
              content: '二',
              bookId: bookId,
              jsonId: const Value('two'),
              sortOrder: const Value(1),
            ),
          );
      final refreshed = await service.select(
        now: now,
        startDate: now,
        mode: TodayTipMode.sequential,
        refreshSequence: 1,
        previousRecordId: only?.record.id,
      );
      expect(refreshed?.record.id, isNot(only?.record.id));
    },
  );

  test('zero length is rejected explicitly', () {
    expect(
      () => TodayTipService.selectIndex(
        length: 0,
        now: DateTime(2026),
        startDate: DateTime(2026),
        mode: TodayTipMode.sequential,
      ),
      throwsArgumentError,
    );
  });

  test(
    'favorite, completion, comments and reordered positions persist',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final bookId = await db
          .into(db.tipBook)
          .insert(TipBookCompanion.insert(name: '状态测试', image: ''));
      final firstId = await db
          .into(db.tipRecord)
          .insert(
            TipRecordCompanion.insert(
              content: '一',
              bookId: bookId,
              jsonId: const Value('state-1'),
            ),
          );
      final secondId = await db
          .into(db.tipRecord)
          .insert(
            TipRecordCompanion.insert(
              content: '二',
              bookId: bookId,
              jsonId: const Value('state-2'),
              sortOrder: const Value(1),
            ),
          );
      final now = DateTime(2026, 8, 20);
      await (db.update(
        db.tipRecord,
      )..where((row) => row.id.equals(firstId))).write(
        TipRecordCompanion(
          favoriteDateTime: Value(now),
          completedDateTime: Value(now),
          comments: const Value('本机评论'),
          sortOrder: const Value(1),
        ),
      );
      await (db.update(db.tipRecord)..where((row) => row.id.equals(secondId)))
          .write(const TipRecordCompanion(sortOrder: Value(0)));
      final records = await (db.select(
        db.tipRecord,
      )..orderBy([(row) => OrderingTerm.asc(row.sortOrder)])).get();
      expect(records.first.id, secondId);
      expect(records.last.favoriteDateTime, isNotNull);
      expect(records.last.completedDateTime, isNotNull);
      expect(records.last.comments, '本机评论');
    },
  );

  test('record states and order survive a database reopen', () async {
    final directory = await Directory.systemTemp.createTemp('gongke-tip-test-');
    addTearDown(() => directory.delete(recursive: true));
    final file = File('${directory.path}${Platform.pathSeparator}tips.sqlite');
    var db = AppDatabase(NativeDatabase(file));
    final bookId = await db
        .into(db.tipBook)
        .insert(TipBookCompanion.insert(name: '重启测试', image: ''));
    await db
        .into(db.tipRecord)
        .insert(
          TipRecordCompanion.insert(
            content: '持久化',
            bookId: bookId,
            jsonId: const Value('reopen-1'),
            favoriteDateTime: Value(DateTime(2026, 8, 20)),
            completedDateTime: Value(DateTime(2026, 8, 20)),
            comments: const Value('重启后仍存在'),
            sortOrder: const Value(4),
          ),
        );
    await db.close();

    db = AppDatabase(NativeDatabase(file));
    final record = await db.select(db.tipRecord).getSingle();
    expect(record.favoriteDateTime, isNotNull);
    expect(record.completedDateTime, isNotNull);
    expect(record.comments, '重启后仍存在');
    expect(record.sortOrder, 4);
    await db.close();
  });
}
