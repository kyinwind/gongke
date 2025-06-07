import 'package:flutter/material.dart';

enum FoPuShaImageType {
  amituofo('阿弥陀佛圣像'),
  dizangpusashengxiang('地藏菩萨圣像'),
  dashizhipusashengxiang('大势至菩萨圣像'),
  guanyinpusashengxiang('观音菩萨圣像'),
  guanshiyinpusashengxiang('观世音菩萨圣像'),
  shijiamounifoshengxiang('释迦牟尼佛圣像'),
  xifangsanshengxiang('西方三圣像');

  final String label;
  const FoPuShaImageType(this.label);
}

String getLabelByFoPuSaType(String typeString) {
  try {
    return FoPuShaImageType.values
        .firstWhere((type) => type.name == typeString)
        .label;
  } catch (e) {
    return '未知类型'; // 返回默认值
  }
}

String getFoPuSaImagePath(String label) {
  final type = getTypeByFoPuSaLabel(label);
  return 'assets/images/$type.jpg';
}

String getTypeByFoPuSaLabel(String fopusaLabel) {
  try {
    switch (fopusaLabel) {
      case '阿弥陀佛圣像':
        return 'amituofo';
      case '地藏菩萨圣像':
        return 'ziangpusashengxiang';
      case '大势至菩萨圣像':
        return 'dashizhipusashengxiang';
      case '观音菩萨圣像':
        return 'guanyinpusashengxiang';
      case '观世音菩萨圣像':
        return 'guanshiyinpusashengxiang';
      case '释迦牟尼佛圣像':
        return 'shijiamounifoshengxiang';
      case '西方三圣像':
        return 'xifangsanshengxiang';
      default:
        return 'xifangsanshengxiang';
    }
  } catch (e) {
    return 'xifangsanshengxiang'; // 返回默认值
  }
}

enum GongKeType {
  songjing('诵经'),
  nianzhou('念咒'),
  nianshenghao('念佛菩萨圣号'),
  ketou('磕头'),
  baichan('拜忏'),
  dazuo('打坐'),
  others('其他');

  final String label;
  const GongKeType(this.label);
}

String getLabelSafely(String typeString) {
  try {
    return GongKeType.values
        .firstWhere((type) => type.name == typeString)
        .label;
  } catch (e) {
    return '未知类型'; // 返回默认值
  }
}

String getDanWeiByLabel(String typeLabelString) {
  try {
    switch (typeLabelString) {
      case '诵经':
        return '部';
      case '念咒':
        return '遍';
      case '念圣号':
        return '声';
      case '磕头':
        return '个';
      case '拜忏':
        return '次';
      case '打坐':
        return '分钟';
      default:
        return '遍';
    }
  } catch (e) {
    return '遍'; // 返回默认值
  }
}

String getDanWei(String typeString) {
  try {
    switch (typeString) {
      case 'songjing':
        return '部';
      case 'nianzhou':
        return '遍';
      case 'nianshenghao':
        return '声';
      case 'ketou':
        return '个';
      case 'baichan':
        return '次';
      case 'dazuo':
        return '分钟';
      default:
        return '遍';
    }
  } catch (e) {
    return '遍'; // 返回默认值
  }
}

// 定义经书名称到文件URL的映射
final Map<String, String> jingShuFiles = {
  '《一切如来心秘密全身舍利宝箧印陀罗尼经》': '1.pdf',
  '《三劫三千佛名经》': '2.pdf',
  '《佛教念诵集》（暮时课诵）': '3.pdf',
  '《佛教念诵集》（朝时课诵）': '4.pdf',
  '《佛说七俱胝佛母心大准提陀罗尼经》': '5.pdf',
  '《佛说四十二章经》': '6.pdf',
  '《佛说无量寿经》': '7.pdf',
  '《佛说父母恩难报经》': '8.pdf',
  '《佛说疗痔病经》': '9.pdf',
  '《佛说盂兰盆经》': '10.pdf',
  '《佛说观弥勒菩萨上生兜率陀天经》': '11.pdf',
  '《佛说观弥勒菩萨下生经》': '12.pdf',
  '《佛说阿弥陀经要解》': '13.pdf',
  '《僧伽吒经》': '14.pdf',
  '《六祖大师法宝坛经》': '15.pdf',
  '《净土五经》': '16.pdf',
  '《千手千眼观世音菩萨广大圆满无碍大悲心陀罗尼经》': '17.pdf',
  '《大乘入楞伽经》': '18.pdf',
  '《大佛顶首楞严神咒》': '19.pdf',
  '《大佛顶首楞严经》': '20.pdf',
  '《大佛顶首楞严经浅释》宣化上人': '21.pdf',
  '《大悲咒》（84句）': '22.pdf',
  '《大方广佛华严经普贤菩萨行愿品》': '23.pdf',
  '《大方广圆觉修多罗了义经》': '24.pdf',
  '《妙法莲华经》': '25.pdf',
  '《慈悲药师宝忏》': '26.pdf',
  '《慈悲道场忏法》': '27.pdf',
  '《梵网经菩萨戒本》诵戒专用': '28.pdf',
  '《礼佛大忏悔文》': '29.pdf',
  '《维摩诘所说经》': '30.pdf',
  '《药师琉璃光如来本愿功德经》': '31.pdf',
  '《虚空藏菩萨经》': '32.pdf',
  '《观世音菩萨普门品》': '33.pdf',
  '《观世音菩萨耳根圆通章》': '34.pdf',
  '《解深密经》': '35.pdf',
  '《达磨大师血脉论》': '36.pdf',
  '《金光明经》': '37.pdf',
  '《金刚般若波罗蜜经》': '38.pdf',
  '地藏三经《占察善恶业报经》': '39.pdf',
  '地藏三经《地藏菩萨本愿经》': '40.pdf',
  '地藏三经《地藏菩萨本愿经》（仿瓷版）': '41.pdf',
  '地藏三经《大乘大集地藏十轮经》': '42.pdf',
};

String getPdfFileByName(String jingShuName) {
  return jingShuFiles[jingShuName] ?? '';
}

class AppButtonStyle {
  static final primaryButton = ButtonStyle(
    backgroundColor: WidgetStateProperty.resolveWith<Color>((
      Set<WidgetState> states,
    ) {
      if (states.contains(WidgetState.disabled)) {
        return Colors.grey.shade300;
      }
      return Colors.blue.shade600;
    }),
    foregroundColor: WidgetStateProperty.all(Colors.white),
    padding: WidgetStateProperty.all(
      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    ),
    shape: WidgetStateProperty.all(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    elevation: WidgetStateProperty.resolveWith<double>((
      Set<WidgetState> states,
    ) {
      if (states.contains(WidgetState.pressed)) {
        return 0;
      }
      return 2;
    }),
    minimumSize: WidgetStateProperty.all(const Size(120, 45)),
  );

  static final secondaryButton = ButtonStyle(
    backgroundColor: WidgetStateProperty.resolveWith<Color>((
      Set<WidgetState> states,
    ) {
      if (states.contains(WidgetState.disabled)) {
        return Colors.grey.shade300;
      }
      return Colors.green.shade600;
    }),
    foregroundColor: WidgetStateProperty.all(Colors.white),
    padding: WidgetStateProperty.all(
      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    ),
    shape: WidgetStateProperty.all(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    elevation: WidgetStateProperty.resolveWith<double>((
      Set<WidgetState> states,
    ) {
      if (states.contains(WidgetState.pressed)) {
        return 0;
      }
      return 2;
    }),
    minimumSize: WidgetStateProperty.all(const Size(120, 45)),
  );
}
