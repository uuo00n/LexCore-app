import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:lexcore/shared/models/legal_models.dart';
import 'package:lexcore/shared/services/mock/mock_legal_repository.dart';

class DocumentRepository {
  const DocumentRepository(this._mock);

  static const _storageKey = 'saved_documents_v1';

  final MockLegalRepository _mock;

  DocumentDraft generatePreview() => _mock.generatedDraft();

  Future<List<DocumentItem>> loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);

    if (raw == null || raw.isEmpty) {
      return _sortDocuments(_mock.savedDocuments());
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return _sortDocuments(_mock.savedDocuments());
      }

      final documents = decoded
          .whereType<Map>()
          .map((item) => DocumentItem.fromJson(Map<String, dynamic>.from(item)))
          .toList(growable: false);
      return _sortDocuments(documents);
    } catch (_) {
      return _sortDocuments(_mock.savedDocuments());
    }
  }

  Future<DocumentSaveResult> saveDraft(DocumentDraft draft) async {
    final currentDocuments = await loadSaved();
    final now = DateTime.now();
    final resolvedTitle = _resolveTitle(draft.title);
    final existingIndex = currentDocuments.indexWhere(
      (item) => item.name.trim() == resolvedTitle,
    );

    final nextDocuments = [...currentDocuments];
    DocumentSaveResult result;
    if (existingIndex >= 0) {
      final existing = nextDocuments[existingIndex];
      nextDocuments[existingIndex] = existing.copyWith(
        name: resolvedTitle,
        updatedAt: now,
        type: _resolveType(resolvedTitle, fallbackType: existing.type),
        markdown: _resolveMarkdown(draft.markdown, fallback: existing.markdown),
      );
      result = DocumentSaveResult.updated;
    } else {
      nextDocuments.add(
        DocumentItem(
          id: 'doc_${now.microsecondsSinceEpoch}',
          name: resolvedTitle,
          updatedAt: now,
          type: _resolveType(resolvedTitle),
          markdown: _resolveMarkdown(draft.markdown),
        ),
      );
      result = DocumentSaveResult.created;
    }

    final sortedDocuments = _sortDocuments(nextDocuments);
    await _persistDocuments(sortedDocuments);
    return result;
  }

  Future<DocumentItem?> loadById(String id) async {
    final normalizedId = id.trim();
    if (normalizedId.isEmpty) {
      return null;
    }

    final documents = await loadSaved();
    for (final item in documents) {
      if (item.id == normalizedId) {
        return item;
      }
    }
    return null;
  }

  Future<DocumentItem?> updateDocument({
    required String id,
    required String title,
    required String markdown,
  }) async {
    final normalizedId = id.trim();
    if (normalizedId.isEmpty) {
      return null;
    }

    final documents = await loadSaved();
    final index = documents.indexWhere((item) => item.id == normalizedId);
    if (index < 0) {
      return null;
    }

    final current = documents[index];
    final resolvedTitle = _resolveTitle(title);
    final updated = current.copyWith(
      name: resolvedTitle,
      markdown: _resolveMarkdown(markdown, fallback: current.markdown),
      updatedAt: DateTime.now(),
      type: _resolveType(resolvedTitle, fallbackType: current.type),
    );

    final nextDocuments = [...documents]..[index] = updated;
    final sorted = _sortDocuments(nextDocuments);
    await _persistDocuments(sorted);

    for (final item in sorted) {
      if (item.id == normalizedId) {
        return item;
      }
    }
    return updated;
  }

  String _resolveTitle(String title) {
    final normalized = title.trim();
    return normalized.isEmpty ? '未命名文档' : normalized;
  }

  String _resolveMarkdown(String markdown, {String? fallback}) {
    final normalized = markdown.trim();
    if (normalized.isNotEmpty) {
      return normalized;
    }
    final normalizedFallback = fallback?.trim() ?? '';
    if (normalizedFallback.isNotEmpty) {
      return normalizedFallback;
    }
    return '# 未命名文档\n\n请补充正文内容。';
  }

  String _resolveType(String title, {String? fallbackType}) {
    if (title.contains('律师函')) {
      return '律师函';
    }
    if (title.contains('申请书') || title.contains('仲裁')) {
      return '仲裁文书';
    }
    if (title.contains('审查') || title.contains('意见')) {
      return '审查意见';
    }
    final normalizedFallback = fallbackType?.trim() ?? '';
    if (normalizedFallback.isNotEmpty) {
      return normalizedFallback;
    }
    return '法律文书';
  }

  List<DocumentItem> _sortDocuments(List<DocumentItem> documents) {
    final sorted = [...documents];
    sorted.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sorted;
  }

  Future<void> _persistDocuments(List<DocumentItem> documents) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(documents.map((item) => item.toJson()).toList()),
    );
  }
}
