import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

//enum TtsState { playing, stopped, paused, continued }

class TtsTools {
  late FlutterTts flutterTts;
  late final Future<void> _initialization;
  String? language;
  String? engine;
  double volume = 0.5;
  double pitch = 1.0;
  double rate = 0.5;
  bool isCurrentLanguageInstalled = false;

  bool get isIOS => !kIsWeb && Platform.isIOS;
  bool get isAndroid => !kIsWeb && Platform.isAndroid;
  bool get isWindows => !kIsWeb && Platform.isWindows;
  bool get isWeb => kIsWeb;

  // 构造函数
  TtsTools() {
    // 这里写初始化代码，创建实例时会自动执行
    print("TtsTools 开始初始化...");
    // 示例：初始化TTS引擎
    flutterTts = FlutterTts();
    _initialization = _initialize();
    print("TtsTools 初始化完成");
  }

  Future<void> _initialize() async {
    await flutterTts.setLanguage("zh-CN");
    await flutterTts.setSpeechRate(0.5); // 设置语速
    await flutterTts.setPitch(1.0); // 设置音调
    // 设置播放完成后再结束 speak Future。
    await _setAwaitOptions();
    if (isAndroid) {
      await _getDefaultEngine();
      await _getDefaultVoice();
    }
  }

  Future<dynamic> getLanguages() async => await flutterTts.getLanguages;

  Future<dynamic> getEngines() async => await flutterTts.getEngines;

  Future<void> _getDefaultEngine() async {
    var engine = await flutterTts.getDefaultEngine;
    if (engine != null) {
      print(engine);
    }
  }

  Future<void> _getDefaultVoice() async {
    var voice = await flutterTts.getDefaultVoice;
    if (voice != null) {
      print(voice);
    }
  }

  Future<void> speak(String text, VoidCallback? onDone) async {
    await _initialization;
    await flutterTts.setVolume(volume);
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setPitch(pitch);

    var completionReported = false;
    void reportCompletionOnce() {
      if (completionReported) return;
      completionReported = true;
      onDone?.call();
    }

    if (onDone != null) {
      flutterTts.setCompletionHandler(reportCompletionOnce);
    }
    try {
      await flutterTts.speak(text);
    } finally {
      // flutter_tts 使用静态 channel。存在多个实例时，原生完成事件可能被
      // 其他实例接收；awaitSpeakCompletion 保证 Future 仍会在自然结束时完成。
      reportCompletionOnce();
    }
  }

  Future<void> _setAwaitOptions() async {
    await flutterTts.awaitSpeakCompletion(true);
  }

  Future<void> stop() async {
    flutterTts.setCompletionHandler(() {});
    var result = await flutterTts.stop();
    if (result == 1) {}
  }

  Future<void> pause() async {
    var result = await flutterTts.pause();
    if (result == 1) {}
  }
}
