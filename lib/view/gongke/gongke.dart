import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:gongke/database.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
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

  @override
  void initState() {
    super.initState();
    fetchAll();
  }

  // 查询所有记录
  Future<void> fetchAll() async {
    try {
      final query = globalDB.managers.faYuan
          .filter(
            (f) =>
                f.startDate.isBeforeOrOn(DateTime.now()) &
                f.endDate.isAfterOrOn(DateTime.now()),
          )
          .orderBy((o) => o.createDateTime.desc());
      setState(() {
        fayuandatalist = query.watch();
      });
    } catch (e) {
      print('查询所有记录时出错: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
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
                );
              },
            ),
          ),
          Expanded(
            child: SlidableAutoCloseBehavior(
              child: StreamBuilder<List<FaYuanData>>(
                stream: fayuandatalist,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.data!.isEmpty) {
                    return const Center(child: Text('暂无发愿记录'));
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final fayuan = snapshot.data![index];
                      return Slidable(
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
                                        )..where((t) => t.id.equals(fayuan.id)))
                                        .go();
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
                                SizedBox(
                                  height: 60,
                                  width: 60,
                                  child: SfCircularChart(
                                    margin: EdgeInsets.zero,
                                    annotations: [
                                      CircularChartAnnotation(
                                        widget: Text(
                                          '${((DateTime.now().difference(fayuan.startDate).inDays / fayuan.endDate.difference(fayuan.startDate).inDays) * 100).toStringAsFixed(0)}%',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    ],
                                    series: <CircularSeries>[
                                      DoughnutSeries<dynamic, dynamic>(
                                        dataSource: [1],
                                        pointColorMapper: (_, __) =>
                                            Colors.grey.shade300,
                                        xValueMapper: (_, __) => '',
                                        yValueMapper: (_, __) => 100,
                                        radius: '100%',
                                      ),
                                      DoughnutSeries<dynamic, dynamic>(
                                        dataSource: [1],
                                        pointColorMapper: (_, __) =>
                                            Theme.of(context).primaryColor,
                                        xValueMapper: (_, __) => '',
                                        yValueMapper: (_, __) =>
                                            (DateTime.now()
                                                    .difference(
                                                      fayuan.startDate,
                                                    )
                                                    .inDays /
                                                fayuan.endDate
                                                    .difference(
                                                      fayuan.startDate,
                                                    )
                                                    .inDays) *
                                            100,
                                        radius: '100%',
                                      ),
                                    ],
                                  ),
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
                                '/FaYuanWizard',
                                arguments: {
                                  'acttype': 'M',
                                  'fayuanId': fayuan.id,
                                },
                              );
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
