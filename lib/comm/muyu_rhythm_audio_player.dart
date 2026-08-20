import 'package:audioplayers/audioplayers.dart';

import '../model/muyu_rhythm_pattern.dart';

class MuyuRhythmAudioPlayer {
  MuyuRhythmAudioPlayer._();

  static final MuyuRhythmAudioPlayer _instance = MuyuRhythmAudioPlayer._();
  factory MuyuRhythmAudioPlayer() => _instance;

  final Map<MuyuSoundVariant, Future<AudioPlayer>> _players = {};
  Future<void> _pendingOperation = Future<void>.value();

  Future<AudioPlayer> _playerFor(MuyuSoundVariant variant) =>
      _players.putIfAbsent(variant, () => _createPlayer(variant));

  Future<AudioPlayer> _createPlayer(MuyuSoundVariant variant) async {
    final player = AudioPlayer(playerId: 'muyu_rhythm_${variant.name}');
    try {
      // Windows 的默认 release 模式会在短音频结束后释放 MediaSource。
      // 木鱼属于高频重复音效，保留已准备的音源并从头 resume 更稳定。
      await player.setReleaseMode(ReleaseMode.stop);
      await player.setSource(AssetSource(variant.asset));
      return player;
    } catch (_) {
      await player.dispose();
      rethrow;
    }
  }

  Future<void> _enqueue(Future<void> Function() operation) {
    final result = _pendingOperation.then((_) => operation());
    _pendingOperation = result.then<void>(
      (_) {},
      onError: (Object _, StackTrace __) {},
    );
    return result;
  }

  Future<void> playMuyu(MuyuSoundVariant variant) => _enqueue(() async {
    for (final playerFuture in _players.values) {
      try {
        await (await playerFuture).stop();
      } catch (_) {
        // A failed fallback player must not block the usable variants.
      }
    }
    Object? lastError;
    StackTrace? lastStackTrace;
    for (final candidate in _fallbacks(variant)) {
      try {
        await (await _playerFor(candidate)).resume();
        return;
      } catch (error, stackTrace) {
        lastError = error;
        lastStackTrace = stackTrace;
      }
    }
    Error.throwWithStackTrace(
      lastError ?? StateError('没有可用的木鱼音频'),
      lastStackTrace ?? StackTrace.current,
    );
  });

  Future<void> stopMuyu() => _enqueue(() async {
    for (final playerFuture in _players.values) {
      try {
        await (await playerFuture).stop();
      } catch (_) {
        // Continue stopping the remaining players.
      }
    }
  });

  Future<void> dispose() => _enqueue(() async {
    for (final playerFuture in _players.values) {
      try {
        await (await playerFuture).dispose();
      } catch (_) {
        // Continue disposing the remaining players.
      }
    }
    _players.clear();
  });

  static List<MuyuSoundVariant> _fallbacks(MuyuSoundVariant variant) =>
      switch (variant) {
        MuyuSoundVariant.c => const [
          MuyuSoundVariant.c,
          MuyuSoundVariant.b,
          MuyuSoundVariant.a,
          MuyuSoundVariant.regular,
        ],
        MuyuSoundVariant.b => const [
          MuyuSoundVariant.b,
          MuyuSoundVariant.a,
          MuyuSoundVariant.regular,
        ],
        MuyuSoundVariant.a => const [
          MuyuSoundVariant.a,
          MuyuSoundVariant.regular,
        ],
        MuyuSoundVariant.regular => const [MuyuSoundVariant.regular],
      };
}
