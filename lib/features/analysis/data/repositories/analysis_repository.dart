import 'package:lexcore/features/analysis/domain/entities/analysis_summary.dart';
import 'package:lexcore/shared/models/legal_models.dart';

class AnalysisRepository {
  const AnalysisRepository();

  AnalysisSummary? loadSummary() {
    return const AnalysisSummary(
      reportId: 'LX-AN-20260405-0001',
      generatedAt: '2026-04-05 12:00',
      overview:
          '本案争议核心集中在房屋买卖合同履行阶段的过户义务迟延。结合现有付款凭证、合同条款及沟通记录，原告诉请具备较高支持度，建议优先围绕违约责任与履行期限进行法庭陈述。',
      metrics: [
        AnalysisMetric(label: '事实完整度', value: '86%'),
        AnalysisMetric(label: '证据强度', value: '79%'),
        AnalysisMetric(label: '程序风险', value: '中等'),
      ],
      risks: [
        RiskAlert(
          level: '中',
          title: '补充证据时点风险',
          description: '若关键补充证据未在举证期限内提交，法院可能降低采信程度。建议在下次庭前会议前完成证据目录更新与说明。',
        ),
        RiskAlert(
          level: '低',
          title: '合同条款解释分歧',
          description: '被告可能主张过户前置条件未满足，需提前准备合同文义与履约行为的对应说明。',
        ),
      ],
      riskIndicators: [
        RiskIndicator(label: '履约抗辩风险', value: 0.52, level: RiskLevel.medium),
        RiskIndicator(label: '证据瑕疵风险', value: 0.34, level: RiskLevel.low),
        RiskIndicator(label: '程序延宕风险', value: 0.61, level: RiskLevel.medium),
      ],
      disputeFocus: ['过户义务是否已到期', '违约责任承担范围', '违约金计算标准与起算时间'],
      legalRelations: ['房屋买卖合同关系', '合同附随义务关系', '违约责任与损害赔偿关系'],
      statuteMatches: [
        StatuteMatch(
          title: '《中华人民共和国民法典》第五百七十七条',
          detail: '当事人一方不履行合同义务或者履行合同义务不符合约定的，应承担继续履行等违约责任。',
        ),
        StatuteMatch(
          title: '《中华人民共和国民法典》第五百七十八条',
          detail: '一方明确表示或以行为表明不履行合同义务的，对方可在履行期限届满前请求承担违约责任。',
        ),
      ],
      recommendations: [
        '在下一次庭前准备中补充付款流水与催告函送达凭证，形成闭环证据链。',
        '围绕“过户义务已具备履行条件”制作时间轴，弱化被告抗辩空间。',
        '准备两套和解区间方案，兼顾继续履行与折价赔偿两种路径。',
      ],
      evidences: [
        EvidenceScore(title: '房屋买卖合同原件', score: '强（A）', strong: true),
        EvidenceScore(title: '全额付款银行流水', score: '强（A-）', strong: true),
        EvidenceScore(title: '催告与沟通记录', score: '中（B+）', strong: false),
      ],
    );
  }
}
