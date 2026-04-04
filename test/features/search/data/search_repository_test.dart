import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lexcore/core/network/api_client.dart';
import 'package:lexcore/features/history/data/repositories/history_repository.dart';
import 'package:lexcore/features/search/data/repositories/search_repository.dart';
import 'package:lexcore/shared/models/legal_models.dart';

class _FakeSearchApiClient extends ApiClient {
  _FakeSearchApiClient() : super(Dio());

  @override
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    required T Function(Object? data) decoder,
  }) async {
    if (path == '/laws/LAW-101') {
      return decoder({
        'title': '劳动合同法第四十四条',
        'category': '劳动法',
        'issuing_authority': '全国人大',
        'effective_status': '现行有效',
        'publish_date': '2024-01-01',
        'full_text': '第四十四条 劳动合同终止。\n\n有下列情形之一的，劳动合同终止。',
        'html_url': 'https://example.com/laws/LAW-101.html',
        'docx_url': 'https://example.com/laws/LAW-101.docx',
        'source_url': 'https://example.com/laws/LAW-101',
      });
    }
    if (path == '/laws/LAW-EMPTY') {
      return decoder({
        'title': '地方性法规示例',
        'category': '地方性法规',
        'issuing_authority': '地方人大',
        'effective_status': '现行有效',
        'publish_date': '2020-01-01',
        'html_url': 'https://example.com/laws/LAW-EMPTY.html',
      });
    }
    if (path == '/history') {
      return decoder({'items': const []});
    }
    throw UnimplementedError('Unhandled GET path: $path');
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('articleDetail records viewed article into history', () async {
    final preferences = await SharedPreferences.getInstance();
    final apiClient = _FakeSearchApiClient();
    final historyRepository = HistoryRepository(apiClient, preferences);
    final repository = SearchRepository(apiClient, historyRepository);

    const item = LawSearchItem(
      title: '劳动合同法第四十四条',
      snippet: '用人单位安排加班的，应当依法支付加班费。',
      articleCode: 'LAW-101',
    );

    final detail = await repository.articleDetail(item);
    final historyItems = await historyRepository.loadAll();

    expect(detail.title, '劳动合同法第四十四条');
    expect(detail.bodySections, hasLength(2));
    expect(detail.htmlUrl, 'https://example.com/laws/LAW-101.html');
    expect(detail.docxUrl, 'https://example.com/laws/LAW-101.docx');
    expect(detail.sourceUrl, 'https://example.com/laws/LAW-101');
    expect(historyItems, hasLength(1));
    expect(historyItems.single.category, HistoryCategory.analysis);
    expect(historyItems.single.title, contains('劳动合同法第四十四条'));
    expect(historyItems.single.title, contains('LAW-101'));
  });

  test(
    'articleDetail keeps fallback message and link when body is missing',
    () async {
      final preferences = await SharedPreferences.getInstance();
      final apiClient = _FakeSearchApiClient();
      final historyRepository = HistoryRepository(apiClient, preferences);
      final repository = SearchRepository(apiClient, historyRepository);

      const item = LawSearchItem(
        title: '地方性法规示例',
        snippet: '地方性法规 · 现行有效',
        articleCode: 'LAW-EMPTY',
      );

      final detail = await repository.articleDetail(item);

      expect(detail.bodySections, isEmpty);
      expect(detail.fallbackMessage, contains('暂未获取到法规正文'));
      expect(detail.htmlUrl, 'https://example.com/laws/LAW-EMPTY.html');
      expect(detail.content, contains('法规标题：地方性法规示例'));
    },
  );
}
