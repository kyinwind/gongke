import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:styled_widget/styled_widget.dart';
// import 'package:flutter_cupertino_datetime_picker/flutter_cupertino_datetime_picker.dart';
//import 'gongkeinfo.dart';

class GongKePage extends StatelessWidget {
  const GongKePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('功课'),
      // ),
      body: Form(
        child: ListView(
          children: [
            // 第一个 section: 发愿一览
            const ListTile(
              title: Text('发愿一览'),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5, // 示例数据数量
              itemBuilder: (context, index) {
                return ListTile(
                  onTap: () {
                    // 点击导航到另一个页面
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AnotherPage()),
                    );
                  },
                  leading: SizedBox(
                    width: 50,
                    height: 50,
                    child: SfCircularChart(
                      series: <CircularSeries>[
                        PieSeries<double, String>(
                          dataSource: <double>[index * 10, 100 - index * 10],
                          xValueMapper: (double data, _) => '',
                          yValueMapper: (double data, _) => data,
                          dataLabelSettings: const DataLabelSettings(isVisible: true),
                        )
                      ],
                    ),
                  ),
                  title: const Text('显示内容'),
                );
              },
            ),
            // 第二个 section
            const ListTile(
              title: Text('日期选择与日历'),
            ),
            // 选择框
            Text('月份选择')
            //DateTimePickerWidget(),
            // 日历
            //CalendarWidget(),
          ],
        ),
      ),
    );
  }
}

class AnotherPage extends StatelessWidget {
  const AnotherPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('另一个页面'),
      ),
      body: Center(
        child: Text('这是点击后打开的页面').fontSize(24).bold(),
      ),
    );
  }
}

class CalendarWidget extends StatelessWidget {
  CalendarWidget({super.key});

  final DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
      ),
      itemCount: 31, // 示例一个月的天数
      itemBuilder: (context, index) {
        final DateTime date = DateTime(_selectedDate.year, _selectedDate.month, index + 1);
        return Column(
          children: [
            Text(DateFormat('d').format(date)),
            Text('农历日期示例'), // 需替换为实际农历日期
            Text('${index * 3}%'),
          ],
        );
      },
    );
  }
}
