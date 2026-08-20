import 'package:flutter/material.dart';
import 'package:gongke/main.dart';
import 'package:styled_widget/styled_widget.dart';
import '../../database.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter_slidable/flutter_slidable.dart'; // 导入 Slidable 库
import 'dart:convert'; // 导入 dart:convert 库，确保已导入
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:gongke/comm/tip_export_service.dart';
import 'package:gongke/comm/tip_import_service.dart';
import 'package:gongke/comm/today_tip_service.dart';
import 'package:gongke/comm/tts_tools.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gongke/viewmodel/current_record.dart';
import 'package:gongke/comm/pub_tools.dart';
import 'package:my_flutter_app_tools/my_flutter_app_tools.dart';
import '../help/help_center_page.dart';

// 为了让页面能够上下滑动，将 Scaffold 的 body 用 SingleChildScrollView 包裹
class TipPage extends StatefulWidget {
  const TipPage({super.key});

  @override
  State<TipPage> createState() => _TipPageState();
}

// 在 _TipPageState 类中添加数据库实例和记录列表
class _TipPageState extends State<TipPage> {
  Stream<List<TipBookData>> records = Stream.value([]);
  CurrentRecord curRec = CurrentRecord();
  final TtsTools _tts = TtsTools();
  TodayTipMode _todayTipMode = TodayTipMode.sequential;
  int _refreshSequence = 0;
  bool _isSpeaking = false;
  _TipPageState(); // 添加构造函数

  @override
  void initState() {
    super.initState();
    fetchTip();
    _checkRecords();
  }

  Future<void> _checkRecords() async {
    _todayTipMode = await TodayTipSettings.loadMode();
    // 监听 Stream 的第一个值
    final firstValue = await records.first;
    if (firstValue.isEmpty) {
      if (appBuildFlag) {
        //如果是完整版本，则导入内置开示文件
        await importTip();
      }

      fetchTip();
    }
    await _loadCurrentRecord();
  }

  // 新增方法处理异步加载
  Future<void> _loadCurrentRecord({bool refresh = false}) async {
    if (refresh) _refreshSequence++;
    final record = await getCurrentRecord(
      mode: _todayTipMode,
      refreshSequence: _refreshSequence,
      previousRecordId: curRec.id,
    );
    if (!mounted) return;
    setState(() {
      curRec = record;
      //print(curRec.id);
      //print(curRec.content);
    });
  }

  Future<void> importTip() async {
    // 假设文件名为 广钦老和尚开示.json, 第二个文件.json, 第三个文件.json, 第四个文件.json
    final fileNames = ['1.json', '2.json', '3.json', '4.json'];

    final service = TipImportService(globalDB);
    for (final fileName in fileNames) {
      final data = await rootBundle.load('assets/tips/$fileName');
      await service.importBytes(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      );
    }
  }

  Future<void> _importSampleTips() async {
    try {
      final data = await rootBundle.load('assets/tips/fojiaogeyan.json');
      final imported = await TipImportService(globalDB).importBytes(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      );
      if (!mounted) return;
      await fetchTip();
      await _loadCurrentRecord();
      if (!mounted) return;
      if (imported) {
        AppToast.success(context, '已导入佛教格言七则');
      } else {
        AppToast.info(context, '示例开示已存在');
      }
    } catch (error) {
      if (!mounted) return;
      AppToast.error(context, '导入示例失败：$error');
    }
  }

