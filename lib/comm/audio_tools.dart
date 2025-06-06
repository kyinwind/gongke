import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioTools {
  static final AudioPlayer _player = AudioPlayer();
  static bool _isDisposed = false;

  static Future<void> playLocalAsset(String file) async {
    if (_isDisposed) {
      await _player.dispose();
      _isDisposed = false;
    }

    try {
      await _player.stop();
      await _player.play(AssetSource(file));
    } catch (e) {
      debugPrint('音频播放出错: $e');
    }
  }

  static Future<void> dispose() async {
    if (!_isDisposed) {
      await _player.dispose();
      _isDisposed = true;
    }
  }
}
