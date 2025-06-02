import 'dart:ffi';

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:gongke/database.dart';
import 'package:gongke/model/tables.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:lunar/lunar.dart';
import 'package:intl/intl.dart';
//import '../../database.dart';
//import 'fayuan_wizard.dart';
import '../../main.dart';
import '../../comm/date_tools.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class GongKePage extends StatefulWidget {
  const GongKePage({super.key});

  @override
  State<GongKePage> createState() => _GongKePageState();
}

class _GongKePageState extends State<GongKePage> {
  Stream<List<FaYuanData>> fayuandatalist = Stream.value([]);

  // 添加日历控制变量
  DateTime _focusedDay = DateTime.now(); // 当前聚焦的日期
  DateTime? _selectedDay; // 当前选中的日期
  Map<int, double> _fayuanCompletionRates = {}; // 存储每一个发愿的功课完成率
  Map<String, double> _completionRates = {}; // 存储每一天的功课完成率
  // 按日期分组处理当月所有的gongkeitem记录
  Map<String, List<GongKeItemData>> groupedRecords = {};

  Future<void> _refreshAllData() async {
    await fetchAllFaYuan().then((value) {
      // 这里可以添加其他需要在刷新时执行的操作
      print(_fayuanCompletionRates.toString());
      print(_completionRates.toString());
    });
    await _loadCompletionRates(_focusedDay);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _refreshAllData();
  }

  // 查询所有记录,以及计算功课完成率
  Future<void> fetchAllFaYuan() async {
    try {
      final query = globalDB.managers.faYuan
          .filter(
            (f) =>
                f.startDate.isBeforeOrOn(DateTime.now()) &
                f.endDate.isAfterOrOn(DateTime.now()),
          )
          .orderBy((o) => o.createDateTime.desc());
      final result = await query.watch();
      final tempfayuanlist = await query.get();
      //print(tempfayuanlist.toString());
      // 计算所有发愿的功课完成率
      for (var fayuan in tempfayuanlist) {
        // 获取该发愿的所有功课项目记录
        final gongkeItems = await globalDB.managers.gongKeItem
            .filter((f) => f.fayuanId.equals(fayuan.id))
            .get();
        print(gongkeItems.length);
        if (gongkeItems.isNotEmpty) {
          // 计算完成率
          int completedCount = gongkeItems
              .where((item) => item.isComplete)
              .length;
          double completionRate = completedCount / gongkeItems.length;
          // 存储完成率
          _fayuanCompletionRates[fayuan.id] = completionRate;
        } else {
          // 如果没有功课记录，设置完成率为0
          _fayuanCompletionRates[fayuan.id] = 0.0;
        }
      }
      setState(() {
        fayuandatalist = result;
      });
    } catch (e) {
      print('查询所有记录时出错: $e');
    }
  }

  // 添加加载完成率的方法
  Future<void> _loadCompletionRates(DateTime month) async {
    // TODO: 从数据库加载当月的功课完成率
    _completionRates.clear();
    groupedRecords.clear();
    // 获取当月的第一天和最后一天
    DateTime firstDayOfMonth = DateTime(month.year, month.month, 1);
    DateTime lastDayOfMonth = DateTime(month.year, month.month + 1, 0);

    // 查询当月的所有功课记录
    final allItems = await globalDB.managers.gongKeItem
        .filter(
          (f) => f.gongKeDay.startsWith(
            '${firstDayOfMonth.year}-${firstDayOfMonth.month.toString().padLeft(2, '0')}-',
          ),
        )
        .get();

    for (var record in allItems) {
      String dateKey = record.gongKeDay;
      if (!groupedRecords.containsKey(dateKey)) {
        groupedRecords[dateKey] = [];
      }
      groupedRecords[dateKey]!.add(record);
    }

    // 计算每天的完成率
    groupedRecords.forEach((date, dayRecords) {
      int totalItems = dayRecords.length;
      int completedItems = dayRecords.where((item) => item.isComplete).length;
      double completionRate = totalItems > 0
          ? completedItems / totalItems
          : 0.0;
      _completionRates[date] = completionRate;
    });

    setState(() {});
  }

