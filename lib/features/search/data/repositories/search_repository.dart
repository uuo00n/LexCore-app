import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lexcore/core/error/app_exception.dart';
import 'package:lexcore/core/network/api_client.dart';
import 'package:lexcore/core/network/dio_provider.dart';
import 'package:lexcore/features/history/data/repositories/history_repository.dart';
import 'package:lexcore/features/search/domain/entities/search_state.dart';
import 'package:lexcore/shared/config/static_ui_config.dart';
import 'package:lexcore/shared/models/legal_models.dart';

enum _SearchFilterMode { catalogLaws, upstreamCases }

class _SearchFilterConfig {
  const _SearchFilterConfig.catalog(this.label, {this.category})
    : mode = _SearchFilterMode.catalogLaws;

  const _SearchFilterConfig.cases(this.label)
    : mode = _SearchFilterMode.upstreamCases,
      category = null;

  final String label;
  final _SearchFilterMode mode;
  final String? category;
}

class SearchRepository {
  const SearchRepository(this._apiClient, [this._historyRepository]);

  static const int _upstreamSearchPageSize = 10;
  static const List<_SearchFilterConfig> _searchFilters = [
    _SearchFilterConfig.catalog('全部'),
    _SearchFilterConfig.cases('裁判文书'),
    _SearchFilterConfig.catalog('地方性法规', category: '地方性法规'),
    _SearchFilterConfig.catalog('行政法规', category: '行政法规'),
    _SearchFilterConfig.catalog('司法解释', category: '司法解释'),
    _SearchFilterConfig.catalog('法律', category: '法律'),
    _SearchFilterConfig.catalog('部门规章', category: '部门规章'),
    _SearchFilterConfig.catalog('宪法', category: '宪法'),
  ];

  final ApiClient _apiClient;
  final HistoryRepository? _historyRepository;

  List<String> hotKeywords() => StaticUiConfig.hotKeywords;
  List<String> searchFilterLabels() =>
      _searchFilters.map((filter) => filter.label).toList(growable: false);

  List<SearchScenarioGroup> searchScenarioGroups() =>
      StaticUiConfig.searchScenarioGroups;

  Future<SearchResultBundle> search(
    String keyword, {
    required int filterIndex,
  }) async {
    final normalizedKeyword = keyword.trim();
    final resolvedFilter = _resolveSearchFilter(filterIndex);
    if (resolvedFilter.mode == _SearchFilterMode.upstreamCases) {
      return _searchUpstreamCases(normalizedKeyword);
    }
    return SearchResultBundle(
      items: await _searchCatalogLaws(
        normalizedKeyword,
        category: resolvedFilter.category,
      ),
    );
  }

