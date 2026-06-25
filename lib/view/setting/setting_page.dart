import 'dart:io';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:gongke/comm/pub_tools.dart';
import '../../comm/shared_preferences.dart';
import 'package:toastification/toastification.dart';
import 'package:url_launcher/url_launcher.dart';
import '../help/help_center_page.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});
  @override
  State<SettingPage> createState() => _SettingPageState();
}

const double picheight = 400;

final help_sllides = Platform.isWindows
    ? help_slides_windows
    : help_slides_android;

final List<Widget> imageSliders = help_sllides
    .map(
      (item) => Container(
        margin: const EdgeInsets.all(8.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.yellow,
                    width: 1,
                  ), // 黄色边框，宽度为3
                ),
                child: SizedBox(
                  height: picheight,
                  child: Image.asset(
                    item['image']!,
                    fit: BoxFit.contain,
                    height: picheight,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                item['title'] ?? '',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 3),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  item['description'] ?? '',
                  style: const TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    )
    .toList();

class _SettingPageState extends State<SettingPage> {
  bool _allowWakelock = false;
  @override
  void initState() {
    super.initState();

    getBoolValue('allow_wakelock_flag').then((value) {
      setState(() {
        _allowWakelock = value ?? false;
      });
    });
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
              // 1. 帮助中心入口
              _buildSection(
                '帮助中心',
                Row(
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.help_outline),
                      label: const Text('打开帮助中心'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const GongKeHelpCenterPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const HelpBadgeIcon(),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 2. App 概览（原使用帮助轮播图）
              _buildSection(
                'App 概览',
                CarouselSlider(
                  options: CarouselOptions(
                    height: picheight + 150,
                    enlargeCenterPage: true,
                    enlargeStrategy: CenterPageEnlargeStrategy.zoom,
                    enlargeFactor: 0.3,
                  ),
                  items: imageSliders,
                ),
              ),

              const SizedBox(height: 24),

              // 3. 关于
              _buildSection(
                '关于',
                const Text(
                  '''  作者本人为了日常做学佛的功课，所以才起意制作了本app分享，希望也能帮到各位佛友。
  在此鸣谢下列单位、人员以及各个flutter组件的开发者（恕不能一一列出人名，仅列出使用的组件）:
  仁慧草堂:本app所提供的经书电子版、图片多数来自于仁慧草堂分享，少数来自于网络收集。
  cupertino_icons、intl、styled_widget、sqlite3、drift、drift_flutter、sqlite3_flutter_libs、path_provider、path、fl_chart、shared_preferences、pdfx、flutter_slidable、image_picker、flutter_image_compress、table_calendar、lunar、sensors_plus、flutter_svg、audioplayers、flutter_tts、carousel_slider、wakelock_plus、device_info_plus、flutter_pdf_text、flutter_foreground_task、pdfium_bindings、ffi、msix、file_picker、url_launcher...''',
                  textAlign: TextAlign.left,
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
