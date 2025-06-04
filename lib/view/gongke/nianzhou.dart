import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gongke/database.dart';
import 'package:gongke/main.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import '../../main.dart';
import 'package:drift/drift.dart' hide Column;
import 'dart:io' show Platform;

class NianzhouPage extends StatefulWidget {
  const NianzhouPage({Key? key}) : super(key: key);

  @override
  State<NianzhouPage> createState() => _NianzhouPageState();
}

class _NianzhouPageState extends State<NianzhouPage> {
  late GongKeItemData gongkeitem;
  VoidCallback? onUpdated;
  int count = 0;
  bool shakeEnabled = true;
  bool vibrateEnabled = true;
  StreamSubscription? _accelerometerSubscription;
  DateTime lastShakeTime = DateTime.now();

  Future<void> _updateCountBeforeExit() async {
    if (count >= gongkeitem.cnt) {
      await globalDB.managers.gongKeItem
          .filter((f) => f.id.equals(gongkeitem.id))
          .update((f) => f(curCnt: Value(count), isComplete: Value(true)));
    } else {
      await globalDB.managers.gongKeItem
          .filter((f) => f.id.equals(gongkeitem.id))
          .update((f) => f(curCnt: Value(count)));
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    if (args != null) {
      gongkeitem = args['gongkeitem'] as GongKeItemData;
      onUpdated = args['onUpdated'] as VoidCallback?;

      if (gongkeitem.curCnt > 0) {
        count = gongkeitem.curCnt;
      }
    }

    if (Platform.isAndroid) {
      _startListeningShake();
    }
  }

  void _startListeningShake() {
    if (!Platform.isAndroid) {
      // 只在Android监听，加这句防止调用
      return;
    }
    _accelerometerSubscription = accelerometerEventStream().listen((
      AccelerometerEvent event,
    ) {
      if (!shakeEnabled) return;

      double delta = event.x.abs() + event.y.abs() + event.z.abs();
      if (delta > 18) {
        final now = DateTime.now();
        if (now.difference(lastShakeTime).inMilliseconds > 1000) {
          lastShakeTime = now;
          _incrementCount();
        }
      }
    });
  }

  void _incrementCount() {
    setState(() {
      count += 1;
    });
    if (vibrateEnabled) {
      HapticFeedback.vibrate();
    }
  }

  void _decrementCount() {
    setState(() {
      if (count > 0) count -= 1;
    });
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    _updateCountBeforeExit();
    // 调用父页面传来的回调
    onUpdated?.call();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('功课计数'), leading: BackButton()),
      body: Column(
        children: [
          const SizedBox(height: 10),
          _buildSectionCard(
            Icons.article,
            '功课内容',
            '${gongkeitem.name} ${gongkeitem.cnt}',
          ),
          const SizedBox(height: 10),
          _buildSwitchSection(),
          const SizedBox(height: 10),
          _buildCounterSection(),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: const Text(
              '1、可以点击按钮计数\n'
              '2、也可在亮屏的情况下摇晃手机计数，方便在室外拿着手机做功课。',
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(IconData icon, String title, String content) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.grey[100],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Text(content, style: const TextStyle(fontSize: 18)),
        ),
      ),
    );
  }

  Widget _buildSwitchSection() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.grey[100],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ListTile(leading: const Icon(Icons.tag), title: const Text('计数')),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('是否打开摇晃手机计数'),
            value: shakeEnabled,
            onChanged: (val) => setState(() => shakeEnabled = val),
          ),
          SwitchListTile(
            title: const Text('计数时是否打开震动'),
            value: vibrateEnabled,
            onChanged: (val) => setState(() => vibrateEnabled = val),
          ),
        ],
      ),
    );
  }

  Widget _buildCounterSection() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.grey[100],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              iconSize: 36,
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: _decrementCount,
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.spa_rounded, color: Colors.white),
              label: Text(
                '功课计数\n($count)',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              onPressed: _incrementCount,
            ),
            const SizedBox(width: 16),
            IconButton(
              iconSize: 36,
              icon: const Icon(Icons.add_circle_outline),
              onPressed: _incrementCount,
            ),
          ],
        ),
      ),
    );
  }
}
