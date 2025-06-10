import 'package:flutter/material.dart';
import 'package:gongke/database.dart';
import 'package:styled_widget/styled_widget.dart';
import '../../comm/pdf_view.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gongke/main.dart';
import 'package:drift/drift.dart' hide Column;

class ShanShuPage extends StatefulWidget {
  const ShanShuPage({super.key});

  @override
  _ShanShuPageState createState() => _ShanShuPageState();
}

class _ShanShuPageState extends State<ShanShuPage> {
  final TextEditingController _searchController = TextEditingController();
  Stream<List<JingShuData>> shanshudatalist = Stream.value([]);
  String? imagePath = 'assets/images/jingshu.png';

  @override
  void initState() {
    super.initState();
    fetchAll();
    // 检查 shanshudatalist 是否为空，如果为空则插入三条记录
    shanshudatalist.first.then((list) {
      if (list.isEmpty) {
        globalDB.managers.jingShu.bulkCreate(
          (o) => [
            o(
              name: '《大佛顶首楞严经浅释》宣化上人',
              image: 'assets/images/lengyanjingqianshi.jpeg',
              fileUrl: '10000.pdf',
              fileType: 'pdf',
              type: 'shanshu',
              remarks: Value('《大佛顶首楞严经浅释》宣化上人'),
              favoriteDateTime: Value(null),
              createDateTime: Value(DateTime.now()),
            ),
            o(
              name: '广钦老和尚事迹-开示录',
              image: 'assets/images/guangqinlaoheshang.jpg',
              fileUrl: '10001.pdf',
              fileType: 'pdf',
              type: 'shanshu',
              remarks: Value('广钦老和尚事迹-开示录'),
              favoriteDateTime: Value(null),
              createDateTime: Value(DateTime.now()),
            ),
            o(
              name: '宽净法师-西方极乐世界游记',
              image: 'assets/images/kuanjingfashi.png',
              fileUrl: '10002.pdf',
              fileType: 'pdf',
              type: 'shanshu',
              remarks: Value('宽净法师-西方极乐世界游记'),
              favoriteDateTime: Value(null),
              createDateTime: Value(DateTime.now()),
            ),
            o(
              name: '倓虚法师-影尘回忆录',
              image: 'assets/images/tanxufashi.jpg',
              fileUrl: '10003.pdf',
              fileType: 'pdf',
              type: 'shanshu',
              remarks: Value('倓虚法师-影尘回忆录'),
              favoriteDateTime: Value(null),
              createDateTime: Value(DateTime.now()),
            ),
            o(
              name: '黄念祖居士点滴开示',
              image: 'assets/images/huangnianzhujushi.jpeg',
              fileUrl: '10004.pdf',
              fileType: 'pdf',
              type: 'shanshu',
              remarks: Value('黄念祖居士点滴开示'),
              favoriteDateTime: Value(null),
              createDateTime: Value(DateTime.now()),
            ),
            o(
              name: '果卿居士-现代因果实录(一)',
              image: 'assets/images/xiandaiiynguoshilu.jpeg',
              fileUrl: '10005.pdf',
              fileType: 'pdf',
              type: 'shanshu',
              remarks: Value('果卿居士-现代因果实录(一)'),
              favoriteDateTime: Value(null),
              createDateTime: Value(DateTime.now()),
            ),
            o(
              name: '果卿居士-现代因果实录(二)',
              image: 'assets/images/xiandaiiynguoshilu.jpeg',
              fileUrl: '10006.pdf',
              fileType: 'pdf',
              type: 'shanshu',
              remarks: Value('果卿居士-现代因果实录(二)'),
              favoriteDateTime: Value(null),
              createDateTime: Value(DateTime.now()),
            ),
            o(
              name: '果卿居士-现代因果实录(三)',
              image: 'assets/images/xiandaiiynguoshilu.jpeg',
              fileUrl: '10007.pdf',
              fileType: 'pdf',
              type: 'shanshu',
              remarks: Value('果卿居士-现代因果实录(三)'),
              favoriteDateTime: Value(null),
              createDateTime: Value(DateTime.now()),
            ),
            o(
              name: '了凡四训',
              image: 'assets/images/liaofansixun.jpg',
              fileUrl: '10008.pdf',
              fileType: 'pdf',
              type: 'shanshu',
              remarks: Value('了凡四训'),
              favoriteDateTime: Value(null),
              createDateTime: Value(DateTime.now()),
            ),
            o(
              name: '于凌波居士-向知识分子介绍佛教',
              image: 'assets/images/jieshaofojiao.jpeg',
              fileUrl: '10009.pdf',
              fileType: 'pdf',
              type: 'shanshu',
              remarks: Value('于凌波居士-向知识分子介绍佛教'),
              favoriteDateTime: Value(null),
              createDateTime: Value(DateTime.now()),
            ),
          ],
        );
        fetchAll(); // 插入数据后重新获取所有记录
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  // 查询所有记录
  Future<void> fetchAll() async {
    try {
      final query = globalDB.managers.jingShu
          .filter((f) => f.type.equals('shanshu'))
          .orderBy((t) => t.favoriteDateTime.desc() & t.createDateTime.desc());
      final list = query.watch(); // 获取所有记录
      setState(() {
        shanshudatalist = list;
      });
    } catch (e) {
      print('查询所有记录时出错: $e');
      // 可以在这里设置一个空的 Stream 或者错误提示的 Stream
      setState(() {
        shanshudatalist = Stream.error(e);
      });
    }
  }

  // 查询所有记录
  Future<void> fetchByWords(String str) async {
    try {
      final query = globalDB.managers.jingShu
          .orderBy((t) => t.favoriteDateTime.desc() & t.createDateTime.desc())
          .filter(
            (f) => f.name.contains(str.trim()) & f.type.equals('shanshu'),
          );
      final list = query.watch(); // 获取所有记录
      setState(() {
        shanshudatalist = list;
      });
    } catch (e) {
      // print('根据关键字查询记录时出错: $e');
      // 可以在这里设置一个空的 Stream 或者错误提示的 Stream
      setState(() {
        shanshudatalist = Stream.error(e);
      });
    }
  }

  // 设置为最爱
  void _setFavorite(JingShuData jingshu) {
    setState(() {
      var favoriteDateTime = jingshu.favoriteDateTime;
      if (jingshu.favoriteDateTime != null) {
        favoriteDateTime = null; // 如果已经是最爱，则取消
      } else {
        favoriteDateTime = DateTime.now();
      }
      // 添加数据库更新逻辑
      globalDB.managers.jingShu
          .filter((f) => f.id(jingshu.id))
          .update((o) => o(favoriteDateTime: Value(favoriteDateTime)));
    });
  }

  // 跳转到PDF页面
  Future<void> _navigateToPdfView(String pdfName, int id) async {
    final int? selectedPage = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfViewerPage(pdfFileName: pdfName),
      ),
    );
    // 处理返回的页码（用户点击返回按钮时 selectedPage 可能为 null）
    if (selectedPage != null) {
      globalDB.managers.jingShu
          .filter((f) => f.id(id))
          .update((o) => o(curPageNum: Value(selectedPage)));
    }
  }

  Widget showPageNumText(JingShuData shanshu) {
    final pageNum = shanshu.curPageNum;
    return Text(
      pageNum != null && pageNum > 0 ? '已读至第${pageNum.toInt()}页' : '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: '输入关键字搜索善书',
            border: InputBorder.none,
          ),
          onChanged: (value) {
            fetchByWords(value);
          },
        ),
      ),
      body: SlidableAutoCloseBehavior(
        child: StreamBuilder<List<JingShuData>>(
          stream: shanshudatalist,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('数据加载出错: ${snapshot.error}'));
            }
            final list = snapshot.data ?? [];
            return ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, index) {
                return Slidable(
                  startActionPane: ActionPane(
                    motion: const DrawerMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) {
                          _setFavorite(list[index]);
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                list[index].favoriteDateTime == null
                                    ? '已设为最爱'
                                    : '已取消最爱',
                              ),
                            ),
                          );
                        },
                        backgroundColor: Colors.white,
                        foregroundColor: Color.fromARGB(255, 226, 203, 50),
                        icon: Icons.favorite,
                        label: list[index].favoriteDateTime != null
                            ? '取消'
                            : '最爱',
                      ),
                    ],
                  ),
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) async {
                          // 在这里处理删除操作
                          await globalDB.managers.jingShu
                              .filter((f) => f.id(list[index].id))
                              .delete();
                          // 重新获取数据
                          await fetchAll();
                        },
                        backgroundColor: Color(0xFFFE4A49),
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: '删除',
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: Image.asset(list[index].image),
                    title: Row(
                      children: [Expanded(child: Text(list[index].name))],
                    ),
                    subtitle: Row(
                      children: [
                        if (list[index].favoriteDateTime != null)
                          const Icon(Icons.favorite, color: Colors.yellow)
                        else
                          const SizedBox.shrink(),
                        showPageNumText(list[index]),
                      ],
                    ),
                    onTap: () {
                      _navigateToPdfView(list[index].fileUrl, list[index].id);
                    },
                  ).padding(all: 10),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
