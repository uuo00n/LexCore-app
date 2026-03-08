import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lexcore/features/analysis/data/repositories/analysis_repository.dart';
import 'package:lexcore/features/analysis/domain/entities/analysis_summary.dart';
import 'package:lexcore/shared/services/mock/mock_providers.dart';

final analysisRepositoryProvider = Provider<AnalysisRepository>((ref) {
  return AnalysisRepository(ref.watch(mockLegalRepositoryProvider));
});

final analysisSummaryProvider = Provider<AnalysisSummary>((ref) {
  return ref.watch(analysisRepositoryProvider).loadSummary();
});

final analysisReportProvider = Provider<AnalysisSummary>((ref) {
  return ref.watch(analysisSummaryProvider);
});
