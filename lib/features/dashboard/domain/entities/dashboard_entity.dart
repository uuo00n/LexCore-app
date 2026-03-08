class DashboardEntity {
  const DashboardEntity({
    required this.totalCases,
    required this.inProgress,
    required this.completed,
    required this.accuracy,
    required this.trendPoints,
    required this.cases,
  });

  final int totalCases;
  final int inProgress;
  final int completed;
  final double accuracy;
  final List<double> trendPoints;
  final List<DashboardCaseItem> cases;
}

class DashboardCaseItem {
  const DashboardCaseItem({
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final double progress;
  final String icon;
}
