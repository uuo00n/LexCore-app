import 'dart:convert';
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lexcore/core/network/api_client.dart';
import 'package:lexcore/core/network/dio_provider.dart';
import 'package:lexcore/core/storage/local_storage.dart';
import 'package:lexcore/shared/models/legal_models.dart';

class DocumentRepository {
  DocumentRepository(this._apiClient, this._preferences);

  final ApiClient _apiClient;
  final SharedPreferences _preferences;

  static const _localEditsStorageKey = 'saved_documents_local_edits_v2';

  DocumentDraft generatePreview() {
    return const DocumentDraft(title: '未命名文档', markdown: '');
  }

  Future<List<DocumentItem>> loadSaved() async {
    final data = await _apiClient.get<Map<String, dynamic>>(
      '/documents',
      queryParameters: const {'offset': 0, 'limit': 100},
      decoder: (value) => (value as Map?)?.cast<String, dynamic>() ?? const {},
    );
    final items = (data['items'] as List?) ?? const [];
    final localEdits = _readLocalEdits();
    return items.whereType<Map>().map((item) {
      final map = item.cast<String, dynamic>();
      final id = map['document_id'] as String? ?? '';
      final local = localEdits[id] ?? const {};
      final title = local['title'] as String? ?? map['title'] as String? ?? '';
      final markdown =
          local['markdown'] as String? ?? map['content_markdown'] as String?;
      final updatedAt =
          DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0);
      final docType = map['doc_type'] as String? ?? '法律文书';
      return DocumentItem(
        id: id,
        name: title,
        updatedAt: updatedAt,
        type: docType,
        markdown: _resolveMarkdown(markdown),
        status: map['status'] as String? ?? 'queued',
      );
    }).toList()..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<DocumentSaveResult> saveDraft(DocumentDraft draft) async {
    await _apiClient.post<Map<String, dynamic>>(
      '/documents/generate',
      data: {
        'title': _resolveTitle(draft.title),
        'doc_type': _resolveType(draft.title),
        'prompt': _resolveMarkdown(draft.markdown),
      },
      decoder: (value) => (value as Map?)?.cast<String, dynamic>() ?? const {},
    );
    return DocumentSaveResult.created;
  }

