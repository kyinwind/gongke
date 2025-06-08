import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});
  State<SettingPage> createState() => _SettingPageState();
}

final List<Map<String, String>> help_slides = [
  {
    'image': 'assets/help/01.jpg',
    'title': '首页',
    'description': '发愿功课，功课完成日历一目了然',
  },
  {
    'image': 'assets/help/02.jpg',
    'title': '发愿向导',
    'description': '跟随发愿向导，制定功课计划。',
  },
  {
    'image': 'assets/help/03.jpg',
    'title': '完成功课记录',
    'description': '点击日历日期，完成当天功课。',
  },
  {
    'image': 'assets/help/04.jpg',
    'title': '完成功课小工具-功课计数',
    'description': '对于念咒类功课，提供晃动手机计数功能，适合在外散步时做功课。',
  },
  {
    'image': 'assets/help/05.jpg',
    'title': '完成功课小工具-念佛计数',
    'description': '对于念佛类功课，提供电子木鱼功能',
  },
  {
    'image': 'assets/help/06.jpg',
    'title': '功课统计',
    'description': '可随时查看统计功课完成情况',
  },
  {
    'image': 'assets/help/07.jpg',
    'title': '藏经阁',
    'description': '40多部常用经书供持诵学习',
  },
  {
    'image': 'assets/help/08.jpg',
    'title': '大德开示',
    'description': '每天一句大德开示，勉励自己精进修行。',
  },
  {
    'image': 'assets/help/09.jpg',
    'title': '拜忏',
    'description': '根据自己体力和发愿，自定义人声引导拜忏，自净其意。',
  },
];
final List<Widget> imageSliders = help_slides
    .map(
      (item) => Container(
        child: Container(
          margin: EdgeInsets.all(5.0),
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
            child: Stack(
              children: <Widget>[
                Image.asset(item['image']!, fit: BoxFit.fill, height: 700),
                Positioned(
                  bottom: 0.0,
                  left: 0.0,
                  right: 0.0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color.fromARGB(200, 0, 0, 0),
                          Color.fromARGB(0, 0, 0, 0),
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: 10.0,
                      horizontal: 20.0,
                    ),
                    child: Text(
                      '${item['title']!}\n${item['description']!}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    )
    .toList();

class _SettingPageState extends State<SettingPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection(
                '意见反馈',
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '如有任何问题或建议，请发邮件给我，感谢您的反馈：',
                      textAlign: TextAlign.left, // ✅ 添加对齐
                    ),
                    SelectableText(
                      'yangxuehui@outlook.com',
                      style: TextStyle(color: Theme.of(context).primaryColor),
                      textAlign: TextAlign.left, // ✅ 添加对齐
                    ),
                    const SelectableText(
                      '技术支持网站: https://zhuanlan.zhihu.com/p/713033250',
                      textAlign: TextAlign.left,
                    ),
                    const SelectableText(
                      '技术支持qq:966451045',
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              _buildSection(
                '使用帮助',
                CarouselSlider(
                  options: CarouselOptions(
                    aspectRatio: 2.0,
                    enlargeCenterPage: true,
                    enlargeStrategy: CenterPageEnlargeStrategy.zoom,
                    enlargeFactor: 0.4,
                  ),
                  items: imageSliders,
                ),
              ),

              const SizedBox(height: 24),

              _buildSection(
                '关于',
                const Text(
                  '''  作者本人为了日常做学佛的功课，所以才起意制作了本app分享，希望也能帮到各位佛友。
  在此鸣谢下列单位、人员以及各个flutter组件的开发者（恕不能一一列出人名，仅列出使用的组件）:
  仁慧草堂:本app所提供的经书电子版、图片多数来自于仁慧草堂分享，少数来自于网络收集。
  syncfusion_flutter_charts
  syncfusion_flutter_calendar
  intl
  styled_widget
  sqlite3、sqlite3_flutter_libs
  drift
  path_provider
  path
  shared_preferences
  pdfx
  flutter_slidable
  image_picker
  flutter_image_compress
  table_calendar
  lunar
  sensors_plus
  flutter_svg
  audioplayers
  flutter_tts
  carousel_slider
  wakelock_plus...''',
                  textAlign: TextAlign.left, // ✅ 添加对齐
                ),
              ),

              const SizedBox(height: 24),

              _buildSection(
                '版本历史',
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    SizedBox(height: 8),
                    Text('v0.9.0 (2025-06-8)', textAlign: TextAlign.left), // ✅
                    Text('• 首次发布', textAlign: TextAlign.left), // ✅
                    SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        Align(alignment: Alignment.centerLeft, child: content),
      ],
    );
  }
}