  Future<LawArticleDetail> articleDetail([LawSearchItem? item]) async {
    if (item == null || item.articleCode.trim().isEmpty) {
      return const LawArticleDetail(
        title: '法律条文详情',
        tags: ['法规解读', '默认详情'],
        author: 'LexCore 法律研究',
        publishInfo: '最新',
        summary: '请选择一条法规查看详情。',
        quote: '法规详情将展示法条基础信息与下载入口。',
        content: '请选择一条搜索结果查看详细内容。',
        bodySections: ['请选择一条搜索结果查看详细内容。'],
        citations: [
          LawCitationItem(title: '提示', subtitle: '从法规检索列表进入详情页可查看完整信息'),
        ],
        fallbackMessage: '请选择一条搜索结果查看详细内容。',
      );
    }

    final detail = await _apiClient.get<Map<String, dynamic>>(
      '/laws/${item.articleCode}',
      decoder: (data) => (data as Map?)?.cast<String, dynamic>() ?? const {},
    );

    final title = detail['title'] as String? ?? item.title;
    final category = detail['category'] as String? ?? '';
    final issuingAuthority = detail['issuing_authority'] as String? ?? '';
    final status = detail['effective_status'] as String? ?? '';
    final publishDate = detail['publish_date'] as String? ?? '';
    final bodySections = _resolveBodySections(detail);
    final htmlUrl = _resolveUrl(detail, const [
      'html_url',
      'html_download_url',
      'htmlUrl',
      'html_link',
      'htmlLink',
      'html_path',
    ]);
    final docxUrl = _resolveUrl(detail, const [
      'docx_url',
      'docx_download_url',
      'docxUrl',
      'docx_link',
      'docxLink',
      'download_url',
      'downloadUrl',
    ]);
    final pdfUrl = _resolveUrl(detail, const [
      'pdf_url',
      'pdf_download_url',
      'pdfUrl',
      'pdf_link',
      'pdfLink',
    ]);
    final sourceUrl = _resolveUrl(detail, const [
      'source_url',
      'sourceUrl',
      'source_link',
      'sourceLink',
      'url',
      'link',
    ]);
    final fallbackMessage = bodySections.isEmpty
        ? [
            '暂未获取到法规正文。',
            if (htmlUrl == null &&
                docxUrl == null &&
                pdfUrl == null &&
                sourceUrl == null)
              '当前仅展示法规基础信息，请稍后重试或更换结果。',
          ].join()
        : null;
    final bodyContent = bodySections.isNotEmpty
        ? bodySections.join('\n\n')
        : '''
法规标题：$title
法规分类：${category.isEmpty ? '未标注' : category}
发布机关：${issuingAuthority.isEmpty ? '未标注' : issuingAuthority}
状态：${status.isEmpty ? '未标注' : status}

${fallbackMessage ?? '暂无正文内容。'}''';
    final resolvedDetail = LawArticleDetail(
      title: title,
      tags: [if (category.isNotEmpty) category, item.articleCode],
      author: issuingAuthority.isEmpty ? '发布机关待补充' : issuingAuthority,
      publishInfo: publishDate.isEmpty ? '发布日期待补充' : publishDate,
      summary:
          '该法规当前状态为${status.isEmpty ? '待补充' : status}，建议结合业务场景重点核对适用范围与时间效力。',
      quote: item.snippet,
      content: bodyContent,
      bodySections: bodySections,
      citations: [
        LawCitationItem(title: '法规 ID', subtitle: item.articleCode),
        LawCitationItem(
          title: '法规状态',
          subtitle: status.isEmpty ? '未标注' : status,
        ),
        if (htmlUrl != null)
          const LawCitationItem(title: 'HTML 原文', subtitle: '可打开网页查看法规全文'),
        if (pdfUrl != null)
          const LawCitationItem(title: 'PDF 下载', subtitle: '可下载法规 PDF 副本'),
        if (docxUrl != null)
          const LawCitationItem(title: 'DOCX 下载', subtitle: '可下载法规文档副本'),
        if (sourceUrl != null)
          const LawCitationItem(title: '来源页面', subtitle: '可前往原始来源继续查看'),
      ],
      htmlUrl: htmlUrl,
      docxUrl: docxUrl,
      pdfUrl: pdfUrl,
      sourceUrl: sourceUrl,
      fallbackMessage: fallbackMessage,
    );

    await _historyRepository?.recordAnalysisViewed(
      articleCode: item.articleCode,
      title: resolvedDetail.title,
    );

    return resolvedDetail;
  }

  _SearchFilterConfig _resolveSearchFilter(int filterIndex) {
    if (filterIndex >= 0 && filterIndex < _searchFilters.length) {
      return _searchFilters[filterIndex];
    }
    return _searchFilters.first;
  }

  Future<List<LawSearchItem>> _searchCatalogLaws(
    String keyword, {
    String? category,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/laws',
      queryParameters: {
        if (keyword.isNotEmpty) 'keyword': keyword,
        if (category != null && category.trim().isNotEmpty)
          'category': category.trim(),
        'offset': 0,
        'limit': 50,
      },
      decoder: (data) => (data as Map?)?.cast<String, dynamic>() ?? const {},
    );

    final items = (response['items'] as List?) ?? const [];
    return items.whereType<Map>().map((item) {
      final map = item.cast<String, dynamic>();
      final id = map['id'] as String? ?? '';
      final category = map['category'] as String? ?? '';
      final authority = map['issuing_authority'] as String? ?? '';
      final status = map['effective_status'] as String? ?? '';
      return LawSearchItem(
        title: map['title'] as String? ?? '',
        snippet: [
          category,
          authority,
          status,
        ].where((value) => value.trim().isNotEmpty).join(' · '),
        articleCode: id,
        resultType: SearchResultType.law,
      );
    }).toList();
  }

