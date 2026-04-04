import 'package:lexcore/shared/models/legal_models.dart';

class SearchState {
  const SearchState({required this.keyword});

  final String keyword;
}

class SearchResultBundle {
  const SearchResultBundle({
    required this.items,
    this.degraded = false,
    this.noticeMessage,
  });

  final List<LawSearchItem> items;
  final bool degraded;
  final String? noticeMessage;
}

class LawArticleDetail {
  const LawArticleDetail({
    required this.title,
    required this.tags,
    required this.author,
    required this.publishInfo,
    required this.summary,
    required this.quote,
    required this.content,
    required this.bodySections,
    required this.citations,
    this.htmlUrl,
    this.docxUrl,
    this.sourceUrl,
    this.fallbackMessage,
  });

  final String title;
  final List<String> tags;
  final String author;
  final String publishInfo;
  final String summary;
  final String quote;
  final String content;
  final List<String> bodySections;
  final List<LawCitationItem> citations;
  final String? htmlUrl;
  final String? docxUrl;
  final String? sourceUrl;
  final String? fallbackMessage;
}

class LawCitationItem {
  const LawCitationItem({required this.title, required this.subtitle});

  final String title;
  final String subtitle;
}
