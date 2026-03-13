import 'package:lexcore/features/search/domain/entities/search_state.dart';
import 'package:lexcore/shared/models/legal_models.dart';
import 'package:lexcore/shared/services/mock/mock_legal_repository.dart';

class SearchRepository {
  const SearchRepository(this._mock);

  final MockLegalRepository _mock;

  List<String> hotKeywords() => _mock.hotKeywords();

  List<LawSearchItem> hotSearchArticles() => _mock.searchResults();

  List<SearchScenarioGroup> searchScenarioGroups() =>
      _mock.searchScenarioGroups();

  List<LawSearchItem> search(String keyword) {
    final all = _mock.searchResults();
    if (keyword.trim().isEmpty) return all;
    return all
        .where(
          (item) =>
              item.title.contains(keyword) || item.snippet.contains(keyword),
        )
        .toList();
  }

  LawArticleDetail articleDetail([LawSearchItem? item]) {
    if (item == null) {
      return const LawArticleDetail(
        title: '法律条文详情',
        tags: ['法规解读', '默认详情'],
        author: 'LexCore 法律研究',
        publishInfo: '2026年3月9日 · 5分钟阅读',
        summary: '当前未传入具体搜索结果，已为您展示默认法条解读内容。',
        quote: '准确匹配搜索结果并传递上下文，是详情页稳定渲染的前提。',
        content: '请选择一条搜索结果查看详细内容。',
        citations: [
          LawCitationItem(title: '搜索结果上下文缺失', subtitle: '建议从搜索列表重新进入详情页'),
        ],
      );
    }

    return LawArticleDetail(
      title: item.title,
      tags: ['法律法规', item.articleCode],
      author: 'LexCore 法律研究',
      publishInfo: '2026年3月9日 · 6分钟阅读',
      summary: '围绕“${item.title}”整理了适用要点、常见争议焦点与维权建议，便于快速查看法条含义。',
      quote: item.snippet,
      content:
          '''
法条编号：${item.articleCode}

核心内容：
${item.snippet}

适用说明：
1. 该条款通常用于判断劳动关系、工资支付或争议处理中的基础义务。
2. 实务中建议同时结合劳动合同、工资流水、考勤记录等证据综合判断。
3. 如果进入仲裁或诉讼程序，应进一步核对当地裁审口径与最新规范性文件。
''',
      citations: [
        LawCitationItem(title: item.title, subtitle: item.snippet),
        LawCitationItem(title: '相关条文延伸', subtitle: '可继续结合相邻条款、实施条例与地方裁审意见交叉核对'),
      ],
    );
  }
}