  // 修改：将方法移入类中并添加 lunar 参数
  String _getLunarDayText(Lunar lunar) {
    final festival = lunar.getFestivals();
    if (festival.isNotEmpty) {
      return festival.first;
    }

    final lunarDay = lunar.getDay();
    switch (lunarDay) {
      case 1:
        return '初一';
      case 2:
        return '初二';
      case 3:
        return '初三';
      case 4:
        return '初四';
      case 5:
        return '初五';
      case 6:
        return '初六';
      case 7:
        return '初七';
      case 8:
        return '初八';
      case 9:
        return '初九';
      case 10:
        return '初十';
      case 11:
        return '十一';
      case 12:
        return '十二';
      case 13:
        return '十三';
      case 14:
        return '十四';
      case 15:
        return '十五';
      case 16:
        return '十六';
      case 17:
        return '十七';
      case 18:
        return '十八';
      case 19:
        return '十九';
      case 20:
        return '二十';
      case 21:
        return '廿一';
      case 22:
        return '廿二';
      case 23:
        return '廿三';
      case 24:
        return '廿四';
      case 25:
        return '廿五';
      case 26:
        return '廿六';
      case 27:
        return '廿七';
      case 28:
        return '廿八';
      case 29:
        return '廿九';
      case 30:
        return '三十';
      default:
        return '未知';
    }
  }

