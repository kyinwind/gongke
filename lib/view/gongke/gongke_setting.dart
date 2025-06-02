import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:gongke/database.dart';
import '../../main.dart';
import 'fayuan_wizard.dart';

class GongKeSettingPage extends StatefulWidget {
  const GongKeSettingPage({super.key});

  @override
  State<GongKeSettingPage> createState() => _GongKeSettingPageState();
}

class _GongKeSettingPageState extends State<GongKeSettingPage> {
  late String date;
  late Map<String, List<GongKeItemData>> groupedRecords;
  late Function() updateCallback;
  late List<GongKeItemData> dayRecords;

  void _setAllComplete() async {
    // 将当天所有任务标记为完成
    await globalDB.managers.gongKeItem
        .filter((item) => item.gongKeDay.equals(date))
        .update((o) => o(isComplete: const Value(true)));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    date = args['date'] as String;
    groupedRecords =
        args['groupedRecords'] as Map<String, List<GongKeItemData>>;
    updateCallback = args['updateCallback'] as Function();

    dayRecords = groupedRecords[date] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('功课设置')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              '当天功课完成情况设定',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDateCard(),
            const SizedBox(height: 12),
            _buildTaskList(),
            const SizedBox(height: 12),
            _buildButtons(),
          ],
        ),
      ),
    );
  }

  String getGongkeItemLabel(GongKeItemData item) {
    return '${getLabelSafely(item.gongketype)}: ${item.name} ${item.cnt}遍';
  }

  Widget _buildDateCard() {
    return Card(
      color: const Color(0xFFF5F6FA),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined),
            const SizedBox(width: 8),
            const Text("功课设定："),
            const Spacer(),
            Text(date, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList() {
    return Expanded(
      child: Card(
        color: const Color(0xFFF5F6FA),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListView.separated(
          itemCount: dayRecords.length,
          itemBuilder: (context, index) {
            return SwitchListTile(
              value: dayRecords[index].isComplete,
              onChanged: (value) {
                setState(() {
                  //dayRecords[index].isComplete = value;
                });
              },
              title: Text(
                dayRecords[index].isComplete
                    ? '已完成:${getGongkeItemLabel(dayRecords[index])}'
                    : '未完成:${getGongkeItemLabel(dayRecords[index])}',
                style: const TextStyle(color: Colors.blue),
              ),
              secondary: const Icon(Icons.chevron_right),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 0,
              ),
            );
          },
          separatorBuilder: (_, __) => const Divider(height: 0.5),
        ),
      ),
    );
  }

  Widget _buildButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              if (!mounted) return; // 添加这行检查
              _setAllComplete();
              Navigator.pop(context);
              updateCallback();
            },
            child: const Text('全部设为完成'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(onPressed: () {}, child: const Text('保存')),
        ),
      ],
    );
  }
}
