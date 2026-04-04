import 'package:lexcore/app/router/route_names.dart';
import 'package:lexcore/shared/models/legal_models.dart';

class MockLegalRepository {
  const MockLegalRepository();

  List<QuickAction> quickActions() {
    return const [
      QuickAction(
        title: '法律咨询',
        subtitle: '即时智能对话建议',
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
        route: RouteNames.dashboardPath,
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

  List<ConsultationSession> consultationSessions() {
    final now = DateTime.now();
    return [
      ConsultationSession(
        id: 'thread_lexiai',
        title: 'LexCore 法律助手',
        preview: '好的，根据您的劳动合同条款，关于竞业协议的范围...',
        updatedAt: now.subtract(const Duration(minutes: 5)),
        icon: 'smart_toy',
        isActive: true,
      ),
      ConsultationSession(
        id: 'thread_property',
        title: '房产买卖纠纷咨询',
        preview: '建议您先准备好购房合同和定金收据，我们可以进一步分析。',
        updatedAt: now.subtract(const Duration(days: 1, hours: 2)),
        icon: 'home_work',
      ),
      ConsultationSession(
        id: 'thread_equity',
        title: '初创企业股权架构',
        preview: '关于创始团队的代持协议，这里有几个模板您可以参考...',
        updatedAt: now.subtract(const Duration(days: 2, hours: 3)),
        icon: 'work',
      ),
      ConsultationSession(
        id: 'thread_tort',
        title: '民事侵权案件分析',
        preview: '侵权行为的判定需要看是否有主观过错和实际损失。',
        updatedAt: now.subtract(const Duration(days: 7)),
        icon: 'gavel',
      ),
      ConsultationSession(
        id: 'thread_family',
        title: '婚姻家庭法律咨询',
        preview: '您咨询的财产分配问题，在法律上有明确的界定标准...',
        updatedAt: now.subtract(const Duration(days: 11)),
        icon: 'family_restroom',
      ),
    ];
  }

  List<ChatMessage> consultationMessages() {
    return consultationMessagesByThread('thread_lexiai');
  }

  List<ChatMessage> consultationMessagesByThread(String threadId) {
    switch (threadId) {
      case 'thread_property':
        return const [
          ChatMessage(
            id: 'property_m1',
            role: ChatRole.assistant,
            content: '请先说明房产交易阶段：签约、付款、过户目前到了哪一步？',
          ),
          ChatMessage(
            id: 'property_m2',
            role: ChatRole.user,
            content: '我已支付定金，卖方突然不卖了。',
          ),
          ChatMessage(
            id: 'property_m3',
            role: ChatRole.assistant,
            content: '建议先核查合同违约条款，并固定转账凭证与沟通记录，再评估继续履约或双倍返还定金路径。',
            references: ['民法典 第五百八十七条', '民法典 第五百七十七条'],
          ),
        ];
      case 'thread_equity':
        return const [
          ChatMessage(
            id: 'equity_m1',
            role: ChatRole.assistant,
            content: '请确认创始人之间是否已有书面股权约定及归属期限（vesting）。',
          ),
          ChatMessage(
            id: 'equity_m2',
            role: ChatRole.user,
            content: '目前只有口头约定，还没有签协议。',
          ),
          ChatMessage(
            id: 'equity_m3',
            role: ChatRole.assistant,
            content: '建议尽快补充股东协议、代持协议和退出机制条款，避免融资前后产生控制权争议。',
            references: ['公司法 第四十三条', '民法典 合同编'],
          ),
        ];
      case 'thread_tort':
        return const [
          ChatMessage(
            id: 'tort_m1',
            role: ChatRole.assistant,
            content: '侵权责任通常围绕行为、过错、损害和因果关系四个要件展开。',
            references: ['民法典 第一千一百六十五条'],
          ),
        ];
      case 'thread_family':
        return const [
          ChatMessage(
            id: 'family_m1',
            role: ChatRole.assistant,
            content: '婚姻家庭咨询建议先明确财产性质：婚前个人财产、婚后共同财产、债务承担。',
            references: ['民法典 第一千零六十二条'],
          ),
        ];
      case 'thread_lexiai':
        return const [
          ChatMessage(
            id: 'lexiai_m1',
            role: ChatRole.assistant,
            content: '您好，我是 LexCore 法律助手。请描述您的问题和关键事实。',
          ),
          ChatMessage(
            id: 'lexiai_m2',
            role: ChatRole.user,
            content: '公司拖欠工资两个月，我该如何维权？',
          ),
          ChatMessage(
            id: 'lexiai_m3',
            role: ChatRole.assistant,
            content: '建议先保留劳动合同、工资流水和考勤记录，再向劳动监察投诉或申请仲裁。',
            references: ['劳动合同法 第三十条', '劳动争议调解仲裁法 第二条'],
          ),
        ];
      default:
        return const [
          ChatMessage(
            id: 'new_thread_welcome',
            role: ChatRole.assistant,
            content: '您好，我是 LexCore 法律助手。请告诉我您的法律问题，我会给出分步骤建议。',
          ),
        ];
    }
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

## 证据示意图
![证据截图示意](lexcore://evidence-info-card)

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
        markdown: '''
# 劳动仲裁申请书-2026-03-06

## 仲裁请求
1. 支付拖欠工资；
2. 支付经济补偿。

## 证据目录
- 劳动合同
- 工资流水
''',
      ),
      DocumentItem(
        id: 'd2',
        name: '借款合同审查意见',
        updatedAt: now.subtract(const Duration(days: 3)),
        type: '审查意见',
        markdown: '''
# 借款合同审查意见

## 审查结论
合同主要条款完整，但违约责任与担保约定仍需细化。
''',
      ),
      DocumentItem(
        id: 'd3',
        name: '合同违约律师函',
        updatedAt: now.subtract(const Duration(days: 5)),
        type: '律师函',
        markdown: '''
# 合同违约律师函

贵司存在逾期履约行为，请于 7 日内完成整改并承担相应违约责任。
''',
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
      LawSearchItem(
        title: '中华人民共和国劳动法 第四十四条',
        snippet: '安排劳动者延长工作时间的，支付不低于工资百分之一百五十的工资报酬。',
        articleCode: '劳动法第44条',
      ),
      LawSearchItem(
        title: '中华人民共和国劳动合同法 第四十七条',
        snippet: '经济补偿按劳动者在本单位工作的年限，每满一年支付一个月工资的标准向劳动者支付。',
        articleCode: '劳合第47条',
      ),
      LawSearchItem(
        title: '中华人民共和国民法典 第五百七十七条',
        snippet: '当事人一方不履行合同义务或者履行合同义务不符合约定的，应当承担继续履行等违约责任。',
        articleCode: '民法典第577条',
      ),
      LawSearchItem(
        title: '中华人民共和国民法典 第五百八十四条',
        snippet: '当事人一方不履行合同义务造成对方损失的，损失赔偿额应相当于因违约所造成的损失。',
        articleCode: '民法典第584条',
      ),
      LawSearchItem(
        title: '中华人民共和国民法典 第一千零六十二条',
        snippet: '夫妻在婚姻关系存续期间所得的工资、奖金、劳务报酬等，为夫妻共同财产。',
        articleCode: '民法典第1062条',
      ),
      LawSearchItem(
        title: '中华人民共和国民法典 第一千一百六十五条',
        snippet: '行为人因过错侵害他人民事权益造成损害的，应当承担侵权责任。',
        articleCode: '民法典第1165条',
      ),
      LawSearchItem(
        title: '中华人民共和国公司法 第四条',
        snippet: '公司股东依法享有资产收益、参与重大决策和选择管理者等权利。',
        articleCode: '公司法第4条',
      ),
      LawSearchItem(
        title: '中华人民共和国行政处罚法 第三十三条',
        snippet: '违法行为轻微并及时改正，没有造成危害后果的，不予行政处罚。',
        articleCode: '行罚法第33条',
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
    ];
  }

  List<SettingItem> settings() {
    return const [
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
  }

  List<String> hotKeywords() {
    return const ['劳动合同', '工伤认定', '借款纠纷', '房屋租赁', '离婚财产'];
  }

  List<SearchScenarioGroup> searchScenarioGroups() {
    return const [
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
          SearchScenarioItem(
            id: 'loan_dispute',
            label: '借款纠纷',
            keyword: '借款纠纷',
          ),
        ],
      ),
      SearchScenarioGroup(
        title: '婚姻家事',
        items: [
          SearchScenarioItem(
            id: 'divorce_property',
            label: '离婚财产',
            keyword: '离婚财产',
          ),
          SearchScenarioItem(id: 'child_custody', label: '抚养权', keyword: '抚养权'),
        ],
      ),
      SearchScenarioGroup(
        title: '侵权赔偿',
        items: [
          SearchScenarioItem(
            id: 'traffic_accident',
            label: '交通事故',
            keyword: '交通事故',
          ),
          SearchScenarioItem(
            id: 'personal_injury',
            label: '人身损害',
            keyword: '人身损害',
          ),
        ],
      ),
      SearchScenarioGroup(
        title: '公司治理',
        items: [
          SearchScenarioItem(
            id: 'equity_entrustment',
            label: '股权代持',
            keyword: '股权',
          ),
          SearchScenarioItem(
            id: 'corporate_governance',
            label: '公司治理',
            keyword: '公司法',
          ),
        ],
      ),
      SearchScenarioGroup(
        title: '房产租赁',
        items: [
          SearchScenarioItem(
            id: 'house_rental',
            label: '房屋租赁',
            keyword: '房屋租赁',
          ),
          SearchScenarioItem(
            id: 'property_dispute',
            label: '物业纠纷',
            keyword: '物业',
          ),
        ],
      ),
    ];
  }
}
