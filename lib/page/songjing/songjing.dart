import 'package:flutter/material.dart';
import 'package:gongke/database.dart';
import 'package:styled_widget/styled_widget.dart';
import '../../comm/pdfview.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gongke/main.dart';
import 'package:drift/drift.dart' hide Column;

class SongJingPage extends StatefulWidget {
  @override
  _SongJingPageState createState() => _SongJingPageState();
}

class _SongJingPageState extends State<SongJingPage> {
  TextEditingController _searchController = TextEditingController();
  Stream<List<JingShuData>> jingshudatalist = Stream.value([]);
  String? imagePath = 'assets/images/jingshu.png';

  @override
  void initState() {
    super.initState();
    fetchAll();
    // 检查 jingshudatalist 是否为空，如果为空则插入三条记录
    jingshudatalist.first.then((list) {
      if (list.isEmpty) {
        globalDB.managers.jingShu.bulkCreate(
          (o) => [
            o(
              name: '《一切如来心秘密全身舍利宝箧印陀罗尼经》',
              image: imagePath!,
              fileUrl: '1.pdf',
              fileType: 'pdf',
              type: 'jingshu',
              remarks: '《一切如来心秘密全身舍利宝箧印陀罗尼经》',
              favoriteDateTime: Value(null),
              createDateTime: Value(DateTime.now()),
            ),
            o(
              name: '《三劫三千佛名经》',
              image: imagePath!,
              fileUrl: '2.pdf',
              fileType: 'pdf',
              type: 'jingshu',
              remarks: '《三劫三千佛名经》',
              favoriteDateTime: Value(null),
              createDateTime: Value(DateTime.now()),
            ),
            o(
              name: '《佛教念诵集》（暮时课诵）',
              image: imagePath!,
              fileUrl: '3.pdf',
              fileType: 'pdf',
              type: 'jingshu',
              remarks: '《佛教念诵集》（暮时课诵）',
              favoriteDateTime: Value(null),
              createDateTime: Value(DateTime.now()),
            ),
            o(
              name: '《佛教念诵集》（朝时课诵）',
              image: imagePath!,
              fileUrl: '4.pdf',
              fileType: 'pdf',
              type: 'jingshu',
              remarks: '《佛教念诵集》（朝时课诵）',
              favoriteDateTime: Value(null),
              createDateTime: Value(DateTime.now()),
            ),
            o(
              name: '《佛说七俱胝佛母心大准提陀罗尼经》',
              image: imagePath!,
              fileUrl: '5.pdf',
              fileType: 'pdf',
              type: 'jingshu',
              remarks: '《佛说七俱胝佛母心大准提陀罗尼经》',
              favoriteDateTime: Value(null),
              createDateTime: Value(DateTime.now()),
            ),
            o(
              name: '《佛说四十二章经》',
              image: imagePath!,
              fileUrl: '6.pdf',
              fileType: 'pdf',
              type: 'jingshu',
              remarks: '《佛说四十二章经》',
              favoriteDateTime: Value(null),
              createDateTime: Value(DateTime.now()),
            ),
            o(
              name: '《佛说无量寿经》',
              image: imagePath!,
              fileUrl: '7.pdf',
              fileType: 'pdf',
              type: 'jingshu',
              remarks: '《佛说无量寿经》',
              favoriteDateTime: Value(null),
              createDateTime: Value(DateTime.now()),
            ),
            o(
              name: '《佛说父母恩难报经》',
              image: imagePath!,
              fileUrl: '8.pdf',
              fileType: 'pdf',
              type: 'jingshu',
              remarks: '《佛说父母恩难报经》',
              favoriteDateTime: Value(null),
              createDateTime: Value(DateTime.now()),
            ),
            o(
              name: '《佛说疗痔病经》',
              image: imagePath!,
              fileUrl: '9.pdf',
              fileType: 'pdf',
              type: 'jingshu',
              remarks: '《佛说疗痔病经》',
              favoriteDateTime: Value(null),
              createDateTime: Value(DateTime.now()),
            ),
            o(
              name: '《佛说盂兰盆经》',
              image: imagePath!,
              fileUrl: '10.pdf',
              fileType: 'pdf',
              type: 'jingshu',
              remarks: '《佛说盂兰盆经》',
              favoriteDateTime: Value(null),
              createDateTime: Value(DateTime.now()),
            ),
            o(
              name: '《佛说观弥勒菩萨上生兜率陀天经》',
              image: imagePath!,
              fileUrl: '11.pdf',
              fileType: 'pdf',
              type: 'jingshu',
              remarks: '《佛说观弥勒菩萨上生兜率陀天经》',
              favoriteDateTime: Value(null),
              createDateTime: Value(DateTime.now()),
            ),
            o(
              name: '《佛说观弥勒菩萨下生经》',
              image: imagePath!,
              fileUrl: '12.pdf',
              fileType: 'pdf',
              type: 'jingshu',
              remarks: '《佛说观弥勒菩萨下生经》',
              favoriteDateTime: Value(null),
              createDateTime: Value(DateTime.now()),
            ),
            o(
              name: '《佛说阿弥陀经要解》',
              image: imagePath!,
              fileUrl: '13.pdf',
              fileType: 'pdf',
              type: 'jingshu',
              remarks: '《佛说阿弥陀经要解》',
              favoriteDateTime: Value(null),
              createDateTime: Value(DateTime.now()),
            ),
            o(
              name: '《僧伽吒经》',
              image: imagePath!,
              fileUrl: '14.pdf',
              fileType: 'pdf',
              type: 'jingshu',
              remarks: '《僧伽吒经》',
              favoriteDateTime: Value(null),
              createDateTime: Value(DateTime.now()),
            ),
            o(
              name: '《六祖大师法宝坛经》',
              image: imagePath!,
              fileUrl: '15.pdf',
              fileType: 'pdf',
              type: 'jingshu',
              remarks: '《六祖大师法宝坛经》',
              favoriteDateTime: Value(null),
              createDateTime: Value(DateTime.now()),
            ),
            o(
              name: '《净土五经》',
              image: imagePath!,
              fileUrl: '16.pdf',
              fileType: 'pdf',
              type: 'jingshu',
              remarks: '《净土五经》',
              favoriteDateTime: Value(null),
              createDateTime: Value(DateTime.now()),
            ),
            o(
              name: '《千手千眼观世音菩萨广大圆满无碍大悲心陀罗尼经》',
              image: imagePath!,
              fileUrl: '17.pdf',
              fileType: 'pdf',
              type: 'jingshu',
              remarks: '《千手千眼观世音菩萨广大圆满无碍大悲心陀罗尼经》',
              favoriteDateTime: Value(null),
              createDateTime: Value(DateTime.now()),
            ),
            o(
              name: '《大乘入楞伽经》',
              image: imagePath!,
              fileUrl: '18.pdf',
              fileType: 'pdf',
              type: 'jingshu',
              remarks: '《大乘入楞伽经》',
              favoriteDateTime: Value(null),
              createDateTime: Value(DateTime.now()),
            ),
            o(
              name: '《大佛顶首楞严神咒》',
              image: imagePath!,
              fileUrl: '19.pdf',
              fileType: 'pdf',
              type: 'jingshu',
              remarks: '《大佛顶首楞严神咒》',
              favoriteDateTime: Value(null),
              createDateTime: Value(DateTime.now()),
            ),
            o(
              name: '《大佛顶首楞严经》',
              image: imagePath!,
              fileUrl: '20.pdf',
              fileType: 'pdf',
              type: 'jingshu',
              remarks: '《大佛顶首楞严经》',
              favoriteDateTime: Value(null),
              createDateTime: Value(DateTime.now()),
            ),
            o(
              name: '《大佛顶首楞严经浅释》宣化上人',
              image: imagePath!,
              fileUrl: '21.pdf',
              fileType: 'pdf',
              type: 'jingshu',
              remarks: '《大佛顶首楞严经浅释》宣化上人',
              favoriteDateTime: Value(null),
              createDateTime: Value(DateTime.now()),
            ),
            o(
              name: '《大悲咒》（84句）',
              image: imagePath!,
              fileUrl: '22.pdf',
              fileType: 'pdf',
              type: 'jingshu',
              remarks: '《大悲咒》（84句）',
              favoriteDateTime: Value(null),
              createDateTime: Value(DateTime.now()),
            ),
            o(
              name: '《大方广佛华严经普贤菩萨行愿品》',
              image: imagePath!,
              fileUrl: '23.pdf',
              fileType: 'pdf',
              type: 'jingshu',
              remarks: '《大方广佛华严经普贤菩萨行愿品》',
              favoriteDateTime: Value(null),
              createDateTime: Value(DateTime.now()),
            ),
            o(
              name: '《大方广圆觉修多罗了义经》',
              image: imagePath!,
              fileUrl: '24.pdf',
              fileType: 'pdf',
              type: 'jingshu',
              remarks: '《大方广圆觉修多罗了义经》',
              favoriteDateTime: Value(null),
              createDateTime: Value(DateTime.now()),
            ),
            o(
              name: '《妙法莲华经》',
              image: imagePath!,
              fileUrl: '25.pdf',
              fileType: 'pdf',
              type: 'jingshu',
              remarks: '《妙法莲华经》',
              favoriteDateTime: Value(null),
              createDateTime: Value(DateTime.now()),
            ),
            o(
              name: '《慈悲药师宝忏》',
              image: imagePath!,
              fileUrl: '26.pdf',
              fileType: 'pdf',
              type: 'jingshu',
              remarks: '《慈悲药师宝忏》',
              favoriteDateTime: Value(null),
              createDateTime: Value(DateTime.now()),
            ),
            o(
              name: '《慈悲道场忏法》',
              image: imagePath!,
              fileUrl: '27.pdf',
              fileType: 'pdf',
              type: 'jingshu',
              remarks: '《慈悲道场忏法》',
              favoriteDateTime: Value(null),
              createDateTime: Value(DateTime.now()),
            ),
            o(
              name: '《梵网经菩萨戒本》诵戒专用',
              image: imagePath!,
              fileUrl: '28.pdf',
              fileType: 'pdf',
              type: 'jingshu',
              remarks: '《梵网经菩萨戒本》诵戒专用',
              favoriteDateTime: Value(null),
              createDateTime: Value(DateTime.now()),
            ),
            o(
              name: '《礼佛大忏悔文》',
              image: imagePath!,
              fileUrl: '29.pdf',
              fileType: 'pdf',
              type: 'jingshu',
              remarks: '《礼佛大忏悔文》',
              favoriteDateTime: Value(null),
              createDateTime: Value(DateTime.now()),
            ),
            o(
              name: '《维摩诘所说经》',
              image: imagePath!,
              fileUrl: '30.pdf',
              fileType: 'pdf',
              type: 'jingshu',
              remarks: '《维摩诘所说经》',
              favoriteDateTime: Value(null),
              createDateTime: Value(DateTime.now()),
            ),
            o(
              name: '《药师琉璃光如来本愿功德经》',
              image: imagePath!,
              fileUrl: '31.pdf',
              fileType: 'pdf',
              type: 'jingshu',
              remarks: '《药师琉璃光如来本愿功德经》',
              favoriteDateTime: Value(null),
              createDateTime: Value(DateTime.now()),
            ),
            o(
              name: '《虚空藏菩萨经》',
              image: imagePath!,
              fileUrl: '32.pdf',
              fileType: 'pdf',
              type: 'jingshu',
              remarks: '《虚空藏菩萨经》',
              favoriteDateTime: Value(null),
              createDateTime: Value(DateTime.now()),
            ),
            o(
              name: '《观世音菩萨普门品》',
              image: imagePath!,
              fileUrl: '33.pdf',
              fileType: 'pdf',
              type: 'jingshu',
              remarks: '《观世音菩萨普门品》',
              favoriteDateTime: Value(null),
              createDateTime: Value(DateTime.now()),
            ),
            o(
              name: '《观世音菩萨耳根圆通章》',
              image: imagePath!,
              fileUrl: '34.pdf',
              fileType: 'pdf',
              type: 'jingshu',
              remarks: '《观世音菩萨耳根圆通章》',
              favoriteDateTime: Value(null),
              createDateTime: Value(DateTime.now()),
            ),
            o(
              name: '《解深密经》',
              image: imagePath!,
              fileUrl: '35.pdf',
              fileType: 'pdf',
              type: 'jingshu',
              remarks: '《解深密经》',
              favoriteDateTime: Value(null),
              createDateTime: Value(DateTime.now()),
            ),
            o(
              name: '《达磨大师血脉论》',
              image: imagePath!,
              fileUrl: '36.pdf',
              fileType: 'pdf',
              type: 'jingshu',
              remarks: '《达磨大师血脉论》',
              favoriteDateTime: Value(null),
              createDateTime: Value(DateTime.now()),
            ),
            o(
              name: '《金光明经》',
              image: imagePath!,
              fileUrl: '37.pdf',
              fileType: 'pdf',
              type: 'jingshu',
              remarks: '《金光明经》',
              favoriteDateTime: Value(null),
              createDateTime: Value(DateTime.now()),
            ),
            o(
              name: '《金刚般若波罗蜜经》',
              image: imagePath!,
              fileUrl: '38.pdf',
              fileType: 'pdf',
              type: 'jingshu',
              remarks: '《金刚般若波罗蜜经》',
              favoriteDateTime: Value(null),
              createDateTime: Value(DateTime.now()),
            ),
            o(
              name: '地藏三经《占察善恶业报经》',
              image: imagePath!,
              fileUrl: '39.pdf',
              fileType: 'pdf',
              type: 'jingshu',
              remarks: '地藏三经《占察善恶业报经》',
              favoriteDateTime: Value(null),
              createDateTime: Value(DateTime.now()),
            ),
            o(
              name: '地藏三经《地藏菩萨本愿经》',
              image: imagePath!,
              fileUrl: '40.pdf',
              fileType: 'pdf',
              type: 'jingshu',
              remarks: '地藏三经《地藏菩萨本愿经》',
              favoriteDateTime: Value(null),
              createDateTime: Value(DateTime.now()),
            ),
            o(
              name: '地藏三经《地藏菩萨本愿经》（仿瓷版）',
              image: imagePath!,
              fileUrl: '41.pdf',
              fileType: 'pdf',
              type: 'jingshu',
              remarks: '地藏三经《地藏菩萨本愿经》（仿瓷版）',
              favoriteDateTime: Value(null),
              createDateTime: Value(DateTime.now()),
            ),
            o(
              name: '地藏三经《大乘大集地藏十轮经》',
              image: imagePath!,
              fileUrl: '42.pdf',
              fileType: 'pdf',
              type: 'jingshu',
              remarks: '地藏三经《大乘大集地藏十轮经》',
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
      final query = globalDB.managers.jingShu.orderBy(
        (t) => t.favoriteDateTime.desc() & t.createDateTime.desc(),
      );
      final list = query.watch(); // 获取所有记录
      setState(() {
        jingshudatalist = list;
      });
    } catch (e) {
      print('查询所有记录时出错: $e');
      // 可以在这里设置一个空的 Stream 或者错误提示的 Stream
      setState(() {
        jingshudatalist = Stream.error(e);
      });
    }
  }

  // 查询所有记录
  Future<void> fetchByWords(String str) async {
    try {
      final query = globalDB.managers.jingShu
          .orderBy((t) => t.favoriteDateTime.desc() & t.createDateTime.desc())
          .filter((f) => f.name.contains(str.trim()));
      final list = query.watch(); // 获取所有记录
      setState(() {
        jingshudatalist = list;
      });
    } catch (e) {
      print('根据关键字查询记录时出错: $e');
      // 可以在这里设置一个空的 Stream 或者错误提示的 Stream
      setState(() {
        jingshudatalist = Stream.error(e);
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
  void _navigateToPdfView(String pdfName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfViewerPage(pdfFileName: pdfName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: '输入关键字搜索经书',
            border: InputBorder.none,
          ),
          onChanged: (value) {
            fetchByWords(value);
          },
        ),
      ),
      body: SlidableAutoCloseBehavior(
        child: StreamBuilder<List<JingShuData>>(
          stream: jingshudatalist,
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
                                list[index].favoriteDateTime != null
                                    ? '已设为最爱'
                                    : '已取消最爱',
                              ),
                            ),
                          );
                        },
                        backgroundColor: Colors.yellow,
                        foregroundColor: Colors.white,
                        icon: Icons.favorite,
                        label: list[index].favoriteDateTime != null
                            ? '取消'
                            : '设为最爱',
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
                    title: Text(list[index].name),
                    trailing: list[index].favoriteDateTime != null
                        ? Icon(Icons.favorite, color: Colors.yellow)
                        : null,
                    onTap: () {
                      _navigateToPdfView(list[index].fileUrl);
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
