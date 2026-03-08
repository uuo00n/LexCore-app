import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lexcore/features/history/data/repositories/history_repository.dart';
import 'package:lexcore/shared/models/legal_models.dart';
import 'package:lexcore/shared/services/mock/mock_providers.dart';

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  return HistoryRepository(ref.watch(mockLegalRepositoryProvider));
});

final historyFilterProvider = StateProvider<HistoryCategory?>((ref) => null);

final historyItemsProvider = Provider<List<HistoryItem>>((ref) {
  final items = ref.watch(historyRepositoryProvider).loadAll();
  final category = ref.watch(historyFilterProvider);
  if (category == null) return items;
  return items.where((item) => item.category == category).toList();
});
