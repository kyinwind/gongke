import 'package:flutter/material.dart';
import 'package:gongke/main.dart';
import 'package:styled_widget/styled_widget.dart';
import '../../database.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter_slidable/flutter_slidable.dart'; // 导入 Slidable 库
import 'dart:convert'; // 导入 dart:convert 库，确保已导入
import 'package:flutter/services.dart';

// 为了让页面能够上下滑动，将 Scaffold 的 body 用 SingleChildScrollView 包裹
class TipPage extends StatefulWidget {
  const TipPage({super.key});

  @override
  State<TipPage> createState() => _TipPageState();
}

// 在 _TipPageState 类中添加数据库实例和记录列表
class _TipPageState extends State<TipPage> {
  Stream<List<TipBookData>> records = Stream.value([]);

  _TipPageState(); // 添加构造函数

  @override
  void initState() {
    super.initState();
    fetchTip();
    records.first.then((value) {
      if (value.isEmpty) {
        importTip();
        fetchTip();
      }
    });
  }

  Future<void> importTip() async {
    // 假设文件名为 广钦老和尚开示.json, 第二个文件.json, 第三个文件.json, 第四个文件.json
    final fileNames = ['1.json', '2.json', '3.json', '4.json'];

    // 开启事务
    await globalDB.transaction(() async {
      try {
        for (final fileName in fileNames) {
          final jsonString = await rootBundle.loadString(
            'assets/tips/$fileName',
          );
          final jsonData = json.decode(jsonString);

          // 提取 TipBook 数据
          final quotation = jsonData['quotation'];
          final tipBookCompanion = globalDB.tipBook.insertOne(
            TipBookCompanion.insert(
              name: quotation['name'],
              image: quotation['image'],
              remarks: quotation['remarks'],
              favoriteDateTime: const Value(null),
              createDateTime: Value(DateTime.now()),
            ),
          );

          // 插入 TipBook 记录并获取插入的 id
          // 由于 tipBookCompanion 是 Future<int> 类型，需要使用 await 来获取实际的 id 值
          final bookId = await tipBookCompanion;

          // 提取 TipRecord 数据
          final records = quotation['records'] as List<dynamic>;
          for (final recordData in records) {
            final tipRecordCompanion = TipRecordCompanion.insert(
              bookId: bookId,
              content: recordData['content'],
              remarks: '',
            );

            // 插入 TipRecord 记录
            await globalDB.tipRecord.insertOne(tipRecordCompanion);
          }
        }
      } catch (e) {
        // 出现错误，回滚事务
        print('导入数据时出错: $e');
        rethrow;
      }
    });
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
    super.dispose();
  }

  String? imagePath = 'assets/images/jingshu.png';
  // 设置为最爱
  void _setFavorite(TipBookData book) {
    setState(() {
      var favoriteDateTime = book.favoriteDateTime;
      if (book.favoriteDateTime != null) {
        favoriteDateTime = null; // 如果已经是最爱，则取消
      } else {
        favoriteDateTime = DateTime.now();
      }
      // 添加数据库更新逻辑
      globalDB.managers.tipBook
          .filter((f) => f.id(book.id))
          .update((o) => o(favoriteDateTime: Value(favoriteDateTime)));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '开示录',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        toolbarHeight: 40,
        actions: [
          Spacer(),
          IconButton(
            icon: const Icon(Icons.import_export),
            onPressed: () {
              // 跳转到导入页面
              Navigator.pushNamed(context, '/importTip');
            },
          ),
          Text('  '),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // 跳转到新增页面
              Navigator.pushNamed(
                context,
                '/addTip',
                arguments: {'acttype': 'new'},
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
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
                                '/addTip',
                                arguments: {'acttype': 'mod', 'id': record.id},
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
                                ? '设为最爱'
                                : '取消最爱',
                          ),
                        ],
                      ),
                      endActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (context) async {
                              // 在这里处理删除操作
                              await globalDB.managers.tipBook
                                  .filter((f) => f.id(record.id))
                                  .delete();
                              // 重新获取数据
                              await fetchTip();
                            },
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
                        leading: (record.image != null && record.image != '')
                            ? Image.memory(
                                const Base64Codec().decode(record.image),
                                height: 100,
                              )
                            : Image.asset(
                                'assets/images/jingshu.png',
                                height: 100,
                              ),
                        title: Text(record.name),
                        trailing: record.favoriteDateTime != null
                            ? Icon(Icons.favorite, color: Colors.yellow)
                            : const SizedBox(),
                      ).padding(all: 10),
                    );
                  },
                );
              },
            ),
            const Text(
              '预览',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ).padding(all: 15),
            Column(
              mainAxisAlignment: MainAxisAlignment.center, // 添加水平居中
              crossAxisAlignment: CrossAxisAlignment.center, //
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center, // 添加水平居中
                  crossAxisAlignment: CrossAxisAlignment.center, //
                  children: [
                    Image.asset(
                      'assets/images/jingshu.png',
                      height: 100,
                      fit: BoxFit.fitHeight, // 确保图片按高度适配
                    ).padding(all: 10),
                    const SizedBox(width: 10),
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
                    ),
                  ],
                ),
                const Text(
                  '今日开示录\n今日开示录今日开示录今日开示录今日开示录今日开示录今日开示录今日开示录今日开示录今日开示录今日开示录今日开示录今日开示录今日开示录今日开示录今日开示录今日开示录',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ).padding(all: 15),
          ],
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
