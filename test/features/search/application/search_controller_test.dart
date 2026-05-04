import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lexcore/core/error/app_exception.dart';
import 'package:lexcore/core/network/api_client.dart';
import 'package:lexcore/core/network/dio_provider.dart';
import 'package:lexcore/core/storage/local_storage.dart';
import 'package:lexcore/features/history/application/history_controller.dart';
import 'package:lexcore/features/search/application/search_controller.dart';
import 'package:lexcore/shared/models/legal_models.dart';

class _FakeArticleApiClient extends ApiClient {
  _FakeArticleApiClient() : super(Dio());

  @override
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    required T Function(Object? data) decoder,
  }) async {
    if (path == '/history') {
      return decoder({'items': const []});
    }
    if (path == '/laws/LAW-REFRESH') {
      return decoder({
        'title': '民法典第一百六十五条',
        'category': '法律',
        'issuing_authority': '全国人大',
        'effective_status': '现行有效',
        'publish_date': '2026-01-01',
        'full_text': '委托代理授权采用书面形式的，授权委托书应当载明代理人的姓名或者名称。',
      });
    }
    if (path == '/laws/LAW-FAIL') {
      throw AppException('law detail unavailable');
    }
    throw UnimplementedError('Unhandled GET path: $path');
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test(
    'article detail refreshes cached history after recording viewed law',
    () async {
      final preferences = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          apiClientProvider.overrideWithValue(_FakeArticleApiClient()),
          sharedPreferencesProvider.overrideWithValue(preferences),
        ],
      );
      addTearDown(container.dispose);

      final initialItems = await container.read(historyAllItemsProvider.future);
      expect(initialItems, isEmpty);

      const item = LawSearchItem(
        title: '民法典第一百六十五条',
        snippet: '委托代理授权采用书面形式。',
        articleCode: 'LAW-REFRESH',
      );
      final detail = await container.read(
        articleDetailByItemProvider(item).future,
      );
      final refreshedItems = await container.read(
        historyAllItemsProvider.future,
      );

      expect(detail.title, '民法典第一百六十五条');
      expect(refreshedItems, hasLength(1));
      expect(refreshedItems.single.category, HistoryCategory.analysis);
      expect(refreshedItems.single.resourceKey, 'LAW-REFRESH');
      expect(refreshedItems.single.title, contains('LAW-REFRESH'));
    },
  );

  test('failed article detail does not create local history', () async {
    final preferences = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        apiClientProvider.overrideWithValue(_FakeArticleApiClient()),
        sharedPreferencesProvider.overrideWithValue(preferences),
      ],
    );
    addTearDown(container.dispose);

    await container.read(historyAllItemsProvider.future);

    const item = LawSearchItem(
      title: '失效法规',
      snippet: '上游详情不可用。',
      articleCode: 'LAW-FAIL',
    );
    await expectLater(
      container.read(articleDetailByItemProvider(item).future),
      throwsA(isA<AppException>()),
    );

    expect(preferences.getString('history_records_local_v1'), isNull);
    expect(await container.read(historyAllItemsProvider.future), isEmpty);
  });
}
