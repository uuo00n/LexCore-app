import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lexcore/features/history/data/repositories/history_repository.dart';
import 'package:lexcore/shared/models/legal_models.dart';

final historyFilterProvider = StateProvider<HistoryCategory?>((ref) => null);

final historySearchKeywordProvider = StateProvider<String>((ref) => '');
final historySearchStartTimeProvider = StateProvider<DateTime?>((ref) => null);
final historySearchEndTimeProvider = StateProvider<DateTime?>((ref) => null);

final historyAllItemsProvider = FutureProvider<List<HistoryItem>>((ref) async {
  return ref.watch(historyRepositoryProvider).loadAll();
});

final historyItemsProvider = Provider<AsyncValue<List<HistoryItem>>>((ref) {
  final itemsAsync = ref.watch(historyAllItemsProvider);
  final category = ref.watch(historyFilterProvider);
  return itemsAsync.whenData((items) {
    if (category == null) {
      return items;
    }
    return items.where((item) => item.category == category).toList();
  });
});

final historySearchItemsProvider = Provider<AsyncValue<List<HistoryItem>>>((
  ref,
) {
  final itemsAsync = ref.watch(historyAllItemsProvider);
  final category = ref.watch(historyFilterProvider);
  final keyword = ref.watch(historySearchKeywordProvider).trim().toLowerCase();
  final startTime = ref.watch(historySearchStartTimeProvider);
  final endTime = ref.watch(historySearchEndTimeProvider);

  return itemsAsync.whenData((items) {
    final filtered = items.where((item) {
      final matchesCategory = category == null || item.category == category;
      final matchesKeyword =
          keyword.isEmpty || item.title.toLowerCase().contains(keyword);
      final matchesStart = startTime == null || !item.time.isBefore(startTime);
      final matchesEnd = endTime == null || !item.time.isAfter(endTime);
      return matchesCategory && matchesKeyword && matchesStart && matchesEnd;
    }).toList()..sort((a, b) => b.time.compareTo(a.time));

    return filtered;
  });
});
