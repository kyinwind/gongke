import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:gongke/database.dart';
import '../../main.dart';
import 'fayuan_wizard.dart';
import '../../comm/pdf_view.dart';
import '../../comm/pub_tools.dart';
import 'package:flutter/services.dart';

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
  // 按发愿ID分组
  Map<int, List<GongKeItemData>> dayRecordsGroupedByFaYuan = {};

  // 添加一个Map来存储本地状态
  final Map<int, bool> _switchStates = {};

  bool _canEdit = false;
  bool _showCompleteButton = false;

  void _setAllComplete() async {
    // 将当天所有任务标记为完成
    await globalDB.managers.gongKeItem
        .filter((item) => item.gongKeDay.equals(date))
        .update((o) => o(isComplete: const Value(true)));
  }

  void _updateEditState(String dateStr) {
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    final inputDate = DateTime.parse(dateStr);

    setState(() {
      // 只有今天和昨天可以编辑
      _canEdit =
          inputDate.year == today.year &&
          inputDate.month == today.month &&
          (inputDate.day == today.day || inputDate.day == yesterday.day);

      // 同样的条件控制按钮显示
      _showCompleteButton = _canEdit;
    });
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

    // 初始化编辑状态
    _updateEditState(date);

    dayRecords = groupedRecords[date] ?? [];
    // 按发愿ID分组
    dayRecordsGroupedByFaYuan.clear();
    for (var record in dayRecords) {
      if (!dayRecordsGroupedByFaYuan.containsKey(record.fayuanId)) {
        dayRecordsGroupedByFaYuan[record.fayuanId] = [];
      }
      dayRecordsGroupedByFaYuan[record.fayuanId]!.add(record);
    }

    // 初始化开关状态
    for (var record in dayRecords) {
      _switchStates[record.id] = record.isComplete;
    }
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

  // 跳转到PDF页面
  void _navigateToPdfView(String pdfName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfViewerPage(pdfFileName: pdfName),
      ),
    );
  }

  Widget _buildTaskList() {
    return Expanded(
      child: Card(
        color: const Color(0xFFF5F6FA),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListView.builder(
          itemCount: dayRecordsGroupedByFaYuan.length,
          itemBuilder: (context, index) {
            int fayuanId = dayRecordsGroupedByFaYuan.keys.elementAt(index);
            List<GongKeItemData> fayuanItems =
                dayRecordsGroupedByFaYuan[fayuanId]!;

            return Column(
              children: [
                // 发愿标题
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.all(16.0),
                  child: FutureBuilder<FaYuanData?>(
                    future: globalDB.managers.faYuan
                        .filter((f) => f.id.equals(fayuanId))
                        .getSingleOrNull(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox();
                      return Text(
                        snapshot.data?.name ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                // 功课项目列表
                ...fayuanItems.map(
                  (item) => SwitchListTile(
                    value: _switchStates[item.id] ?? false,
                    onChanged:
                        _canEdit // 根据_canEdit控制是否可点击
                        ? (value) async {
                            setState(() {
                              _switchStates[item.id] = value;
                            });
                            await globalDB.managers.gongKeItem
                                .filter((t) => t.id.equals(item.id))
                                .update((o) => o(isComplete: Value(value)));
                            updateCallback();
                          }
                        : null, // 不可编辑时设为null
                    title: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (!_canEdit) return;
                            switch (item.gongketype) {
                              case 'songjing':
                                _navigateToPdfView(getPdfFileByName(item.name));
                                break;
                              case 'nianzhou':
                                Navigator.pushNamed(
                                  context,
                                  '/GongKe/GongKeSetting/nianzhou',
                                  arguments: {
                                    'name': item.name,
                                    'cnt': item.cnt,
                                  },
                                );
                              case 'nianshenghao':
                                Navigator.pushNamed(
                                  context,
                                  '/GongKe/GongKeSetting/nianshenghao',
                                  arguments: {
                                    'name': item.name,
                                    'cnt': item.cnt,
                                  },
                                );
                              case 'ketou':
                              case 'baichan':
                              case 'dazuo':
                                Navigator.pushNamed(
                                  context,
                                  '/GongKe/GongKeSetting/dazuo',
                                  arguments: {
                                    'name': item.name,
                                    'cnt': item.cnt,
                                  },
                                );
                                break;
                              default:
                                // 其他类型不做处理
                                break;
                            }
                          }, // 不可编辑时禁用点击
                          child: Text(
                            getGongkeItemLabel(item),
                            style: TextStyle(
                              //fontSize: 16,
                              color:
                                  item.gongketype == 'songjing' ||
                                      item.gongketype == 'nianzhou'
                                  ? Colors.blue
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      _switchStates[item.id] == true ? '已完成' : '未完成',
                    ),
                    secondary: const Icon(Icons.chevron_right),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 0,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildButtons() {
    // 如果不显示按钮，直接返回空容器
    if (!_showCompleteButton) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        const SizedBox(width: 30),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            style: AppButtonStyle.primaryButton,
            onPressed: _canEdit
                ? () {
                    if (!mounted) return;
                    _setAllComplete();
                    Navigator.pop(context);
                    updateCallback();
                  }
                : null, // 不可编辑时禁用按钮
            child: const Text('全部设为完成', style: TextStyle(color: Colors.white)),
          ),
        ),
        const SizedBox(width: 30),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            style: AppButtonStyle.primaryButton,
            onPressed: () {
              String gongkeText = '!!';
              for (var record in dayRecords) {
                if (record.isComplete) {
                  gongkeText += '${record.name}${record.cnt},';
                }
              }
              Clipboard.setData(ClipboardData(text: gongkeText));
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('已复制到剪贴板')));
            },
            child: const Text('生成报课文本', style: TextStyle(color: Colors.white)),
          ),
        ),
        const SizedBox(width: 30),
      ],
    );
  }
}
