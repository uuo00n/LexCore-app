import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lexcore/core/network/api_client.dart';
import 'package:lexcore/core/network/dio_provider.dart';
import 'package:lexcore/core/storage/local_storage.dart';
import 'package:lexcore/shared/models/legal_models.dart';

class HistoryRepository {
  HistoryRepository(this._apiClient, this._preferences);

  final ApiClient _apiClient;
  final SharedPreferences _preferences;

  static const _localHistoryStorageKey = 'history_records_local_v1';
  static const _maxLocalHistoryItems = 200;

  Future<List<HistoryItem>> loadAll() async {
    final localItems = _readLocalItems();
    final remoteItems = await _loadRemoteItems();

    final merged = <HistoryItem>[...remoteItems, ...localItems]
      ..sort((a, b) => b.time.compareTo(a.time));
    return merged;
  }

  Future<void> recordAnalysisViewed({
    required String articleCode,
    required String title,
  }) async {
    final normalizedCode = articleCode.trim();
    final normalizedTitle = title.trim();
    if (normalizedCode.isEmpty || normalizedTitle.isEmpty) {
      return;
    }

    await _upsertLocalItem(
      _StoredHistoryItem(
        id: 'local_analysis_$normalizedCode',
        title: normalizedTitle.contains(normalizedCode)
            ? normalizedTitle
            : '$normalizedTitle（$normalizedCode）',
        category: HistoryCategory.analysis,
        time: DateTime.now(),
        resourceKey: normalizedCode,
      ),
      replaceByResourceKey: true,
    );
  }

  Future<void> recordConsultationQuery({
    required String question,
    String? threadId,
  }) async {
    final normalizedQuestion = question.trim();
    if (normalizedQuestion.isEmpty) {
      return;
    }

    final shortened = normalizedQuestion.length <= 36
        ? normalizedQuestion
        : '${normalizedQuestion.substring(0, 36)}...';

    await _upsertLocalItem(
      _StoredHistoryItem(
        id: 'local_consultation_${DateTime.now().microsecondsSinceEpoch}',
        title: shortened,
        category: HistoryCategory.consultation,
        time: DateTime.now(),
        resourceKey: threadId?.trim().isEmpty == true ? null : threadId?.trim(),
      ),
    );
  }

  static HistoryCategory _categoryFromEventType(String eventType) {
    if (eventType.contains('document') || eventType.contains('pdf')) {
      return HistoryCategory.document;
    }
    if (eventType.contains('search') || eventType.contains('analysis')) {
      return HistoryCategory.analysis;
    }
    return HistoryCategory.consultation;
  }

  Future<List<HistoryItem>> _loadRemoteItems() async {
    try {
      final result = await _apiClient.get<Map<String, dynamic>>(
        '/history',
        queryParameters: const {'offset': 0, 'limit': 100},
        decoder: (data) => (data as Map?)?.cast<String, dynamic>() ?? const {},
      );

      final items = (result['items'] as List?) ?? const [];
      return items
          .whereType<Map>()
          .map((item) {
            final map = item.cast<String, dynamic>();
            final eventType = map['event_type'] as String? ?? '';
            return HistoryItem(
              id: map['history_id'] as String? ?? '',
              title: map['event_summary'] as String? ?? '',
              category: _categoryFromEventType(eventType),
              time:
                  DateTime.tryParse(map['created_at'] as String? ?? '') ??
                  DateTime.fromMillisecondsSinceEpoch(0),
              resourceKey: _resolveRemoteResourceKey(map),
            );
          })
          .where((item) => item.title.trim().isNotEmpty)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  List<HistoryItem> _readLocalItems() {
    final raw = _preferences.getString(_localHistoryStorageKey);
    if (raw == null || raw.trim().isEmpty) {
      return const [];
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return const [];
      }

      return decoded
          .whereType<Map>()
          .map(
            (item) => _StoredHistoryItem.fromJson(item.cast<String, dynamic>()),
          )
          .map((item) => item.toHistoryItem())
          .where((item) => item.title.trim().isNotEmpty)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> _upsertLocalItem(
    _StoredHistoryItem item, {
    bool replaceByResourceKey = false,
  }) async {
    final items = _readStoredLocalItems();
    final updated = <_StoredHistoryItem>[];

    for (final existing in items) {
      final sameId = existing.id == item.id;
      final sameResource =
          replaceByResourceKey &&
          existing.category == item.category &&
          existing.resourceKey != null &&
          existing.resourceKey == item.resourceKey;
      if (sameId || sameResource) {
        continue;
      }
      updated.add(existing);
    }

    updated.insert(0, item);
    final trimmed = updated.take(_maxLocalHistoryItems).toList(growable: false);
    await _preferences.setString(
      _localHistoryStorageKey,
      jsonEncode(trimmed.map((entry) => entry.toJson()).toList()),
    );
  }

  List<_StoredHistoryItem> _readStoredLocalItems() {
    final raw = _preferences.getString(_localHistoryStorageKey);
    if (raw == null || raw.trim().isEmpty) {
      return const [];
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return const [];
      }
      return decoded
          .whereType<Map>()
          .map(
            (item) => _StoredHistoryItem.fromJson(item.cast<String, dynamic>()),
          )
          .toList();
    } catch (_) {
      return const [];
    }
  }
}

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  return HistoryRepository(
    ref.watch(apiClientProvider),
    ref.watch(sharedPreferencesProvider),
  );
});

class _StoredHistoryItem {
  const _StoredHistoryItem({
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

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category.name,
      'time': time.toIso8601String(),
      'resourceKey': resourceKey,
    };
  }

  HistoryItem toHistoryItem() {
    return HistoryItem(
      id: id,
      title: title,
      category: category,
      time: time,
      resourceKey: resourceKey,
    );
  }

  factory _StoredHistoryItem.fromJson(Map<String, dynamic> json) {
    final categoryName = json['category'] as String? ?? '';
    return _StoredHistoryItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      category: HistoryCategory.values.firstWhere(
        (item) => item.name == categoryName,
        orElse: () => HistoryCategory.consultation,
      ),
      time:
          DateTime.tryParse(json['time'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      resourceKey: json['resourceKey'] as String?,
    );
  }
}

String? _resolveRemoteResourceKey(Map<String, dynamic> data) {
  const keyCandidates = [
    'resource_key',
    'resourceKey',
    'thread_id',
    'threadId',
    'article_code',
    'articleCode',
    'document_id',
    'documentId',
    'target_id',
    'targetId',
  ];

  for (final key in keyCandidates) {
    final value = data[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
  }
  return null;
}