  Future<DocumentItem?> loadById(String id) async {
    final normalizedId = id.trim();
    if (normalizedId.isEmpty) {
      return null;
    }
    final data = await _apiClient.get<Map<String, dynamic>>(
      '/documents/$normalizedId',
      decoder: (value) => (value as Map?)?.cast<String, dynamic>() ?? const {},
    );
    final localEdits = _readLocalEdits()[normalizedId] ?? const {};
    final title =
        localEdits['title'] as String? ?? data['title'] as String? ?? '';
    final markdown =
        localEdits['markdown'] as String? ??
        data['content_markdown'] as String?;
    return DocumentItem(
      id: data['document_id'] as String? ?? normalizedId,
      name: title,
      updatedAt:
          DateTime.tryParse(data['created_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      type: data['doc_type'] as String? ?? '法律文书',
      markdown: _resolveMarkdown(markdown),
      status: data['status'] as String? ?? 'queued',
    );
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

    final current = await loadById(normalizedId);
    if (current == null) {
      return null;
    }

    final updates = _readLocalEdits();
    updates[normalizedId] = {
      'title': _resolveTitle(title),
      'markdown': _resolveMarkdown(markdown),
    };
    await _preferences.setString(_localEditsStorageKey, jsonEncode(updates));

    return current.copyWith(
      name: _resolveTitle(title),
      markdown: _resolveMarkdown(markdown),
      updatedAt: DateTime.now(),
    );
  }

  Future<DocumentPdfExportResult> exportPdf(
    String documentId, {
    int maxPollAttempts = 20,
    Duration pollInterval = const Duration(seconds: 2),
  }) async {
    final normalizedId = documentId.trim();
    if (normalizedId.isEmpty) {
      return const DocumentPdfExportResult(
        completed: false,
        status: 'failed',
        errorMessage: '文档 ID 为空，无法导出 PDF',
      );
    }

    final exportTask = await _apiClient.post<Map<String, dynamic>>(
      '/pdf/export',
      data: {'document_id': normalizedId},
      decoder: (value) => (value as Map?)?.cast<String, dynamic>() ?? const {},
    );

    final taskId = exportTask['task_id'] as String? ?? '';
    var status = exportTask['status'] as String? ?? 'queued';
    String? fileId = exportTask['file_id'] as String?;
    String? errorMessage = exportTask['error_message'] as String?;

    if (taskId.trim().isEmpty) {
      return const DocumentPdfExportResult(
        completed: false,
        status: 'failed',
        errorMessage: 'PDF 任务创建失败（task_id 为空）',
      );
    }

    for (var attempt = 0; attempt < maxPollAttempts; attempt++) {
      if (status == 'completed' || status == 'failed') {
        break;
      }
      await Future<void>.delayed(pollInterval);
      final taskInfo = await _apiClient.get<Map<String, dynamic>>(
        '/pdf/tasks/$taskId',
        decoder: (value) =>
            (value as Map?)?.cast<String, dynamic>() ?? const {},
      );
      status = taskInfo['status'] as String? ?? status;
      fileId = taskInfo['file_id'] as String? ?? fileId;
      errorMessage = taskInfo['error_message'] as String? ?? errorMessage;
    }

    if (status != 'completed') {
      return DocumentPdfExportResult(
        completed: false,
        taskId: taskId,
        status: status,
        errorMessage: errorMessage ?? 'PDF 导出超时，请稍后重试',
      );
    }

    if (fileId == null || fileId.trim().isEmpty) {
      return DocumentPdfExportResult(
        completed: false,
        taskId: taskId,
        status: 'failed',
        errorMessage: 'PDF 导出完成但未返回 file_id',
      );
    }

    final downloadData = await _apiClient.get<Map<String, dynamic>>(
      '/pdf/download/$fileId',
      decoder: (value) => (value as Map?)?.cast<String, dynamic>() ?? const {},
    );
    final downloadUrl = downloadData['download_url'] as String?;
    if (downloadUrl == null || downloadUrl.trim().isEmpty) {
      return DocumentPdfExportResult(
        completed: false,
        taskId: taskId,
        fileId: fileId,
        status: 'failed',
        errorMessage: 'PDF 下载地址为空',
      );
    }

    return DocumentPdfExportResult(
      completed: true,
      taskId: taskId,
      fileId: fileId,
      status: status,
      downloadUrl: downloadUrl,
    );
  }

  Map<String, Map<String, dynamic>> _readLocalEdits() {
    final raw = _preferences.getString(_localEditsStorageKey);
    if (raw == null || raw.trim().isEmpty) {
      return {};
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return {};
      }
      final result = <String, Map<String, dynamic>>{};
      decoded.forEach((key, value) {
        if (key is String && value is Map) {
          result[key] = value.cast<String, dynamic>();
        }
      });
      return result;
    } catch (_) {
      return {};
    }
  }

  String _resolveTitle(String title) {
    final normalized = title.trim();
    return normalized.isEmpty ? '未命名文档' : normalized;
  }

  String _resolveMarkdown(String? markdown) {
    return markdown?.trim() ?? '';
  }

  String _resolveType(String title) {
    if (title.contains('律师函')) {
      return '律师函';
    }
    if (title.contains('申请书') || title.contains('仲裁')) {
      return '仲裁文书';
    }
    if (title.contains('审查') || title.contains('意见')) {
      return '审查意见';
    }
    return '法律文书';
  }
}

class DocumentPdfExportResult {
  const DocumentPdfExportResult({
    required this.completed,
    required this.status,
    this.taskId,
    this.fileId,
    this.downloadUrl,
    this.errorMessage,
  });

  final bool completed;
  final String status;
  final String? taskId;
  final String? fileId;
  final String? downloadUrl;
  final String? errorMessage;
}

final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  return DocumentRepository(
    ref.watch(apiClientProvider),
    ref.watch(sharedPreferencesProvider),
  );
});
