import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lexcore/core/error/app_exception.dart';
import 'package:lexcore/core/network/api_client.dart';
import 'package:lexcore/features/history/data/repositories/history_repository.dart';
import 'package:lexcore/shared/models/legal_models.dart';

class _FakeApiClient extends ApiClient {
  _FakeApiClient() : super(Dio());

  Map<String, dynamic> historyPayload = const {'items': []};
  bool throwOnHistory = false;

  @override
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    required T Function(Object? data) decoder,
  }) async {
    if (path == '/history') {
      if (throwOnHistory) {
        throw AppException('history unavailable');
      }
      return decoder(historyPayload);
    }
    throw UnimplementedError('Unhandled GET path: $path');
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('loadAll falls back to local history when remote is empty', () async {
    final preferences = await SharedPreferences.getInstance();
    final apiClient = _FakeApiClient();
    final repository = HistoryRepository(apiClient, preferences);

    await repository.recordConsultationQuery(question: '工资拖欠如何处理');

    final items = await repository.loadAll();

    expect(items, hasLength(1));
    expect(items.single.title, contains('工资拖欠如何处理'));
    expect(items.single.category, HistoryCategory.consultation);
  });

  test(
    'loadAll merges remote and local history in descending time order',
    () async {
      final preferences = await SharedPreferences.getInstance();
      final apiClient = _FakeApiClient()
        ..historyPayload = {
          'items': [
            {
              'history_id': 'remote_1',
              'event_summary': '远端法条记录',
              'event_type': 'search_law',
              'created_at': '2026-04-04T10:00:00.000Z',
            },
          ],
        };
      final repository = HistoryRepository(apiClient, preferences);

      await repository.recordConsultationQuery(question: '本地咨询记录');

      final items = await repository.loadAll();

      expect(items, hasLength(2));
      expect(items.first.title, '本地咨询记录');
      expect(items.last.title, '远端法条记录');
    },
  );

  test(
    'recordAnalysisViewed updates the same article instead of duplicating',
    () async {
      final preferences = await SharedPreferences.getInstance();
      final repository = HistoryRepository(_FakeApiClient(), preferences);

      await repository.recordAnalysisViewed(
        articleCode: 'LAW-001',
        title: '劳动合同法第四十四条',
      );
      await repository.recordAnalysisViewed(
        articleCode: 'LAW-001',
        title: '劳动合同法第四十四条',
      );

      final items = await repository.loadAll();

      expect(items, hasLength(1));
      expect(items.single.category, HistoryCategory.analysis);
      expect(items.single.title, contains('LAW-001'));
    },
  );

  test(
    'loadAll still returns local history when remote request fails',
    () async {
      final preferences = await SharedPreferences.getInstance();
      final apiClient = _FakeApiClient()..throwOnHistory = true;
      final repository = HistoryRepository(apiClient, preferences);

      await repository.recordConsultationQuery(question: '咨询服务中断怎么办');

      final items = await repository.loadAll();

      expect(items, hasLength(1));
      expect(items.single.title, contains('咨询服务中断怎么办'));
    },
  );
}
