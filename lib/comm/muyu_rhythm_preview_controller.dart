import 'dart:async';

import '../model/muyu_rhythm_pattern.dart';
import 'muyu_rhythm_audio_player.dart';

class MuyuRhythmPreviewController {
  final MuyuRhythmAudioPlayer _audio = MuyuRhythmAudioPlayer();
  Timer? _timer;
  int _playedCount = 0;
  bool isPlaying = false;

  int get playedCount => _playedCount;

  void start({required MuyuRhythmPattern pattern, double interval = 1}) {
    stop();
    isPlaying = true;
    void playNext() {
      if (!isPlaying || _playedCount >= 20) {
        stop();
        return;
      }
      _audio.playMuyu(pattern.variantForZeroBasedStrikeIndex(_playedCount));
      _playedCount++;
      _timer = Timer(
        Duration(milliseconds: (interval * 1000).round()),
        playNext,
      );
    }

    playNext();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    isPlaying = false;
    _playedCount = 0;
    _audio.stopMuyu();
  }

  void dispose() => stop();
}
