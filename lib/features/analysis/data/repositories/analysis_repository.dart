import 'package:lexcore/features/analysis/domain/entities/analysis_summary.dart';
import 'package:lexcore/shared/services/mock/mock_legal_repository.dart';

class AnalysisRepository {
  const AnalysisRepository(this._mock);

  final MockLegalRepository _mock;

  AnalysisSummary loadSummary() {
    return AnalysisSummary(
      reportId: 'LX-20231024-082',
      generatedAt: '2023年10月24日',
      overview: '基于您上传的案卷材料，系统已识别本案属于“买卖合同纠纷”，涉及争议金额约 ¥1,250,000，证据完整度评估为良好。',
      metrics: _mock.analysisMetrics(),
      risks: _mock.riskAlerts(),
      riskIndicators: const [
        RiskIndicator(label: '诉讼时效风险', value: 0.15, level: RiskLevel.low),
        RiskIndicator(label: '证据链条闭环度', value: 0.65, level: RiskLevel.medium),
        RiskIndicator(label: '合规性违约概率', value: 0.88, level: RiskLevel.high),
      ],
      disputeFocus: const ['货物质量是否符合合同约定的验收标准？', '逾期付款违约金的计算基数及比例是否过高？'],
      legalRelations: const ['主体 A：某贸易有限公司', '法律性质：买卖合同关系'],
      statuteMatches: const [
        StatuteMatch(title: '《中华人民共和国劳动合同法》第三十条', detail: '用人单位应当及时足额支付劳动报酬。'),
        StatuteMatch(title: '《劳动争议调解仲裁法》第二条', detail: '用人单位与劳动者发生劳动争议，适用本法。'),
      ],
      recommendations: const ['补齐书面证据', '7 日内提交仲裁', '准备调解备选方案'],
      evidences: const [
        EvidenceScore(title: '电子采购合同.pdf', score: '98/100', strong: true),
        EvidenceScore(
          title: '货物交接单照片.jpg',
          score: '45/100 (模糊)',
          strong: false,
        ),
      ],
    );
  }
}
