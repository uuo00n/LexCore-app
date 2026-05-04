import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lexcore/features/history/application/history_controller.dart';
import 'package:lexcore/features/search/data/repositories/search_repository.dart';
import 'package:lexcore/features/search/domain/entities/search_state.dart';
import 'package:lexcore/shared/models/legal_models.dart';

class SearchController extends StateNotifier<String> {
  SearchController() : super('');

  void updateKeyword(String keyword) {
    state = keyword;
  }
}

final searchControllerProvider =
    StateNotifierProvider<SearchController, String>((ref) {
      return SearchController();
    });

final searchFilterProvider = StateProvider<int>((ref) => 0);

final searchFilterLabelsProvider = Provider<List<String>>((ref) {
  return ref.watch(searchRepositoryProvider).searchFilterLabels();
});

final hotKeywordsProvider = Provider<List<String>>((ref) {
  return ref.watch(searchRepositoryProvider).hotKeywords();
});

final searchScenarioGroupsProvider = Provider<List<SearchScenarioGroup>>((ref) {
  return ref.watch(searchRepositoryProvider).searchScenarioGroups();
});

final searchResultsProvider = FutureProvider<SearchResultBundle>((ref) async {
  final keyword = ref.watch(searchControllerProvider);
  final filterIndex = ref.watch(searchFilterProvider);
  return ref
      .watch(searchRepositoryProvider)
      .search(keyword, filterIndex: filterIndex);
});

final filteredHotSearchArticlesProvider =
    Provider<AsyncValue<List<LawSearchItem>>>((ref) {
      return ref
          .watch(searchResultsProvider)
          .whenData((result) => result.items);
    });

final searchNoticeProvider = Provider<AsyncValue<String?>>((ref) {
  return ref
      .watch(searchResultsProvider)
      .whenData((result) => result.noticeMessage);
});

final articleDetailProvider = FutureProvider<LawArticleDetail>((ref) async {
  return ref.watch(searchRepositoryProvider).articleDetail();
});

final articleDetailByItemProvider =
    FutureProvider.family<LawArticleDetail, LawSearchItem?>((ref, item) async {
      final detail = await ref
          .watch(searchRepositoryProvider)
          .articleDetail(item);
      if (item != null && item.articleCode.trim().isNotEmpty) {
        ref.invalidate(historyAllItemsProvider);
      }
      return detail;
    });
