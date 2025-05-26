import 'package:flutter/material.dart';
import 'dart:io';
import 'page/gongke/gongke.dart';
import 'database.dart';
import 'page/songjing/songjing.dart';
import 'page/tips/Tip.dart';
import 'page/tips/AddTip.dart';
import 'page/tips/TipRecord.dart';
import 'page/tips/ImportTips.dart';
// 导入 path_provider 库以使用 getApplicationDocumentsDirectory 函数
import 'package:path_provider/path_provider.dart';

// 声明全局数据库变量
late AppDatabase globalDB; // 在main函数中创建单一实例;
void main() {
  globalDB = AppDatabase();
  final dbFolder = getApplicationDocumentsDirectory();

  runApp(MyApp(db: globalDB));
}

class MyApp extends StatefulWidget {
  final AppDatabase db; // 添加数据库字段

  const MyApp({super.key, required this.db}); // 修改构造函数

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    String fontFamily;
    if (Platform.isWindows) {
      fontFamily = 'SimSun';
    } else {
      fontFamily = 'Roboto';
    }
    return MaterialApp(
      // title: '功课助手',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        textTheme: TextTheme(
          bodyMedium: TextStyle(fontFamily: fontFamily),
        ).apply(fontFamily: fontFamily),
      ),
      home: TabbedHomePage(title: 'Flutter Demo Home Page'),
      // 添加路由配置
      routes: {
        '/addTip': (context) => const AddTipPage(),
        '/importTip': (context) => const ImportTipPage(),
        '/TipRecord': (context) => const AddTipRecordPage(),
      },
      initialRoute: '/',
    );
  }

  @override
  void dispose() {
    widget.db.close();
    super.dispose();
  }
}

class TabbedHomePage extends StatefulWidget {
  const TabbedHomePage({super.key, required this.title});
  final String title;
  @override
  State<TabbedHomePage> createState() => _TabbedHomePageState();
}

class _TabbedHomePageState extends State<TabbedHomePage> {
  int _selectedIndex = 0;
  static List<Widget> _widgetOptions() => <Widget>[
    GongKePage(),
    SongJingPage(),
    TipPage(), // 传入数据库实例
    Text('拜忏页面'),
    Text('设置页面'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _widgetOptions().elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.book), label: '功课'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: '诵经'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: '开示'),
          BottomNavigationBarItem(icon: Icon(Icons.announcement), label: '拜忏'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '设置'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 241, 214, 4),
        unselectedItemColor: Colors.grey,
        // 确保显示激活标签的文字
        showSelectedLabels: true,
        // 确保显示未激活标签的文字
        showUnselectedLabels: true,
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
