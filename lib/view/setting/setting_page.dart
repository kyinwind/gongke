import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  List<String> helpimagelist = [];

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
                    height: 200,
                    enableInfiniteScroll: false,
                    viewportFraction: 0.8,
                  ),
                  items: List.generate(
                    10,
                    (index) => Card(
                      child: Align(
                        alignment: Alignment.centerLeft, // ✅ 左对齐
                        child: Image.asset(
                          'assets/help/${(index + 1).toString().padLeft(2, '0')}.jpg',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
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
  carousel_slider...                
                ''',
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
                    Text('v1.0.0 (2025-06-10)', textAlign: TextAlign.left), // ✅
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