  // 自定义日期单元格构建器
  Widget _buildCalendarCell(
    BuildContext context,
    DateTime day, // 当前日期，就是遍历到哪一天的日期，日期单元格
    DateTime focusedDay, // 当前聚焦的日期，如果用户选择了某年某月，那么就是聚焦的日期
  ) {
    final lunar = Lunar.fromDate(day);
    final dateString = DateTools.getStringByDate(day);
    final completion = _completionRates[dateString] ?? 0.0;
    final todayString = DateTools.getStringByDate(DateTime.now());
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/GongKeSetting',
          arguments: {
            'date': dateString,
            'groupedRecords': groupedRecords, // 通过引用传递 Map
            'updateCallback': () async {
              // 修改为 async
              // 等待数据更新完成
              await _refreshAllData();
              // 强制更新状态
              if (mounted) {
                setState(() {});
              }
            },
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 1,
          vertical: 2,
        ), // 减小水平边距，保持垂直边距
        padding: const EdgeInsets.all(2), // 添加内边距
        width: 45, // 让容器尽可能宽

        decoration: BoxDecoration(
          color: groupedRecords[dateString] == null
              ? Colors
                    .white // 有功课记录时背景为白色
              : (completion > 0 ? Colors.green : Colors.yellow), // 没有记录时背景为浅灰色
          // 添加背景颜色
          border: Border.all(
            color: dateString == todayString
                ? Colors.red
                : Colors.grey.shade200,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 阳历日期
            Text('${day.day}', style: const TextStyle(fontSize: 14)),
            // 完成度进度条
            if (completion >= 0)
              Text(
                '${(completion * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 10,
                  color: completion > 0 ? Colors.white : Colors.blue,
                ),
              ),
            // 农历日期
            Text(
              _getLunarDayText(lunar),
              style: TextStyle(
                fontSize: 10,
                // 节日显示红色
                color: lunar.getFestivals().isNotEmpty
                    ? Colors.red
                    : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _PercentChart(BuildContext context, double percent) {
    return SizedBox(
      height: 60,
      width: 60,
      child: SfCircularChart(
        margin: EdgeInsets.zero,
        annotations: [
          CircularChartAnnotation(
            widget: Text(
              '${(percent * 100).toStringAsFixed(0)}%',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
        series: <CircularSeries>[
          // 背景环
          DoughnutSeries<dynamic, dynamic>(
            dataSource: [1],
            pointColorMapper: (_, __) => Colors.grey.shade300,
            xValueMapper: (_, __) => '',
            yValueMapper: (_, __) => 100,
            radius: '100%',
            innerRadius: '80%', // 添加内半径
          ),
          // 进度环
          DoughnutSeries<dynamic, dynamic>(
            dataSource: [1],
            pointColorMapper: (_, __) => Theme.of(context).primaryColor,
            xValueMapper: (_, __) => '',
            yValueMapper: (_, __) => percent * 100,
            radius: '100%',
            innerRadius: '80%', // 添加内半径
            startAngle: 270, // 设置起始角度
            endAngle: 270, // 设置结束角度
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 发愿一览标题
            ListTile(
              title: const Text(
                '发愿一览',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/FaYuanWizard',
                    arguments: {'acttype': 'A'},
                  ).then((_) => _refreshAllData());
                },
              ),
            ),

            // 发愿列表
            StreamBuilder<List<FaYuanData>>(
              stream: fayuandatalist,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.data!.isEmpty) {
                  return const Center(child: Text('暂无发愿记录'));
                }

                return ListView.builder(
                  shrinkWrap: true, // 让ListView适应内容高度
                  physics:
                      const NeverScrollableScrollPhysics(), // 禁用ListView的滚动
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final fayuan = snapshot.data![index];
                    return Slidable(
                      startActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        children: [
                          SlidableAction(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            icon: Icons.edit,
                            label: '编辑',
                            onPressed: (context) {
                              Navigator.pushNamed(
                                context,
                                '/FaYuanWizard',
                                arguments: {
                                  'acttype': 'M',
                                  'fayuanId': fayuan.id,
                                },
                              ).then((_) => _refreshAllData());
                            },
                          ),
                          SlidableAction(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            icon: Icons.check_circle,
                            label: '修改发愿文',
                            onPressed: (context) {
                              Navigator.pushNamed(
                                context,
                                '/ModifyFaYuanWen',
                                arguments: {'fayuanId': fayuan.id},
                              );
                            },
                          ),
                        ],
                      ),
                      endActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        children: [
                          SlidableAction(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            label: '删除',
                            onPressed: (context) async {
                              bool confirm =
                                  await showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('确认删除'),
                                      content: const Text(
                                        '确定要删除这条发愿记录吗？相关的功课记录也会被删除。',
                                      ),
                                      actions: [
                                        TextButton(
                                          child: const Text('取消'),
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                        ),
                                        TextButton(
                                          child: const Text('确定'),
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                        ),
                                      ],
                                    ),
                                  ) ??
                                  false;

                              if (confirm) {
                                await globalDB.transaction(() async {
                                  // 删除关联的功课项目记录
                                  await (globalDB.delete(globalDB.gongKeItem)
                                        ..where(
                                          (t) => t.fayuanId.equals(fayuan.id),
                                        ))
                                      .go();
                                  // 删除关联的每日功课记录
                                  await (globalDB.delete(
                                        globalDB.gongKeItemsOneDay,
                                      )..where(
                                        (t) => t.fayuanId.equals(fayuan.id),
                                      ))
                                      .go();
                                  // 删除发愿记录
                                  await (globalDB.delete(
                                    globalDB.faYuan,
                                  )..where((t) => t.id.equals(fayuan.id))).go();
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      child: Card(
                        child: ListTile(
                          title: Row(
                            children: [
                              _PercentChart(
                                context,
                                _fayuanCompletionRates[fayuan.id] ?? 0.0,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '建:${DateTools.getDateStringByDate(fayuan.createDateTime)}\n'
                                '起:${DateTools.getDateStringByDate(fayuan.startDate)}\n'
                                '止:${DateTools.getDateStringByDate(fayuan.endDate)}',
                                style: TextStyle(fontSize: 10),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                fayuan.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/ModifyFaYuanWen',
                              arguments: {'fayuanId': fayuan.id},
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),

            // 功课一览标题
            Container(
              padding: const EdgeInsets.only(top: 8),
              child: ListTile(
                title: const Text(
                  '功课一览',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    Navigator.pushNamed(context, '/GongKeStat', arguments: {});
                  },
                ),
              ),
            ),

            // 这里添加日历组件
            Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 1,
                  ),
                ],
              ),
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                calendarFormat: CalendarFormat.month,
                availableCalendarFormats: const {CalendarFormat.month: '月'},
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                  _loadCompletionRates(focusedDay);
                },
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: _buildCalendarCell,
                  selectedBuilder: _buildCalendarCell,
                  todayBuilder: _buildCalendarCell,
                ),
                locale: 'zh_CN', // 设置中文区域
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
                calendarStyle: const CalendarStyle(
                  outsideDaysVisible: false, // 隐藏非当前月份的日期
                ),
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(color: Colors.black87),
                  weekendStyle: TextStyle(color: Colors.red),
                ),
                rowHeight: 60, // 增加行高，可以根据需要调整这个值
              ),
            ),
          ],
        ),
      ),
    );
  }
}