  // 查询所有记录
  Future<void> fetchTip() async {
    final query = globalDB.managers.tipBook.orderBy(
      (t) => t.favoriteDateTime.desc() & t.createDateTime.desc(),
    );
    final books = query.watch(); // 获取所有记录
    setState(() {
      records = books;
    });
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  String? imagePath = 'assets/images/shanshu.png';
  // 设置为最爱
  Future<void> _setFavorite(TipBookData book) async {
    var favoriteDateTime = book.favoriteDateTime;
    if (book.favoriteDateTime != null) {
      favoriteDateTime = null; // 如果已经是最爱，则取消
    } else {
      favoriteDateTime = DateTime.now();
    }
    // 添加数据库更新逻辑
    await globalDB.managers.tipBook
        .filter((f) => f.id(book.id))
        .update((o) => o(favoriteDateTime: Value(favoriteDateTime)));

    await _loadCurrentRecord();
  }

  Future<void> _exportBook(TipBookData book) async {
    try {
      final bytes = await const TipExportService().exportBook(
        globalDB,
        book.id,
      );
      final outputPath = await FilePicker.platform.saveFile(
        dialogTitle: '导出开示录',
        fileName: '${book.name}.json',
        type: FileType.custom,
        allowedExtensions: const ['json'],
        bytes: bytes,
      );
      if (outputPath == null) return;
      final output = File(outputPath);
      if (!await output.exists() || await output.length() != bytes.length) {
        await output.writeAsBytes(bytes, flush: true);
      }
      if (!mounted) return;
      AppToast.success(context, '开示 JSON 已导出');
    } catch (error) {
      if (!mounted) return;
      AppToast.error(context, '导出失败：$error');
    }
  }

  Future<void> _deleteBook(TipBookData book) async {
    final recordCount =
        await (globalDB.select(globalDB.tipRecord)
              ..where((row) => row.bookId.equals(book.id)))
            .get()
            .then((rows) => rows.length);
    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('删除开示录'),
        content: Text('《${book.name}》包含 $recordCount 条记录，确定一并删除吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await globalDB.transaction(() async {
      await (globalDB.delete(
        globalDB.tipRecord,
      )..where((row) => row.bookId.equals(book.id))).go();
      await (globalDB.delete(
        globalDB.tipBook,
      )..where((row) => row.id.equals(book.id))).go();
    });
    await fetchTip();
    await _loadCurrentRecord();
  }

  Future<void> _setTodayTipMode(TodayTipMode mode) async {
    await TodayTipSettings.saveMode(mode);
    if (!mounted) return;
    setState(() {
      _todayTipMode = mode;
      _refreshSequence = 0;
    });
    await _loadCurrentRecord();
  }

  Future<void> _toggleCurrentFavorite() async {
    if (!curRec.hasData) return;
    await (globalDB.update(
      globalDB.tipRecord,
    )..where((row) => row.id.equals(curRec.id))).write(
      TipRecordCompanion(
        favoriteDateTime: Value(
          curRec.favoriteDateTime == null ? DateTime.now() : null,
        ),
      ),
    );
    await _loadCurrentRecord();
  }

  Future<void> _toggleCurrentCompleted() async {
    if (!curRec.hasData) return;
    await (globalDB.update(
      globalDB.tipRecord,
    )..where((row) => row.id.equals(curRec.id))).write(
      TipRecordCompanion(
        completedDateTime: Value(
          curRec.completedDateTime == null ? DateTime.now() : null,
        ),
      ),
    );
    await _loadCurrentRecord();
  }

