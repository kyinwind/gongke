import 'dart:async';
import 'dart:developer' as developer;

import '../model/muyu_rhythm_pattern.dart';
import 'audio_tools.dart';
import 'muyu_rhythm_audio_player.dart';

enum NianFoMuyuState { idle, leadingChime, playing, completed }

class NianFoMuyuSessionController {
  NianFoMuyuSessionController({
    this.onCompleted,
    Future<void> Function()? waitForLeadingChime,
    Future<void> Function(MuyuSoundVariant)? playStrike,
    Future<void> Function()? stopStrikes,
    void Function()? playCompletionChime,
  }) : _waitForLeadingChime =
           waitForLeadingChime ??
           (() => AudioTools.playLocalAssetAndWait('mp3/yinqing.wav')),
       _playStrike = playStrike ?? MuyuRhythmAudioPlayer().playMuyu,
       _stopStrikes = stopStrikes ?? MuyuRhythmAudioPlayer().stopMuyu,
       _playCompletionChime =
           playCompletionChime ??
           (() => AudioTools.playLocalAsset('mp3/yinqing.wav'));

  final void Function()? onCompleted;
  final Future<void> Function() _waitForLeadingChime;
  final Future<void> Function(MuyuSoundVariant) _playStrike;
  final Future<void> Function() _stopStrikes;
  final void Function() _playCompletionChime;
  Timer? _timer;
  Duration _interval = const Duration(seconds: 1);
  NianFoMuyuState state = NianFoMuyuState.idle;
  MuyuRhythmPattern? activePattern;
  int totalCount = 0;
  int remainingCount = 0;
  int strikeIndex = 0;

  bool get isActive =>
      state == NianFoMuyuState.leadingChime || state == NianFoMuyuState.playing;
  int get playedCount => totalCount - remainingCount;

  Future<void> start({
    required MuyuRhythmPattern pattern,
    required int totalCount,
    required Duration interval,
  }) async {
    if (isActive || totalCount <= 0) return;
    this.totalCount = totalCount;
    remainingCount = totalCount;
    strikeIndex = 0;
    await _begin(pattern, interval);
  }

  Future<void> resume({
    required MuyuRhythmPattern pattern,
    required Duration interval,
  }) async {
    if (isActive || remainingCount <= 0) return;
    strikeIndex = 0;
    await _begin(pattern, interval);
  }

  Future<void> _begin(MuyuRhythmPattern pattern, Duration interval) async {
    activePattern = pattern;
    _interval = interval;
    state = NianFoMuyuState.leadingChime;
    await _waitForLeadingChime();
    if (state != NianFoMuyuState.leadingChime) return;
    state = NianFoMuyuState.playing;
    _scheduleNextBeat();
  }

  void _scheduleNextBeat() {
    _timer?.cancel();
    _timer = Timer(_interval, () => unawaited(_beat()));
  }

  Future<void> _beat() async {
    if (state != NianFoMuyuState.playing) return;
    if (remainingCount <= 0) {
      await _complete();
      return;
    }
    try {
      await _playStrike(
        activePattern?.variantForZeroBasedStrikeIndex(strikeIndex) ??
            MuyuSoundVariant.regular,
      );
    } catch (error, stackTrace) {
      developer.log(
        '木鱼音频播放失败',
        name: 'NianFoMuyuSessionController',
        error: error,
        stackTrace: stackTrace,
      );
      if (state == NianFoMuyuState.playing) _scheduleNextBeat();
      return;
    }
    if (state != NianFoMuyuState.playing) return;
    strikeIndex++;
    remainingCount--;
    // 最后一声也保留一个完整节拍，避免刚开始播放就被 stopMuyu 截断。
    if (remainingCount == 0) {
      _timer = Timer(_interval, () => unawaited(_complete()));
    } else {
      _scheduleNextBeat();
    }
  }

  Future<void> _complete() async {
    if (state != NianFoMuyuState.playing) return;
    _timer?.cancel();
    _timer = null;
    state = NianFoMuyuState.completed;
    await _stopStrikes();
    _playCompletionChime();
    onCompleted?.call();
  }

  void pause() {
    _timer?.cancel();
    _timer = null;
    _stopStrikes();
    strikeIndex = 0;
    if (state != NianFoMuyuState.completed) state = NianFoMuyuState.idle;
  }

  void dispose() {
    pause();
    state = NianFoMuyuState.idle;
  }
}
