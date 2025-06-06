import 'package:flutter/material.dart';
import 'package:gongke/main.dart';
import 'package:gongke/model/tables.dart';
import '../../database.dart';
import '../../comm/pub_tools.dart';
import 'package:drift/drift.dart' hide Column;

class NewBaiChanPage extends StatefulWidget {
  final BaiChanCompanion? baichan; // 可空，用于区分新建和编辑
  final String actType;

  const NewBaiChanPage({this.baichan, required this.actType, Key? key})
    : super(key: key);

  @override
  _NewBaiChanPageState createState() => _NewBaiChanPageState();
}

class _NewBaiChanPageState extends State<NewBaiChanPage> {
  late BaiChanCompanion baichan;
  final List<String> imageList = [
    '阿弥陀佛圣像',
    '观音菩萨圣像',
    '地藏王菩萨圣像',
    '大势至菩萨圣像',
    '观世音菩萨圣像',
    '释迦牟尼佛圣像',
    '西方三圣像',
  ];
  late String currentImage;
  void _updateBaichan({
    String? image,
    String? chanhuiWenStart,
    String? chanhuiWenEnd,
    int? baichanTimes,
    int? baichanInterval1,
    int? baichanInterval2,
    bool? flagOrderNumber,
    bool? flagQiShen,
    String? name,
  }) {
    setState(() {
      baichan = baichan.copyWith(
        image: image != null ? Value(image) : const Value.absent(),
        chanhuiWenStart: chanhuiWenStart != null
            ? Value(chanhuiWenStart)
            : const Value.absent(),
        chanhuiWenEnd: chanhuiWenEnd != null
            ? Value(chanhuiWenEnd)
            : const Value.absent(),
        baichanTimes: baichanTimes != null
            ? Value(baichanTimes)
            : const Value.absent(),
        baichanInterval1: baichanInterval1 != null
            ? Value(baichanInterval1)
            : const Value.absent(),
        baichanInterval2: baichanInterval2 != null
            ? Value(baichanInterval2)
            : const Value.absent(),
        flagOrderNumber: flagOrderNumber != null
            ? Value(flagOrderNumber)
            : const Value.absent(),
        flagQiShen: flagQiShen != null
            ? Value(flagQiShen)
            : const Value.absent(),
        name: name != null ? Value(name) : const Value.absent(),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    // 如果是编辑模式，使用传入的数据；如果是新建模式，创建默认值
    baichan =
        widget.baichan ??
        BaiChanCompanion(
          image: const Value('阿弥陀佛圣像'),
          chanhuiWenStart: const Value(''),
          chanhuiWenEnd: const Value(''),
          baichanTimes: const Value(108),
          baichanInterval1: const Value(7),
          baichanInterval2: const Value(5),
          flagOrderNumber: const Value(true),
          flagQiShen: const Value(true),
          name: const Value('新建拜忏'),
        );
    currentImage = baichan.image.value;
  }

  Future<void> saveData() async {
    try {
      // 新增记录
      await globalDB.into(globalDB.baiChan).insertOnConflictUpdate(baichan);

      if (mounted) {
        Navigator.pop(context, true); // 返回 true 表示保存成功
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('保存失败: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.actType == 'new' ? '新建拜忏' : '修改拜忏')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text('1. 请选择拜忏背景图片'),
            DropdownButton<String>(
              value: currentImage,
              onChanged: (String? newValue) {
                setState(() {
                  currentImage = newValue!;
                });
              },
              items: imageList.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Row(
                    children: [
                      Image.asset(
                        getFoPuSaImagePath(value),
                        width: 30,
                        height: 30,
                      ),
                      const SizedBox(width: 8),
                      Text(value),
                    ],
                  ),
                );
              }).toList(),
            ),
            Image.asset(currentImage, height: 200),
            _textField('2. 忏悔文前文', baichan.chanhuiWenStart.toString(), (val) {
              _updateBaichan(chanhuiWenStart: val);
            }),
            _sliderField(
              '3. 共拜多少拜',
              baichan.baichanTimes.value.toDouble(),
              5,
              500,
              (val) {
                _updateBaichan(baichanTimes: val.toInt());
              },
            ),
            _sliderField(
              '4. 每一拜时长 (秒)',
              baichan.baichanInterval1.value.toDouble(),
              7,
              50,
              (val) {
                _updateBaichan(baichanInterval1: val.toInt());
              },
            ),
            SwitchListTile(
              title: Text('是否语音提示第几拜'),
              value: baichan.flagOrderNumber.value,
              onChanged: (val) {
                setState(() => _updateBaichan(flagOrderNumber: val));
              },
            ),
            _sliderField(
              '5. 每拜间隔 (秒)',
              baichan.baichanInterval2.value.toDouble(),
              5,
              10,
              (val) {
                _updateBaichan(baichanInterval2: val.toInt());
              },
            ),
            SwitchListTile(
              title: Text('是否语音提示起身'),
              value: baichan.flagQiShen.value,
              onChanged: (val) {
                setState(() => _updateBaichan(flagQiShen: val));
              },
            ),
            _textField('6. 忏悔文回向', baichan.chanhuiWenEnd.toString(), (val) {
              _updateBaichan(chanhuiWenEnd: val);
            }),
            _textField('7. 名称', baichan.name.toString(), (val) {
              _updateBaichan(name: val);
            }),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('取消'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    _updateBaichan(image: currentImage);
                    await saveData();
                    Navigator.pop(context, baichan);
                  },
                  child: Text('确认'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _textField(String label, String value, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        TextFormField(
          initialValue: value,
          maxLines: null,
          onChanged: onChanged,
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _sliderField(
    String label,
    double value,
    double min,
    double max,
    Function(double) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label (${value.toInt()} 秒)'),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: (max - min).toInt(),
          label: value.toStringAsFixed(0),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
