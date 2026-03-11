import 'package:lexcore/app/router/route_names.dart';
import 'package:lexcore/shared/models/legal_models.dart';

class MockLegalRepository {
  const MockLegalRepository();

  List<QuickAction> quickActions() {
    return const [
      QuickAction(
        title: '法律咨询',
        subtitle: '即时 AI 对话建议',
        icon: 'chat_bubble',
        route: RouteNames.consultationPath,
      ),
      QuickAction(
        title: '文档生成',
        subtitle: '快速生成法律文书',
        icon: 'description',
        route: RouteNames.documentGeneratePath,
      ),
      QuickAction(
        title: '案件分析',
        subtitle: '风险与胜诉要点',
        icon: 'analytics',
        route: RouteNames.analysisDetailPath,
      ),
      QuickAction(
        title: '法律搜索',
        subtitle: '法规与案例检索',
        icon: 'gavel',
        route: RouteNames.legalSearchPath,
      ),
    ];
  }

  List<ActivityRecord> recentActivities() {
    final now = DateTime.now();
    return [
      ActivityRecord(
        title: '租赁合同违约责任咨询',
        time: now.subtract(const Duration(minutes: 15)),
        tag: '咨询',
      ),
      ActivityRecord(
        title: '劳动仲裁答辩状草稿',
        time: now.subtract(const Duration(hours: 2)),
        tag: '文档',
      ),
      ActivityRecord(
        title: '交通事故责任比例分析',
        time: now.subtract(const Duration(days: 1)),
        tag: '分析',
      ),
    ];
  }

  List<ChatMessage> consultationMessages() {
    return const [
      ChatMessage(
        id: 'm1',
        role: ChatRole.assistant,
        content: '您好，我是 LexCore 法律助手。请描述您的问题和关键事实。',
      ),
      ChatMessage(id: 'm2', role: ChatRole.user, content: '公司拖欠工资两个月，我该如何维权？'),
      ChatMessage(
        id: 'm3',
        role: ChatRole.assistant,
        content: '建议先保留劳动合同、工资流水和考勤记录，再向劳动监察投诉或申请仲裁。',
        references: ['劳动合同法 第三十条', '劳动争议调解仲裁法 第二条'],
      ),
    ];
  }

  List<AnalysisMetric> analysisMetrics() {
    return const [
      AnalysisMetric(label: '事实完整度', value: '82%'),
      AnalysisMetric(label: '证据强度', value: '76%'),
      AnalysisMetric(label: '程序风险', value: '中'),
      AnalysisMetric(label: '建议优先级', value: '高'),
    ];
  }

  List<RiskAlert> riskAlerts() {
    return const [
      RiskAlert(
        level: '高',
        title: '关键书面证据缺失',
        description: '建议补充书面通知、聊天记录导出件与签收凭证。',
      ),
      RiskAlert(
        level: '中',
        title: '诉讼时效接近',
        description: '建议本周内完成仲裁申请，避免时效风险。',
      ),
    ];
  }

  DocumentDraft generatedDraft() {
    return const DocumentDraft(
      title: '劳动仲裁申请书（草稿）',
      markdown: '''
# 劳动仲裁申请书

申请人：张某某

被申请人：某科技有限公司

## 仲裁请求
1. 支付拖欠工资人民币 20,000 元；
2. 支付经济补偿金人民币 8,000 元。

## 事实与理由
申请人自 2024 年 3 月入职，被申请人连续拖欠工资两个月。申请人已多次催告无果。

## 证据目录
- 劳动合同
- 工资流水
- 微信催告记录
''',
    );
  }

  List<DocumentItem> savedDocuments() {
    final now = DateTime.now();
    return [
      DocumentItem(
        id: 'd1',
        name: '劳动仲裁申请书-2026-03-06',
        updatedAt: now.subtract(const Duration(days: 1)),
        type: '仲裁文书',
      ),
      DocumentItem(
        id: 'd2',
        name: '借款合同审查意见',
        updatedAt: now.subtract(const Duration(days: 3)),
        type: '审查意见',
      ),
      DocumentItem(
        id: 'd3',
        name: '合同违约律师函',
        updatedAt: now.subtract(const Duration(days: 5)),
        type: '律师函',
      ),
    ];
  }

  List<LawSearchItem> searchResults() {
    return const [
      LawSearchItem(
        title: '中华人民共和国劳动合同法 第三十条',
        snippet: '用人单位应当按照劳动合同约定和国家规定，向劳动者及时足额支付劳动报酬。',
        articleCode: '劳合第30条',
      ),
      LawSearchItem(
        title: '劳动争议调解仲裁法 第二条',
        snippet: '中华人民共和国境内的用人单位与劳动者发生劳动争议，适用本法。',
        articleCode: '仲裁法第2条',
      ),
    ];
  }

  List<HistoryItem> historyItems() {
    final now = DateTime.now();
    return [
      HistoryItem(
        id: 'h1',
        title: '工资拖欠咨询会话',
        category: HistoryCategory.consultation,
        time: now.subtract(const Duration(hours: 4)),
      ),
      HistoryItem(
        id: 'h2',
        title: '劳动仲裁风险分析',
        category: HistoryCategory.analysis,
        time: now.subtract(const Duration(days: 1)),
      ),
      HistoryItem(
        id: 'h3',
        title: '劳动仲裁申请书草稿',
        category: HistoryCategory.document,
        time: now.subtract(const Duration(days: 2)),
      ),
    ];
  }

  List<ProfileMenuItem> profileMenus() {
    return const [
      ProfileMenuItem(
        title: '我的文档',
        icon: 'folder_open',
        route: RouteNames.savedDocumentsPath,
      ),
      ProfileMenuItem(
        title: '历史记录',
        icon: 'history',
        route: RouteNames.historyPath,
      ),
      ProfileMenuItem(
        title: '设置',
        icon: 'settings',
        route: RouteNames.settingsPath,
      ),
    ];
  }

  List<SettingItem> settings() {
    return const [
      SettingItem(title: '主题模式', subtitle: '预留暗色主题能力', icon: 'dark_mode'),
      SettingItem(
        title: '缓存管理',
        subtitle: '查看与清理本地缓存',
        icon: 'cleaning_services',
      ),
      SettingItem(title: '服务条款', subtitle: '查看平台使用规范', icon: 'description'),
      SettingItem(title: '隐私政策', subtitle: '查看数据使用说明', icon: 'policy'),
      SettingItem(title: '关于我们', subtitle: '版本信息与团队介绍', icon: 'info'),
    ];
  }

  List<String> hotKeywords() {
    return const ['劳动合同', '工伤认定', '借款纠纷', '房屋租赁', '离婚财产'];
  }
}
