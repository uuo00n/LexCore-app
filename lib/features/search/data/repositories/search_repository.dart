import 'package:lexcore/features/search/domain/entities/search_state.dart';
import 'package:lexcore/shared/models/legal_models.dart';
import 'package:lexcore/shared/services/mock/mock_legal_repository.dart';

class SearchRepository {
  const SearchRepository(this._mock);

  final MockLegalRepository _mock;

  List<String> hotKeywords() => _mock.hotKeywords();

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

  LawArticleDetail articleDetail() {
    return LawArticleDetail(
      title: '关于数字经济中反垄断法的适用研究：平台经济与数据主权',
      tags: const ['反垄断法', '深度解析'],
      author: '陈法官',
      publishInfo: '2023年10月24日 · 12分钟阅读',
      summary: '本文讨论数字经济下反垄断的三大焦点：相关市场界定、数据资产支配地位、算法共谋风险。',
      quote: '数据不仅是数字经济的原油，更是评估企业市场控制力的关键维度。',
      content: '''
第一条  为了保护劳动者的合法权益，调整劳动关系，建立和维护适应社会主义市场经济的劳动制度，制定本法。

第三十条  用人单位应当按照劳动合同约定和国家规定，向劳动者及时足额支付劳动报酬。

第八十五条  用人单位有下列情形之一的，由劳动行政部门责令限期支付劳动报酬、加班费或者经济补偿。
''',
      citations: const [
        LawCitationItem(
          title: '《中华人民共和国反垄断法》',
          subtitle: '第十七条：禁止具有市场支配地位的经营者...',
        ),
        LawCitationItem(title: '平台经济领域反垄断指南', subtitle: '2021年发布 · 指导性文件'),
      ],
    );
  }
}
