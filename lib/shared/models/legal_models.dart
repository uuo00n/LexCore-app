enum ChatRole { user, assistant }

enum HistoryCategory { consultation, analysis, document }

class QuickAction {
  const QuickAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
  });

  final String title;
  final String subtitle;
  final String icon;
  final String route;
}

class ActivityRecord {
  const ActivityRecord({
    required this.title,
    required this.time,
    required this.tag,
  });

  final String title;
  final DateTime time;
  final String tag;
}

class ConsultationSession {
  const ConsultationSession({
    required this.id,
    required this.title,
    required this.preview,
    required this.updatedAt,
    this.icon = 'smart_toy',
    this.isActive = false,
  });

  final String id;
  final String title;
  final String preview;
  final DateTime updatedAt;
  final String icon;
  final bool isActive;

  ConsultationSession copyWith({
    String? id,
    String? title,
    String? preview,
    DateTime? updatedAt,
    String? icon,
    bool? isActive,
  }) {
    return ConsultationSession(
      id: id ?? this.id,
      title: title ?? this.title,
      preview: preview ?? this.preview,
      updatedAt: updatedAt ?? this.updatedAt,
      icon: icon ?? this.icon,
      isActive: isActive ?? this.isActive,
    );
  }
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    this.references = const [],
  });

  final String id;
  final ChatRole role;
  final String content;
  final List<String> references;
}

class AnalysisMetric {
  const AnalysisMetric({required this.label, required this.value});

  final String label;
  final String value;
}

class RiskAlert {
  const RiskAlert({
    required this.level,
    required this.title,
    required this.description,
  });

  final String level;
  final String title;
  final String description;
}

class DocumentDraft {
  const DocumentDraft({required this.title, required this.markdown});

  final String title;
  final String markdown;
}

class DocumentItem {
  const DocumentItem({
    required this.id,
    required this.name,
    required this.updatedAt,
    required this.type,
  });

  final String id;
  final String name;
  final DateTime updatedAt;
  final String type;
}

class LawSearchItem {
  const LawSearchItem({
    required this.title,
    required this.snippet,
    required this.articleCode,
  });

  final String title;
  final String snippet;
  final String articleCode;
}

class SearchScenarioItem {
  const SearchScenarioItem({
    required this.id,
    required this.label,
    required this.keyword,
  });

  final String id;
  final String label;
  final String keyword;
}

class SearchScenarioGroup {
  const SearchScenarioGroup({required this.title, required this.items});

  final String title;
  final List<SearchScenarioItem> items;
}

class HistoryItem {
  const HistoryItem({
    required this.id,
    required this.title,
    required this.category,
    required this.time,
  });

  final String id;
  final String title;
  final HistoryCategory category;
  final DateTime time;
}

class ProfileMenuItem {
  const ProfileMenuItem({
    required this.title,
    required this.icon,
    required this.route,
  });

  final String title;
  final String icon;
  final String route;
}

class SettingItem {
  const SettingItem({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String icon;
}
