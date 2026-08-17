import 'package:flutter/material.dart';
import 'package:app_help_center/app_help_center.dart';

/// 诵经助手 · 帮助中心配置
const String _feedbackEmail = 'yangxuehui@outlook.com';

/// 全局帮助中心配置（供 controller 和页面共用）
final AppHelpCenterConfig gongKeHelpConfig = AppHelpCenterConfig(
  appName: '诵经助手',
  feedback: HelpFeedbackConfig(
    email: _feedbackEmail,
    discordWebhookUrl: Uri.parse(
      'https://discord.com/api/webhooks/1480084428188549174/gROlu7EzQdVS1icNZD1_3AirLfHtoTCumEPzD_P66rFt6Bv4CaZmA1NwfEjTuJip67Ro',
    ),
    dingTalkWebhookUrl: Uri.parse(
      'https://oapi.dingtalk.com/robot/send?access_token=fe7f86d6c40a7585ead48d4c87cbbdbbb49b96171c0c8fc6a3ef0f72ec2ae0c2',
    ),
    dingTalkContentBuilder: (payload) => 'feedback\n${payload.combinedContent}',
    includeSystemInfo: true,
  ),
  supportUrl: Uri.parse(
    'https://my.feishu.cn/wiki/Px4OwS67Eia7ZNkVtWJchBpSnVg',
  ),
  announcements: [
    HelpAnnouncement(
      id: 'welcome_v106',
      title: '欢迎使用诵经助手',
      message:
          '诵经助手是一款帮助佛友管理与记录日常佛学修行功课的免费工具。 应用提供了发愿向导、功课日历、功课统计、诵经、电子木鱼、念佛念咒计数、打坐计时、每日开示、语音引导拜忏等工具帮助佛友更好地进行日常佛学修行功课。\n\n如果您在使用过程中遇到问题，或者有任何建议和意见，欢迎通过反馈页面联系我们。',
      publishedAt: DateTime(2026, 6, 27),
      level: HelpAnnouncementLevel.info,
      isPinned: true,
    ),
  ],
  versionHistory: [
    VersionHistoryItem(
      versionName: 'v1.0.7',
      publishedAt: DateTime(2026, 6, 27),
      changes: '增加帮助中心的公告和版本更新功能。\n\n用户可以通过反馈页面提交问题和建议。',
    ),
    VersionHistoryItem(
      versionName: 'v1.0.6',
      publishedAt: DateTime(2025, 9, 9),
      changes: '功课设定界面、开示界面增加分享功能。',
    ),
    VersionHistoryItem(
      versionName: 'v1.0.5',
      publishedAt: DateTime(2025, 8, 30),
      changes: '诵经时可以播放电子木鱼。',
    ),
    VersionHistoryItem(
      versionName: 'v1.0.3',
      publishedAt: DateTime(2025, 7, 29),
      changes: '增加欢迎页面。\n增加经书、善书、开示文件导入功能。\n准备上架应用商店。',
    ),
    VersionHistoryItem(
      versionName: 'v1.0.0',
      publishedAt: DateTime(2025, 7, 19),
      changes: '准备上架应用商店。\n增加华严经。',
    ),
    VersionHistoryItem(
      versionName: 'v0.9.7',
      publishedAt: DateTime(2025, 7, 12),
      changes: '增加打坐的计时功能。\n增加善书。',
    ),
    VersionHistoryItem(
      versionName: 'v0.9.6',
      publishedAt: DateTime(2025, 7, 4),
      changes: '完善双页显示和缩略图显示。',
    ),
    VersionHistoryItem(
      versionName: 'v0.9.4',
      publishedAt: DateTime(2025, 6, 26),
      changes: '听书功能支持win平台。\n增加坐禅系列电子书。\n修改经书和善书按照名称排序。',
    ),
    VersionHistoryItem(
      versionName: 'v0.9.3',
      publishedAt: DateTime(2025, 6, 23),
      changes: '增加听书功能。\n更换饼图组件。',
    ),
    VersionHistoryItem(
      versionName: 'v0.9.2',
      publishedAt: DateTime(2025, 6, 17),
      changes: '完善首页显示。\n完善开示录显示。\n完善拜忏显示。',
    ),
    VersionHistoryItem(
      versionName: 'v0.9.1',
      publishedAt: DateTime(2025, 6, 11),
      changes: '完善pdf显示，增加善书页面。',
    ),
    VersionHistoryItem(
      versionName: 'v0.9.0',
      publishedAt: DateTime(2025, 6, 8),
      changes: '首次发布。',
    ),
  ],
  faqItems: [
    HelpFaqItem(
      id: 'why_no_builtin_sutras',
      question: '为什么功课助手没有内置经书？还需要我自己导入？',
      answer:
          '在《互联网宗教信息服务管理办法》中，要求 App 作者应当取得互联网宗教信息服务许可。\n\n所以目前的功课助手 App 以及诵经助手 App 都是纯工具类 App，不能内置经书。\n\n因为目前互联网上的经书很常见，也比较容易下载，各位佛友自己下载导入就可以使用。\n\n具体操作方法请参考技术支持网站。',
    ),
  ],
);

/// 全局共享的帮助中心 controller
final AppHelpCenterController helpCenterController = AppHelpCenterController(
  config: gongKeHelpConfig,
);

/// 在 app 启动时调用，初始化 controller（加载本地存储的已读状态、拉取远程公告）
Future<void> initHelpCenter() async {
  await helpCenterController.load(
    refreshRemote: gongKeHelpConfig.refreshRemoteOnOpen,
  );
}

/// 帮助中心页面（使用共享 controller，确保红点状态同步）
class GongKeHelpCenterPage extends StatelessWidget {
  const GongKeHelpCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppHelpCenterPage(
      config: gongKeHelpConfig,
      controller: helpCenterController,
    );
  }
}

/// 带小红点的帮助图标按钮
///
/// 当有未读公告或版本更新时，图标右上角显示红色小圆点；
/// 用户点击后跳转到帮助中心页面，阅读后红点自动消失。
class HelpBadgeIcon extends StatefulWidget {
  const HelpBadgeIcon({super.key});

  @override
  State<HelpBadgeIcon> createState() => _HelpBadgeIconState();
}

class _HelpBadgeIconState extends State<HelpBadgeIcon> {
  @override
  void initState() {
    super.initState();
    helpCenterController.addListener(_onControllerChange);
  }

  @override
  void dispose() {
    helpCenterController.removeListener(_onControllerChange);
    super.dispose();
  }

  void _onControllerChange() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasUnread = helpCenterController.hasUnreadContent;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: const Icon(Icons.help_outline),
          color: Colors.grey,
          iconSize: 28,
          tooltip: '帮助中心',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const GongKeHelpCenterPage(),
              ),
            );
          },
        ),
        if (hasUnread)
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}
