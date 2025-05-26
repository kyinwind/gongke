import 'package:flutter/material.dart';
import 'package:drift/drift.dart';
import 'package:gongke/main.dart';
import '../../database.dart';

// 假设这是一个StatefulWidget页面
class AddTipRecordPage extends StatefulWidget {
  const AddTipRecordPage({Key? key}) : super(key: key);

  @override
  _AddTipRecordPageState createState() => _AddTipRecordPageState();
}

class _AddTipRecordPageState extends State<AddTipRecordPage> {
  Stream<List<TipRecordData>> tipRecords = Stream.value([]);
  int bookId = 0; // 默认值，实际使用时可能需要从路由参数获取

  @override
  void initState() {
    super.initState();
    if (bookId > 0) {
      _loadTipRecords(bookId);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic> && args['bookId'] != null) {
      bookId = args['bookId'];
      _loadTipRecords(bookId);
    }
    print('Book ID: $bookId');
  }

  Future<void> _loadTipRecords(int bookId) async {
    final query = globalDB.managers.tipRecord;
    query.orderBy((o) => o.id.asc());
    query.filter((f) => f.bookId.equals(bookId));
    final records = await query.watch();
    setState(() {
      tipRecords = records;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('提示记录'),
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
      body: StreamBuilder<List<TipRecordData>>(
        stream: tipRecords,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final records = snapshot.data ?? [];
            return ListView.builder(
              itemCount: records.length,
              itemBuilder: (context, index) {
                final record = records[index];
                return ListTile(
                  title: Text(record.id.toString()),
                  subtitle: Text(record.content),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Text('错误: ${snapshot.error}');
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
