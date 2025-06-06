import 'package:flutter/material.dart';
import 'package:gongke/model/tables.dart';
import 'package:drift/drift.dart' hide Column;
import 'new_bai_chan.dart';
import 'bai_chan_play.dart';
import '../../database.dart';
import '../../main.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'bai_chan_play.dart';
import 'package:styled_widget/styled_widget.dart';

class BaiChanListPage extends StatefulWidget {
  @override
  _BaiChanListPageState createState() => _BaiChanListPageState();
}

class _BaiChanListPageState extends State<BaiChanListPage> {
  Stream<List<BaiChanData>> baiChanList = Stream.value([]);

  bool isRefresh = false;

  @override
  void initState() {
    super.initState();
    loadAllData();
  }

  // 设置为最爱
  void _setFavorite(BaiChanData baichan) {
    setState(() {
      var favoriteDateTime = baichan.favoriteDateTime;
      if (baichan.favoriteDateTime != null) {
        favoriteDateTime = null; // 如果已经是最爱，则取消
      } else {
        favoriteDateTime = DateTime.now();
      }
      // 添加数据库更新逻辑
      globalDB.managers.baiChan
          .filter((f) => f.id(baichan.id))
          .update((o) => o(favoriteDateTime: Value(favoriteDateTime)));
    });
  }

  Future<void> loadAllData() async {
    baiChanList = globalDB.managers.baiChan.watch();
  }

  void deleteBaiChan(int id) {
    setState(() {
      globalDB.managers.baiChan.filter((f) => f.id.equals(id)).delete();
    });
  }

  void setFavorite(int id) {
    setState(() {
      globalDB.managers.baiChan
          .filter((f) => f.id.equals(id))
          .update((o) => o(favoriteDateTime: Value(DateTime.now())));
    });
  }

  // 跳转到PDF页面
  void _navigateToPlay(BaiChanData baichan) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BaiChanPlayPage(baichan: baichan),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('拜忏'),
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewBaiChanPage(
                    baichan: BaiChanCompanion(),
                    actType: 'new',
                  ),
                ),
              );
            },
          ),
        ],
      ),

      body: SlidableAutoCloseBehavior(
        child: StreamBuilder<List<BaiChanData>>(
          stream: baiChanList,
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
                          await globalDB.managers.baiChan
                              .filter((f) => f.id(list[index].id))
                              .delete();
                          // 重新获取数据
                          await loadAllData();
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
                        //Spacer(),
                      ],
                    ),
                    onTap: () {
                      _navigateToPlay(list[index]);
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
