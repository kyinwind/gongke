import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:gongke/comm/muyu_rhythm_store.dart';
import 'package:gongke/comm/nianfo_muyu_session_controller.dart';
import 'package:gongke/model/muyu_rhythm_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('built-in ten-recitation sequences are exact and repeat safely', () {
    expect(
      MuyuRhythmTemplateCatalog.masterYinguang.sequence.map(
        (variant) => variant.shortName,
      ),
      ['B', 'B', 'B', 'C', 'C', 'C', 'A', 'A', 'A', 'A'],
    );
    expect(
      MuyuRhythmTemplateCatalog.antiDrowsiness.sequence.map(
        (variant) => variant.shortName,
      ),
      ['B', 'C', 'B', 'C', 'B', 'C', 'A', 'A', 'A', 'A'],
    );
    expect(
      MuyuRhythmTemplateCatalog.masterYinguang.variantForZeroBasedStrikeIndex(
        10,
      ),
      MuyuSoundVariant.b,
    );
    expect(
      MuyuRhythmTemplateCatalog.masterYinguang.variantForZeroBasedStrikeIndex(
        -1,
      ),
      MuyuSoundVariant.regular,
    );
  });

  test('custom pattern, selection, usage and replacement persist', () async {
    final store = MuyuRhythmPatternStore();
    await store.load();
    expect(store.selectablePatterns, hasLength(3));
    expect(
      await store.createCustom(
        name: '我的节奏',
        sequence: MuyuRhythmTemplateCatalog.masterYinguang.sequence,
      ),
      isNull,
    );
    final custom = store.selectablePatterns.last;
    await store.select(
      patternID: custom.id,
      gongKeType: 'nianshenghao',
      gongKeName: '阿弥陀佛',
    );
    expect(store.usageCount(custom.id), 1);

    final reloaded = MuyuRhythmPatternStore();
    await reloaded.load();
    expect(
      reloaded.selectedPatternId(
        gongKeType: 'nianshenghao',
        gongKeName: '阿弥陀佛',
      ),
      custom.id,
    );
    expect(
      await reloaded.deleteCustom(
        id: custom.id,
        replacementID: MuyuRhythmTemplateCatalog.masterYinguang.id,
      ),
      isNull,
    );
    expect(reloaded.usageCount(custom.id), 0);
    expect(
      reloaded.selectedPatternId(
        gongKeType: 'nianshenghao',
        gongKeName: '阿弥陀佛',
      ),
      MuyuRhythmTemplateCatalog.masterYinguang.id,
    );
  });

  test(
    'built-in overrides can be restored and invalid data is rejected',
    () async {
      final store = MuyuRhythmPatternStore();
      await store.load();
      expect(
        await store.updateBuiltIn(
          id: MuyuRhythmTemplateCatalog.masterYinguang.id,
          sequence: MuyuRhythmTemplateCatalog.antiDrowsiness.sequence,
        ),
        isNull,
      );
      expect(
        store
            .patternFor(MuyuRhythmTemplateCatalog.masterYinguang.id)
            .isOverridden,
        isTrue,
      );
      await store.resetBuiltIn(MuyuRhythmTemplateCatalog.masterYinguang.id);
      expect(
        store
            .patternFor(MuyuRhythmTemplateCatalog.masterYinguang.id)
            .isOverridden,
        isFalse,
      );
      expect(
        await store.createCustom(
          name: '',
          sequence: const [MuyuSoundVariant.a],
        ),
        isNotNull,
      );
    },
  );

  test('corrupted or future snapshots fall back without crashing', () async {
    SharedPreferences.setMockInitialValues({
      'gongke.muyuRhythmPreferences': '{broken',
    });
    final corrupted = MuyuRhythmPatternStore();
    await corrupted.load();
    expect(corrupted.selectablePatterns, hasLength(3));

    SharedPreferences.setMockInitialValues({
      'gongke.muyuRhythmPreferences': '{"schemaVersion":99}',
    });
    final future = MuyuRhythmPatternStore();
    await future.load();
    expect(future.selectablePatterns, hasLength(3));
  });

  test('stopping during the leading chime prevents delayed playback', () async {
    final chime = Completer<void>();
    final strikes = <MuyuSoundVariant>[];
    final controller = NianFoMuyuSessionController(
      waitForLeadingChime: () => chime.future,
      playStrike: (variant) async => strikes.add(variant),
      stopStrikes: () async {},
      playCompletionChime: () {},
    );
    final starting = controller.start(
      pattern: MuyuRhythmTemplateCatalog.masterYinguang,
      totalCount: 3,
      interval: const Duration(milliseconds: 1),
    );
    expect(controller.state, NianFoMuyuState.leadingChime);
    controller.pause();
    chime.complete();
    await starting;
    await Future<void>.delayed(const Duration(milliseconds: 5));
    expect(controller.state, NianFoMuyuState.idle);
    expect(strikes, isEmpty);
  });

  test(
    'pause and resume preserve remaining count without duplicate strikes',
    () async {
      final strikes = <MuyuSoundVariant>[];
      var completions = 0;
      final controller = NianFoMuyuSessionController(
        waitForLeadingChime: () async {},
        playStrike: (variant) async => strikes.add(variant),
        stopStrikes: () async {},
        playCompletionChime: () {},
        onCompleted: () => completions++,
      );
      await controller.start(
        pattern: MuyuRhythmTemplateCatalog.masterYinguang,
        totalCount: 3,
        interval: const Duration(milliseconds: 20),
      );
      await Future<void>.delayed(const Duration(milliseconds: 25));
      controller.pause();
      final countAtPause = strikes.length;
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(strikes, hasLength(countAtPause));
      await controller.resume(
        pattern: MuyuRhythmTemplateCatalog.masterYinguang,
        interval: const Duration(milliseconds: 10),
      );
      await Future<void>.delayed(const Duration(milliseconds: 45));
      expect(strikes, hasLength(3));
      expect(controller.playedCount, 3);
      expect(controller.state, NianFoMuyuState.completed);
      expect(completions, 1);
    },
  );

  test(
    'slow strike commands never overlap or advance the count early',
    () async {
      final pendingStrikes = <Completer<void>>[];
      final controller = NianFoMuyuSessionController(
        waitForLeadingChime: () async {},
        playStrike: (_) {
          final pending = Completer<void>();
          pendingStrikes.add(pending);
          return pending.future;
        },
        stopStrikes: () async {},
        playCompletionChime: () {},
      );

      await controller.start(
        pattern: MuyuRhythmTemplateCatalog.masterYinguang,
        totalCount: 3,
        interval: const Duration(milliseconds: 5),
      );
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(pendingStrikes, hasLength(1));
      expect(controller.playedCount, 0);

      pendingStrikes.first.complete();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(pendingStrikes, hasLength(2));
      expect(controller.playedCount, 1);

      controller.pause();
      pendingStrikes.last.complete();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(controller.playedCount, 1);
      expect(controller.state, NianFoMuyuState.idle);
    },
  );

  test(
    'the final strike gets a full interval before completion stops audio',
    () async {
      var stopCount = 0;
      var completionChimeCount = 0;
      final controller = NianFoMuyuSessionController(
        waitForLeadingChime: () async {},
        playStrike: (_) async {},
        stopStrikes: () async => stopCount++,
        playCompletionChime: () => completionChimeCount++,
      );

      await controller.start(
        pattern: MuyuRhythmTemplateCatalog.regular,
        totalCount: 1,
        interval: const Duration(milliseconds: 30),
      );
      await Future<void>.delayed(const Duration(milliseconds: 40));
      expect(controller.playedCount, 1);
      expect(controller.state, NianFoMuyuState.playing);
      expect(stopCount, 0);

      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(controller.state, NianFoMuyuState.completed);
      expect(stopCount, 1);
      expect(completionChimeCount, 1);
    },
  );
}
