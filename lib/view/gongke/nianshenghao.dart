import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../comm/audio_tools.dart';
import '../../comm/muyu_rhythm_store.dart';
import '../../comm/nianfo_muyu_session_controller.dart';
import '../../comm/pub_tools.dart';
import '../../comm/shared_preferences.dart';
import '../../database.dart';
import '../../model/muyu_rhythm_pattern.dart';

class NianShengHaoPage extends StatefulWidget {
  const NianShengHaoPage({super.key});

  @override
  State<NianShengHaoPage> createState() => _NianShengHaoPageState();
}

class _NianShengHaoPageState extends State<NianShengHaoPage> {
  GongKeItemData? _item;
  bool _loaded = false;
  double _interval = 1;
  String _selectedPatternId = 'regular';
  Timer? _uiTimer;
  late final NianFoMuyuSessionController _session;

  String get _intervalKey =>
      'gongke.muyuIntervalSeconds.${_item!.gongketype}.${_item!.name}';
  MuyuRhythmPattern get _pattern =>
      muyuRhythmStore.patternFor(_selectedPatternId);

  @override
  void initState() {
    super.initState();
    _session = NianFoMuyuSessionController(
      onCompleted: () {
        WakelockPlus.disable();
        if (mounted) setState(() {});
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is Map && arguments['gongkeitem'] is GongKeItemData) {
      _item = arguments['gongkeitem'] as GongKeItemData;
      _selectedPatternId = muyuRhythmStore.selectedPatternId(
        gongKeType: _item!.gongketype,
        gongKeName: _item!.name,
      );
      _loadInterval();
    }
  }

  Future<void> _loadInterval() async {
    final saved = await getDoubleValue(_intervalKey);
    if (saved != null && mounted) setState(() => _interval = saved);
  }

  bool get _canResume =>
      !_session.isActive &&
      _session.remainingCount > 0 &&
      _session.remainingCount < (_item?.cnt ?? 0);

  String get _primaryLabel => _session.isActive
      ? '暂停'
      : _canResume
      ? '继续'
      : '开始';

  Future<void> _primaryAction() async {
    if (_item == null) return;
    if (_session.isActive) {
      _pause();
      return;
    }
    await WakelockPlus.enable();
    if (_canResume) {
      await _session.resume(
        pattern: _pattern,
        interval: Duration(milliseconds: (_interval * 1000).round()),
      );
    } else {
      await _session.start(
        pattern: _pattern,
        totalCount: _item!.cnt,
        interval: Duration(milliseconds: (_interval * 1000).round()),
      );
    }
    _startUiTicker();
    if (mounted) setState(() {});
  }

  void _pause() {
    _session.pause();
    _uiTimer?.cancel();
    WakelockPlus.disable();
    if (mounted) setState(() {});
  }

  void _stop() {
    _session.dispose();
    _uiTimer?.cancel();
    WakelockPlus.disable();
    if (mounted) setState(() {});
  }

  void _startUiTicker() {
    _uiTimer?.cancel();
    _uiTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (mounted) setState(() {});
      if (!_session.isActive) _uiTimer?.cancel();
    });
  }

  Future<void> _selectPattern(String? id) async {
    if (id == null || _item == null || _session.isActive) return;
    setState(() => _selectedPatternId = id);
    await muyuRhythmStore.select(
      patternID: id,
      gongKeType: _item!.gongketype,
      gongKeName: _item!.name,
    );
  }

  Future<void> _openManagement() async {
    if (_session.isActive) return;
    await Navigator.pushNamed(context, '/GongKe/MuyuRhythmManagement');
    if (!mounted || _item == null) return;
    setState(() {
      _selectedPatternId = muyuRhythmStore.selectedPatternId(
        gongKeType: _item!.gongketype,
        gongKeName: _item!.name,
      );
    });
  }

  @override
  void dispose() {
    _uiTimer?.cancel();
    _session.dispose();
    WakelockPlus.disable();
    AudioTools.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = _item;
    if (item == null) {
      return const Scaffold(body: Center(child: Text('加载中…')));
    }
    final total = item.cnt;
    return Scaffold(
      appBar: AppBar(title: const Text('电子木鱼')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '${item.name} ${item.cnt} 遍',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            initialValue: _selectedPatternId,
            decoration: const InputDecoration(
              labelText: '播放模式',
              border: OutlineInputBorder(),
            ),
            items: muyuRhythmStore.selectablePatterns
                .map(
                  (pattern) => DropdownMenuItem(
                    value: pattern.id,
                    child: Text(pattern.displayName),
                  ),
                )
                .toList(),
            onChanged: _session.isActive ? null : _selectPattern,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(_pattern.groupedDescription),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.tune),
            title: const Text('管理十念法'),
            subtitle: const Text('创建、编辑、恢复默认和查看使用次数'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _session.isActive ? null : _openManagement,
          ),
          const Divider(),
          Text('木鱼间隔：${_interval.toStringAsFixed(1)} 秒'),
          Slider(
            min: 0.5,
            max: 3,
            divisions: 25,
            value: _interval,
            onChanged: _session.isActive
                ? null
                : (value) => setState(() => _interval = value),
            onChangeEnd: _session.isActive
                ? null
                : (value) => saveDoubleValue(_intervalKey, value),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 180,
                child: ElevatedButton(
                  onPressed: _primaryAction,
                  style: AppButtonStyle.primaryButton,
                  child: Text(_primaryLabel),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: _session.playedCount > 0 ? _stop : null,
                child: const Text('停止'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('总共 $total 声，当前第 ${_session.playedCount} 声'),
          LinearProgressIndicator(
            value: total > 0 ? _session.playedCount / total : 0,
          ),
          if (_session.isActive)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text('播放期间已锁定节奏、管理和间隔设置。'),
            ),
        ],
      ),
    );
  }
}