  Future<void> _editCurrentComment() async {
    if (!curRec.hasData) return;
    final controller = TextEditingController(text: curRec.comments);
    final comment = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('评论'),
        content: TextField(
          controller: controller,
          minLines: 3,
          maxLines: 8,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: const Text('保存'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (comment == null) return;
    await (globalDB.update(globalDB.tipRecord)
          ..where((row) => row.id.equals(curRec.id)))
        .write(TipRecordCompanion(comments: Value(comment.trim())));
    await _loadCurrentRecord();
  }

  Future<void> _copyCurrent() async {
    if (!curRec.hasData) return;
    await Clipboard.setData(ClipboardData(text: curRec.content));
    if (mounted) {
      AppToast.success(context, '开示文本已复制');
    }
  }

  Future<void> _shareCurrent() async {
    if (!curRec.hasData) return;
    try {
      await SharePlus.instance.share(
        ShareParams(text: '${curRec.content}\n——《${curRec.bookName}》'),
      );
    } catch (_) {
      await _copyCurrent();
    }
  }

  Future<void> _speakCurrent() async {
    if (!curRec.hasData) return;
    if (_isSpeaking) {
      await _tts.stop();
      if (mounted) setState(() => _isSpeaking = false);
      return;
    }
    setState(() => _isSpeaking = true);
    await _tts.speak(curRec.content, () {
      if (mounted) setState(() => _isSpeaking = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '开示录',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),

        //backgroundColor: Colors.blue,
        //toolbarHeight: 40,
        actions: [
          const HelpBadgeIcon(),
          const SizedBox(width: 8),
          IconButton(
            tooltip: '导入示例开示',
            icon: const Icon(Icons.library_add_outlined),
            onPressed: _importSampleTips,
          ),
          IconButton(
            icon: const Icon(Icons.arrow_circle_down),
            color: Colors.blue,
            iconSize: 35,
            onPressed: () async {
              // 跳转到新增页面
              final imported = await Navigator.pushNamed(
                context,
                '/ImportFiles',
                arguments: {'jingshutype': 'kaishi'},
              );
              if (!mounted || imported != true) return;
              await fetchTip();
              await _loadCurrentRecord();
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_circle, color: Colors.blue, size: 35),
            onPressed: () {
              // 跳转到新增页面
              Navigator.pushNamed(
                context,
                '/AddTip',
                arguments: {'acttype': 'new'},
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: SlidableAutoCloseBehavior(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 移除SizedBox包装器，直接使用StreamBuilder
              StreamBuilder<List<TipBookData>>(
                stream: records,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Text('错误: ${snapshot.error}');
                  }
                  final books = snapshot.data ?? [];
                  return ListView.builder(
                    shrinkWrap: true, // 保持这个属性确保正确嵌套
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: books.length,
                    itemBuilder: (context, index) {
                      final record = books[index];
                      return Slidable(
                        startActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) {
                                // 跳转到修改页面
                                Navigator.pushNamed(
                                  context,
                                  '/AddTip',
                                  arguments: {
                                    'acttype': 'mod',
                                    'id': record.id,
                                  },
                                );
                              },
                              backgroundColor: Color(0xFF2196F3),
                              foregroundColor: Colors.white,
                              icon: Icons.edit,
                              label: '修改',
                            ),
                            SlidableAction(
                              onPressed: (context) {
                                _setFavorite(books[index]);
                              },
                              backgroundColor: Color.fromARGB(
                                5,
                                201,
                                223,
                                36,
                              ), // 使用不同颜色区分
                              foregroundColor: const Color.fromARGB(
                                255,
                                226,
                                203,
                                50,
                              ),
                              icon: Icons.favorite,
                              label: record.favoriteDateTime == null
                                  ? '最爱'
                                  : '取消',
                            ),
                          ],
                        ),
                        endActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) => _deleteBook(record),
                              backgroundColor: Color(0xFFFE4A49),
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: '删除',
                            ),
                          ],
                        ),
                        child: ListTile(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/TipRecord',
                              arguments: {'bookId': record.id},
                            );
                          },
                          leading: (record.image != '')
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.memory(
                                    const Base64Codec().decode(record.image),
                                    //height: 200,
                                    width: 60,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Image.asset(
                                  'assets/images/jingshu.png',
                                  height: 100,
                                ),
                          title: Text(record.name),
                          subtitle: Row(
                            children: [
                              if (record.favoriteDateTime != null)
                                const Icon(Icons.favorite, color: Colors.yellow)
                              else
                                const SizedBox.shrink(),
                            ],
                          ),
                          trailing: IconButton(
                            tooltip: '导出 JSON',
                            icon: const Icon(Icons.ios_share_outlined),
                            onPressed: () => _exportBook(record),
                          ),
                        ).padding(all: 10),
                      );
                    },
                  );
                },
              ),
              Row(
                children: [
                  const Text(
                    '预览',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ).padding(all: 15),
                  const Spacer(),
                  PopupMenuButton<TodayTipMode>(
                    tooltip: '选择每日开示模式',
                    initialValue: _todayTipMode,
                    onSelected: _setTodayTipMode,
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: TodayTipMode.sequential,
                        child: Text('顺序模式'),
                      ),
                      PopupMenuItem(
                        value: TodayTipMode.random,
                        child: Text('随机模式'),
                      ),
                    ],
                    icon: Icon(
                      _todayTipMode == TodayTipMode.sequential
                          ? Icons.format_list_numbered
                          : Icons.shuffle,
                    ),
                  ),
                  IconButton(
                    tooltip: '随机刷新',
                    icon: const Icon(Icons.refresh),
                    onPressed: curRec.hasData
                        ? () => _loadCurrentRecord(refresh: true)
                        : null,
                  ),
                  IconButton(
                    tooltip: '制作分享卡片',
                    icon: const Icon(Icons.share),
                    color: Colors.blue,
                    iconSize: 35,
                    onPressed: () {
                      // 跳转到新增页面
                      Navigator.pushNamed(context, '/ShareCardPage');
                    },
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center, // 添加水平居中
                crossAxisAlignment: CrossAxisAlignment.center, //
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center, // 添加水平居中
                    crossAxisAlignment: CrossAxisAlignment.center, //
                    children: [
                      (curRec.bookImage != '')
                          ? ClipOval(
                              // 改用 ClipOval
                              child: Image.memory(
                                const Base64Codec().decode(curRec.bookImage),
                                height: 100,
                                width: 100, // 添加宽度确保是圆形
                                fit: BoxFit.cover, // 确保图片填充整个圆形
                              ),
                            )
                          : ClipOval(
                              // 默认图片也使用圆形
                              child: Image.asset(
                                'assets/images/jingshu.png',
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                              ),
                            ).padding(all: 10),
                      const SizedBox(width: 30),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '${DateTime.now().day}',
                                style: const TextStyle(fontSize: 60),
                              ),
                              Divider(),
                              buildVerticalText(
                                '${DateTime.now().month}月',
                                20,
                              ).padding(all: 10),
                              Divider(),
                              //const VerticalDivider(width: 20, thickness: 1, color: Colors.grey),
                              // 在 Column 中添加显示星期几的 Text 组件
                              buildVerticalText(getWeekday(), 20),
                            ],
                          ),
                          Text(
                            '更新:${DateTime.now().toString().split(' ')[0]}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ).padding(all: 10),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        curRec.content,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Spacer(),
                          Text(
                            '《${curRec.bookName}》',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      if (curRec.comments.isNotEmpty)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text('评论：${curRec.comments}'),
                          ),
                        ),
                      if (curRec.hasData)
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 4,
                          children: [
                            IconButton(
                              tooltip: curRec.favoriteDateTime == null
                                  ? '收藏'
                                  : '取消收藏',
                              onPressed: _toggleCurrentFavorite,
                              icon: Icon(
                                curRec.favoriteDateTime == null
                                    ? Icons.favorite_border
                                    : Icons.favorite,
                                color: Colors.amber,
                              ),
                            ),
                            IconButton(
                              tooltip: curRec.completedDateTime == null
                                  ? '标记完成'
                                  : '取消完成',
                              onPressed: _toggleCurrentCompleted,
                              icon: Icon(
                                curRec.completedDateTime == null
                                    ? Icons.check_circle_outline
                                    : Icons.check_circle,
                                color: Colors.green,
                              ),
                            ),
                            IconButton(
                              tooltip: _isSpeaking ? '停止朗读' : '朗读',
                              onPressed: _speakCurrent,
                              icon: Icon(
                                _isSpeaking
                                    ? Icons.stop_circle_outlined
                                    : Icons.volume_up_outlined,
                              ),
                            ),
                            IconButton(
                              tooltip: '复制',
                              onPressed: _copyCurrent,
                              icon: const Icon(Icons.copy_outlined),
                            ),
                            IconButton(
                              tooltip: '分享文本',
                              onPressed: _shareCurrent,
                              icon: const Icon(Icons.share_outlined),
                            ),
                            IconButton(
                              tooltip: '评论',
                              onPressed: _editCurrentComment,
                              icon: const Icon(Icons.comment_outlined),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ).padding(all: 15),
            ],
          ),
        ),
      ),
    );
  }
}

// 构建垂直显示的文本
Widget buildVerticalText(String text, double fontsize) {
  if (text.isEmpty) return const SizedBox();

  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: text
        .split('')
        .map((char) => Text(char, style: TextStyle(fontSize: fontsize)))
        .toList(),
  );
}

// 获取当前日期是星期几
String getWeekday() {
  final weekday = DateTime.now().weekday;
  switch (weekday) {
    case 1:
      return '周一';
    case 2:
      return '周二';
    case 3:
      return '周三';
    case 4:
      return '周四';
    case 5:
      return '周五';
    case 6:
      return '周六';
    case 7:
      return '周日';
    default:
      return '';
  }
}
