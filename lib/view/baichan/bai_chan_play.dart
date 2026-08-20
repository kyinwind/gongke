import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../comm/audio_tools.dart';
import '../../comm/pub_tools.dart';
import '../../comm/tts_tools.dart';
import '../../database.dart';

class BaiChanPlayPage extends StatefulWidget {
  const BaiChanPlayPage({super.key});

  @override
  State<BaiChanPlayPage> createState() => _BaiChanPlayPageState();
}

class _BaiChanPlayPageState extends State<BaiChanPlayPage> {
  final TtsTools _tts = TtsTools();
  BaiChanData? _baichan;
  Timer? _timer;
  int _count = 0;
  int _seconds = 0;
  bool _isPlaying = false;
  bool _waitingBetweenBows = true;
  bool _isAnnouncing = false;
  bool _initialized = false;
  String _message = '拜忏中…';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is Map<String, dynamic>) {
      _baichan = arguments['baichan'] as BaiChanData?;
    }
    final current = _baichan;
    if (current != null) {
      _announce(current.chanhuiWenStart, _startLoop);
    }
  }

  Future<void> _announce(String text, VoidCallback onDone) async {
    if (!mounted) return;
    setState(() {
      _message = text;
      _isAnnouncing = true;
    });
    await _tts.speak(text, () {
      if (!mounted) return;
      setState(() => _isAnnouncing = false);
      onDone();
    });
  }

  Future<void> _speakAfterBell(String text, {VoidCallback? onDone}) async {
    if (_isAnnouncing) return;
    setState(() => _isAnnouncing = true);
    await AudioTools.playLocalAssetAndWait('mp3/yinqing.wav');
    if (!mounted || !_isPlaying) return;
    await _announce(text, onDone ?? () {});
  }

  void _startLoop() {
    if (!mounted || _isPlaying) return;
    setState(() => _isPlaying = true);
    WakelockPlus.enable();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final current = _baichan;
    if (!mounted || !_isPlaying || _isAnnouncing || current == null) return;
    _seconds++;
    if (_waitingBetweenBows) {
      if (_seconds < max(1, current.baichanInterval2)) return;
      _seconds = 0;
      _count++;
      if (_count > current.baichanTimes) {
        _speakAfterBell(
          current.chanhuiWenEnd,
          onDone: () async {
            await _stop();
            if (mounted) Navigator.pop(context);
          },
        );
        return;
      }
      setState(() => _waitingBetweenBows = false);
      if (current.flagOrderNumber) _speakAfterBell('第 $_count 拜');
    } else {
      if (_seconds < max(1, current.baichanInterval1)) return;
      _seconds = 0;
      setState(() => _waitingBetweenBows = true);
      if (current.flagQiShen) _speakAfterBell('起身');
    }
  }

  Future<void> _stop() async {
    _timer?.cancel();
    _timer = null;
    _isAnnouncing = false;
    await _tts.stop();
    await AudioTools.clearAndStop();
    await WakelockPlus.disable();
    if (mounted) setState(() => _isPlaying = false);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tts.stop();
    AudioTools.clearAndStop();
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = _baichan;
    if (current == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('拜忏进行中'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            await _stop();
            if (context.mounted) Navigator.pop(context);
          },
        ),
      ),
      body: GestureDetector(
        onTap: _isPlaying ? _stop : _startLoop,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Image.asset(
                  getFoPuSaImagePath(current.image),
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  '$_count / ${current.baichanTimes}\n$_message',
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
