import 'package:lexcore/shared/models/legal_models.dart';

class AnalysisSummary {
  const AnalysisSummary({
    required this.reportId,
    required this.generatedAt,
    required this.overview,
    required this.metrics,
    required this.risks,
    required this.riskIndicators,
    required this.disputeFocus,
    required this.legalRelations,
    required this.statuteMatches,
    required this.recommendations,
    required this.evidences,
  });

  final String reportId;
  final String generatedAt;
  final String overview;
  final List<AnalysisMetric> metrics;
  final List<RiskAlert> risks;
  final List<RiskIndicator> riskIndicators;
  final List<String> disputeFocus;
  final List<String> legalRelations;
  final List<StatuteMatch> statuteMatches;
  final List<String> recommendations;
  final List<EvidenceScore> evidences;
}

class RiskIndicator {
  const RiskIndicator({
    required this.label,
    required this.value,
    required this.level,
  });

  final String label;
  final double value;
  final RiskLevel level;
}

enum RiskLevel { low, medium, high }

class StatuteMatch {
  const StatuteMatch({required this.title, required this.detail});

  final String title;
  final String detail;
}

class EvidenceScore {
  const EvidenceScore({
    required this.title,
    required this.score,
    required this.strong,
  });

  final String title;
  final String score;
  final bool strong;
}