  Future<SearchResultBundle> _searchUpstreamCases(String keyword) async {
    if (keyword.isEmpty) {
      return SearchResultBundle(
        items: const [],
        degraded: true,
        noticeMessage: '请输入关键词后再进行裁判文书检索。',
      );
    }

    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/search/cases',
        data: _buildCaseSearchPayload(keyword),
        decoder: (data) => (data as Map?)?.cast<String, dynamic>() ?? const {},
      );
      final items = _extractUpstreamItems(response).map((item) {
        final title =
            item['caseName'] as String? ??
            item['title'] as String? ??
            item['name'] as String? ??
            '裁判文书检索结果';
        final code =
            item['caseNo'] as String? ??
            item['caseId'] as String? ??
            item['id'] as String? ??
            title.hashCode.toString();
        final snippet = [
          item['courtName'] as String? ?? '',
          item['judgementDate'] as String? ?? '',
          item['caseType'] as String? ?? '',
        ].where((value) => value.trim().isNotEmpty).join(' · ');

        return LawSearchItem(
          title: title,
          snippet: snippet.isEmpty ? '来自裁判文书检索' : snippet,
          articleCode: code,
          resultType: SearchResultType.caseDoc,
          courtName: item['courtName'] as String?,
          judgementDate: item['judgementDate'] as String?,
          caseType: item['caseType'] as String?,
        );
      }).toList();
      return SearchResultBundle(items: items);
    } on AppException {
      return SearchResultBundle(
        items: await _searchCatalogLaws(keyword),
        degraded: true,
        noticeMessage: '裁判文书检索暂不可用（503），已自动降级为法规库检索。',
      );
    }
  }

  Map<String, dynamic> _buildCaseSearchPayload(String keyword) {
    return {
      'pageNo': 1,
      'pageSize': _upstreamSearchPageSize,
      'sortField': 'correlation',
      'sortOrder': 'desc',
      'condition': {
        'keywordArr': [keyword],
      },
    };
  }

  List<Map<String, dynamic>> _extractUpstreamItems(
    Map<String, dynamic> response,
  ) {
    final body =
        (response['body'] as Map?)?.cast<String, dynamic>() ?? const {};
    final data = (body['data'] as List?) ?? const [];
    return data
        .whereType<Map>()
        .map((item) => item.cast<String, dynamic>())
        .toList();
  }

  List<String> _resolveBodySections(Map<String, dynamic> detail) {
    final list = _resolveStringList(detail, const [
      'body_sections',
      'bodySections',
      'sections',
      'paragraphs',
      'articles',
    ]);
    if (list.isNotEmpty) {
      return list;
    }

    final rawContent = _resolveString(detail, const [
      'content',
      'full_text',
      'fullText',
      'body',
      'text',
      'original_text',
      'originalText',
    ]);
    if (rawContent == null) {
      return const [];
    }

    return rawContent
        .split(RegExp(r'\n\s*\n'))
        .map((section) => section.trim())
        .where((section) => section.isNotEmpty)
        .toList();
  }

  List<String> _resolveStringList(
    Map<String, dynamic> detail,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = detail[key];
      if (value is List) {
        final resolved = value
            .map((item) {
              if (item is String) {
                return item.trim();
              }
              if (item is Map) {
                final map = item.cast<String, dynamic>();
                return _resolveString(map, const [
                  'content',
                  'text',
                  'body',
                  'value',
                  'title',
                ]);
              }
              return null;
            })
            .whereType<String>()
            .where((item) => item.isNotEmpty)
            .toList();
        if (resolved.isNotEmpty) {
          return resolved;
        }
      }
    }
    return const [];
  }

  String? _resolveUrl(Map<String, dynamic> detail, List<String> keys) {
    final value = _resolveString(detail, keys);
    if (value == null) {
      return null;
    }
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasScheme || value.trim().isEmpty) {
      return null;
    }
    return value;
  }

  String? _resolveString(Map<String, dynamic> detail, List<String> keys) {
    for (final key in keys) {
      final value = detail[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return null;
  }
}

final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  return SearchRepository(
    ref.watch(apiClientProvider),
    ref.watch(historyRepositoryProvider),
  );
});
