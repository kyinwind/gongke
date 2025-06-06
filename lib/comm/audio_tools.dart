import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioTools {
  static final AudioPlayer audioPlayer = AudioPlayer();
  static Duration duration = Duration.zero;
  static Duration position = Duration.zero;
  static PlayerState playerState = PlayerState.stopped;
  // 播放本地资源WAV音频（需先将音频文件放入assets目录）
  static Future<void> playLocalAsset(String file) async {
    try {
      final player = AudioPlayer();
      await player.play(AssetSource(file));

      player.onPlayerComplete.listen((event) {
        player.dispose(); // Clean up after playback
      });
    } catch (e) {
      debugPrint("Error playing audio: $e");
    }
  }
}
