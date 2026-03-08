class SearchState {
  const SearchState({required this.keyword});

  final String keyword;
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
    required this.citations,
  });

  final String title;
  final List<String> tags;
  final String author;
  final String publishInfo;
  final String summary;
  final String quote;
  final String content;
  final List<LawCitationItem> citations;
}

class LawCitationItem {
  const LawCitationItem({required this.title, required this.subtitle});

  final String title;
  final String subtitle;
}
