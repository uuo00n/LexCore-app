import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lexcore/features/analysis/data/repositories/analysis_repository.dart';
import 'package:lexcore/features/analysis/domain/entities/analysis_summary.dart';

final analysisRepositoryProvider = Provider<AnalysisRepository>((ref) {
  return const AnalysisRepository();
});

final analysisSummaryProvider = Provider<AnalysisSummary?>((ref) {
  return ref.watch(analysisRepositoryProvider).loadSummary();
});

final analysisReportProvider = Provider<AnalysisSummary?>((ref) {
  return ref.watch(analysisSummaryProvider);
});
