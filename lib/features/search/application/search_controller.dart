import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lexcore/features/search/data/repositories/search_repository.dart';
import 'package:lexcore/features/search/domain/entities/search_state.dart';
import 'package:lexcore/shared/models/legal_models.dart';
import 'package:lexcore/shared/services/mock/mock_providers.dart';

class SearchController extends StateNotifier<String> {
  SearchController() : super('');

  void updateKeyword(String keyword) {
    state = keyword;
  }
}

final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  return SearchRepository(ref.watch(mockLegalRepositoryProvider));
});

final searchControllerProvider =
    StateNotifierProvider<SearchController, String>((ref) {
      return SearchController();
    });

final hotKeywordsProvider = Provider<List<String>>((ref) {
  return ref.watch(searchRepositoryProvider).hotKeywords();
});

final searchResultsProvider = Provider<List<LawSearchItem>>((ref) {
  final keyword = ref.watch(searchControllerProvider);
  return ref.watch(searchRepositoryProvider).search(keyword);
});

final articleDetailProvider = Provider<LawArticleDetail>((ref) {
  return ref.watch(searchRepositoryProvider).articleDetail();
});

final articleDetailByItemProvider =
    Provider.family<LawArticleDetail, LawSearchItem?>((ref, item) {
      return ref.watch(searchRepositoryProvider).articleDetail(item);
    });
