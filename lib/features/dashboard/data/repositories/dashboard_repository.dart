import 'package:lexcore/features/dashboard/domain/entities/dashboard_entity.dart';

class DashboardRepository {
  const DashboardRepository();

  DashboardEntity load() {
    return const DashboardEntity(
      totalCases: 1284,
      inProgress: 42,
      completed: 1207,
      accuracy: 99.2,
      trendPoints: [0.78, 0.7, 0.76, 0.58, 0.64, 0.42, 0.48],
      cases: [
        DashboardCaseItem(
          title: '某房地产合同纠纷 A-2024-081',
          subtitle: '证据审查中',
          progress: 0.85,
          icon: 'gavel',
        ),
        DashboardCaseItem(
          title: '跨国贸易侵权调查 CASE-992',
          subtitle: '深度学习分析',
          progress: 0.32,
          icon: 'description',
        ),
        DashboardCaseItem(
          title: '股权质押合规性自查',
          subtitle: '文档扫描中',
          progress: 0.54,
          icon: 'balance',
        ),
      ],
    );
  }
}
