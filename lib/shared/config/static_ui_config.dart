import 'package:lexcore/app/router/route_names.dart';
import 'package:lexcore/shared/models/legal_models.dart';

class StaticUiConfig {
  const StaticUiConfig._();

  static const quickActions = <QuickAction>[
    QuickAction(
      title: '法律咨询',
      subtitle: '即时智能对话建议',
      icon: 'chat_bubble',
      route: RouteNames.consultationPath,
    ),
    QuickAction(
      title: '文书生成',
      subtitle: '快速生成法律文书',
      icon: 'description',
      route: RouteNames.documentGeneratePath,
    ),
    QuickAction(
      title: '案件分析',
      subtitle: '风险与胜诉要点',
      icon: 'analytics',
      route: RouteNames.dashboardPath,
    ),
  ];

  static const settingsItems = <SettingItem>[
    SettingItem(title: '主题模式', subtitle: '跟随系统', icon: 'dark_mode'),
    SettingItem(
      title: '缓存管理',
      subtitle: '查看与清理本地缓存',
      icon: 'cleaning_services',
    ),
    SettingItem(title: '服务条款', subtitle: '查看平台使用规范', icon: 'description'),
    SettingItem(title: '隐私政策', subtitle: '查看数据使用说明', icon: 'policy'),
    SettingItem(title: '关于我们', subtitle: '版本信息与团队介绍', icon: 'info'),
  ];

  static const hotKeywords = <String>['劳动合同', '工伤认定', '借款纠纷', '房屋租赁', '离婚财产'];

  static const searchScenarioGroups = <SearchScenarioGroup>[
    SearchScenarioGroup(
      title: '劳动用工',
      items: [
        SearchScenarioItem(
          id: 'labor_contract',
          label: '劳动合同',
          keyword: '劳动合同',
        ),
        SearchScenarioItem(
          id: 'labor_arbitration',
          label: '劳动仲裁',
          keyword: '劳动仲裁',
        ),
      ],
    ),
    SearchScenarioGroup(
      title: '合同纠纷',
      items: [
        SearchScenarioItem(
          id: 'contract_breach',
          label: '合同违约',
          keyword: '合同违约',
        ),
        SearchScenarioItem(id: 'loan_contract', label: '借款合同', keyword: '借款合同'),
      ],
    ),
  ];
}
