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
    required this.category,
    this.resourceKey,
  });

  final String title;
  final DateTime time;
  final HistoryCategory category;
  final String? resourceKey;

  String get tag {
    return switch (category) {
      HistoryCategory.consultation => '咨询',
      HistoryCategory.analysis => '分析',
      HistoryCategory.document => '文档',
    };
  }
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
  const DocumentDraft({
    required this.title,
    required this.markdown,
    this.docType = '法律文书',
    this.userInput = '',
    this.templateParams = const <String, Object?>{},
  });

  final String title;
  final String markdown;
  final String docType;
  final String userInput;
  final Map<String, Object?> templateParams;
}

enum DocumentSaveResult { created, updated }

class DocumentSaveOutcome {
  const DocumentSaveOutcome({
    required this.result,
    required this.documentId,
    required this.status,
  });

  final DocumentSaveResult result;
  final String documentId;
  final String status;
}

class DocumentItem {
  const DocumentItem({
    required this.id,
    required this.name,
    required this.updatedAt,
    required this.type,
    this.markdown = '',
    this.status = 'completed',
    this.errorMessage,
  });

  final String id;
  final String name;
  final DateTime updatedAt;
  final String type;
  final String markdown;
  final String status;
  final String? errorMessage;

  DocumentItem copyWith({
    String? id,
    String? name,
    DateTime? updatedAt,
    String? type,
    String? markdown,
    String? status,
    String? errorMessage,
  }) {
    return DocumentItem(
      id: id ?? this.id,
      name: name ?? this.name,
      updatedAt: updatedAt ?? this.updatedAt,
      type: type ?? this.type,
      markdown: markdown ?? this.markdown,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'name': name,
      'updatedAt': updatedAt.toIso8601String(),
      'type': type,
      'markdown': markdown,
      'status': status,
      'errorMessage': errorMessage,
    };
  }

  factory DocumentItem.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String? ?? '';
    final type = json['type'] as String? ?? '';
    final normalizedMarkdown = (json['markdown'] as String? ?? '').trim();

    return DocumentItem(
      id: json['id'] as String? ?? '',
      name: name,
      updatedAt:
          DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      type: type,
      markdown: normalizedMarkdown.isEmpty
          ? _legacyDocumentMarkdownFallback(name: name, type: type)
          : normalizedMarkdown,
      status: json['status'] as String? ?? 'completed',
      errorMessage:
          json['errorMessage'] as String? ?? json['error_message'] as String?,
    );
  }
}

String _legacyDocumentMarkdownFallback({
  required String name,
  required String type,
}) {
  final resolvedName = name.trim().isEmpty ? '未命名文档' : name.trim();
  final resolvedType = type.trim().isEmpty ? '法律文书' : type.trim();
  return [
    '# $resolvedName',
    '',
    '> 文档类型：$resolvedType',
    '',
    '该文档来自旧版本保存记录，原始正文未完整保留。',
    '请进入编辑模式补充内容后重新保存。',
  ].join('\n');
}

class LawSearchItem {
  const LawSearchItem({
    required this.title,
    required this.snippet,
    required this.articleCode,
    this.resultType = SearchResultType.law,
    this.courtName,
    this.judgementDate,
    this.caseType,
  });

  final String title;
  final String snippet;
  final String articleCode;
  final SearchResultType resultType;
  final String? courtName;
  final String? judgementDate;
  final String? caseType;
}

enum SearchResultType { law, caseDoc }

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
    this.resourceKey,
  });

  final String id;
  final String title;
  final HistoryCategory category;
  final DateTime time;
  final String? resourceKey;
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
