import 'dart:async';

import 'package:flutter/foundation.dart';

import '../model/muyu_rhythm_pattern.dart';
import 'muyu_rhythm_audio_player.dart';

class MuyuRhythmPreviewController {
  final MuyuRhythmAudioPlayer _audio = MuyuRhythmAudioPlayer();
  Timer? _timer;
  int _playedCount = 0;
  int _sessionId = 0;
  bool isPlaying = false;

  int get playedCount => _playedCount;

  void start({required MuyuRhythmPattern pattern, double interval = 1}) {
    stop();
    final sessionId = ++_sessionId;
    isPlaying = true;
    Future<void> playNext() async {
      if (!isPlaying || sessionId != _sessionId || _playedCount >= 20) {
        stop();
        return;
      }
      try {
        await _audio.playMuyu(
          pattern.variantForZeroBasedStrikeIndex(_playedCount),
        );
      } catch (error) {
        debugPrint('木鱼节奏预览失败: $error');
        stop();
        return;
      }
      if (!isPlaying || sessionId != _sessionId) return;
      _playedCount++;
      _timer = Timer(
        Duration(milliseconds: (interval * 1000).round()),
        () => unawaited(playNext()),
      );
    }

    unawaited(playNext());
  }

  void stop() {
    _sessionId++;
    _timer?.cancel();
    _timer = null;
    isPlaying = false;
    _playedCount = 0;
    _audio.stopMuyu();
  }

  void dispose() => stop();
}
