import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gongke/database.dart';
import '../../comm/audio_tools.dart';

class NianShengHaoPage extends StatefulWidget {
  const NianShengHaoPage({super.key});

  @override
  State<NianShengHaoPage> createState() => _NianShengHaoPageState();
}

class _NianShengHaoPageState extends State<NianShengHaoPage> {
  GongKeItemData? gongkeitem;
  bool isRunning = false;
  Timer? timer;
  double interval = 1.0;
  int currentCount = 0;
  bool isLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!isLoaded) {
      final args = ModalRoute.of(context)?.settings.arguments as Map?;
      if (args != null && args['gongkeitem'] is GongKeItemData) {
        gongkeitem = args['gongkeitem'] as GongKeItemData;
        isLoaded = true;
      }
      print(gongkeitem.toString());
    }
  }

  void startOrPause() {
    if (isRunning) {
      pause();
    } else {
      start();
    }
  }

  void start() {
    setState(() {
      isRunning = true;
    });

    timer?.cancel();
    timer = Timer.periodic(Duration(milliseconds: (interval * 1000).toInt()), (
      timer,
    ) async {
      if (currentCount >= (gongkeitem?.cnt ?? 0)) {
        stop();
        return;
      }

      if (mounted) {
        // 先播放音频
        await AudioTools.playLocalAsset('mp3/muyu.wav');

        // 再更新计数
        if (mounted) {
          setState(() {
            currentCount++;
          });
        }
      }
    });
  }

  void pause() {
    setState(() {
      isRunning = false;
    });
    timer?.cancel();
    timer = null;
  }

  void stop() {
    pause();
    setState(() {
      currentCount = gongkeitem?.cnt ?? 0;
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (gongkeitem == null) {
      return Scaffold(
        appBar: AppBar(leading: BackButton()),
        body: const Center(child: Text("加载中...")),
      );
    }

    final total = gongkeitem!.cnt;
    final current = currentCount;

    return Scaffold(
      appBar: AppBar(title: const Text("电子木鱼"), leading: BackButton()),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("功课内容", style: TextStyle(fontWeight: FontWeight.bold)),
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text("${gongkeitem!.name} ${gongkeitem!.cnt}遍"),
            ),
            const SizedBox(height: 12),
            Row(
              children: const [
                Text(
                  "请设置电子木鱼时间间隔：",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 4),
              ],
            ),
            Row(
              children: [
                Text(
                  interval.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 24, color: Colors.blue),
                ),
                const SizedBox(width: 8),
                const Text("单位:秒"),
              ],
            ),
            Row(
              children: [
                Text('0.5秒'),
                const SizedBox(width: 8),
                Expanded(
                  child: Slider(
                    min: 0.5,
                    max: 3.0,
                    value: interval,
                    divisions: 45,
                    onChanged: (value) {
                      setState(() {
                        interval = value;
                      });
                      if (isRunning) {
                        pause();
                        start(); // 重启计时器以应用新间隔
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                const Text('3秒'),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              "点击按钮开始敲打木鱼：",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: startOrPause,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(120, 48),
                    ),
                    child: Text(isRunning ? "暂停" : "开始"),
                  ),
                  const SizedBox(height: 12),
                  Text("总共 $total 声，当前第 $current 声"),
                  LinearProgressIndicator(
                    value: total > 0 ? current / total : 0,
                    backgroundColor: Colors.grey[300],
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
