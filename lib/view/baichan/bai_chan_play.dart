import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../database.dart';

class BaiChanPlayPage extends StatefulWidget {
  final BaiChanData baichan;

  BaiChanPlayPage({required this.baichan});

  @override
  _BaiChanPlayPageState createState() => _BaiChanPlayPageState();
}

class _BaiChanPlayPageState extends State<BaiChanPlayPage> {
  int count = 0;
  bool isPlaying = false;
  bool flag = true;
  int num = 0;
  Timer? _timer;
  String msg = "拜忏中...";
  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _speak(widget.baichan.chanhuiWenStart.toString(), () => _startLoop());
  }

  void _startLoop() {
    setState(() => isPlaying = true);
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!isPlaying) return;

      if (flag) {
        final int baichanInterval2 = widget.baichan.baichanInterval2.toInt();
        if (num % baichanInterval2 == 0) {
          count++;
          if (count <= widget.baichan.baichanTimes &&
              widget.baichan.flagOrderNumber) {
            _speak("第$count 拜", () {});
          }
          num = 0;
          flag = false;
        }
        if (count == widget.baichan.baichanTimes.toInt() + 1) {
          _speak(widget.baichan.chanhuiWenEnd, () {
            _stop();
            Navigator.pop(context);
          });
        }
        num++;
      } else {
        if (num % widget.baichan.baichanInterval1.toInt() == 0) {
          if (widget.baichan.flagQiShen) {
            _speak("起身", () {});
          }
          num = 0;
          flag = true;
        }
        num++;
      }
    });
  }

  Future<void> _speak(String text, VoidCallback onDone) async {
    await flutterTts.setLanguage("zh-CN");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.speak(text);
    flutterTts.setCompletionHandler(() {
      onDone();
    });
  }

  void _stop() {
    _timer?.cancel();
    flutterTts.stop();
    setState(() => isPlaying = false);
  }

  @override
  void dispose() {
    _stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bai = widget.baichan;
    return Scaffold(
      appBar: AppBar(
        title: Text('拜忏进行中'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            _stop();
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: GestureDetector(
          onTap: isPlaying ? _stop : _startLoop,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(bai.image, height: 300),
              SizedBox(height: 20),
              Text('$count / ${bai.baichanTimes.toInt()} $msg'),
            ],
          ),
        ),
      ),
    );
  }
}
