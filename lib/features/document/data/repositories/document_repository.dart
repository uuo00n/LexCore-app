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
  static const String _laborArbitrationType = '劳动仲裁';
  static const String _lawyerLetterType = '律师函';

  DocumentDraft generatePreview() {
    return const DocumentDraft(
      title: '劳动仲裁申请书（草稿）',
      docType: _laborArbitrationType,
      markdown:
          '# 劳动仲裁申请书（草稿）\n\n'
          '## 申请事项\n\n'
          '1. 请求裁令被申请人支付拖欠工资。\n'
          '2. 请求裁令被申请人承担仲裁费用。\n\n'
          '## 证据目录\n\n'
          '![证据材料示意（非真实图片）](lexcore://evidence-info-card)\n',
    );
  }

  Future<List<DocumentItem>> loadSaved() async {
    final data = await _apiClient.get<Map<String, dynamic>>(
      '/documents',
      queryParameters: const {'offset': 0, 'limit': 100},
      decoder: (value) => (value as Map?)?.cast<String, dynamic>() ?? const {},
    );
    final items = (data['items'] as List?) ?? const [];
    return items.whereType<Map>().map((item) {
      final map = item.cast<String, dynamic>();
      final id = map['document_id'] as String? ?? '';
      final title = map['title'] as String? ?? '';
      final markdown = _resolveRemoteMarkdown(map);
      final updatedAt =
          DateTime.tryParse(
            map['updated_at'] as String? ?? map['created_at'] as String? ?? '',
          ) ??
          DateTime.fromMillisecondsSinceEpoch(0);
      final docType = _normalizeDocumentTypeForRead(map['doc_type'] as String?);
      return DocumentItem(
        id: id,
        name: title,
        updatedAt: updatedAt,
        type: docType,
        markdown: _resolveMarkdown(markdown),
        status: map['status'] as String? ?? 'queued',
        errorMessage: map['error_message'] as String?,
      );
    }).toList()..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<DocumentSaveOutcome> saveDraft(DocumentDraft draft) async {
    final userInput = _resolveUserInput(
      userInput: draft.userInput,
      markdown: draft.markdown,
    );
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/documents/generate',
      data: {
        'title': _resolveTitle(draft.title),
        'doc_type': _resolveType(draft.docType, draft.title),
        'user_input': userInput,
      },
      decoder: (value) => (value as Map?)?.cast<String, dynamic>() ?? const {},
    );
    final documentId = response['document_id'] as String? ?? '';
    final status = response['status'] as String? ?? 'queued';
    return DocumentSaveOutcome(
      result: DocumentSaveResult.created,
      documentId: documentId,
      status: status,
    );
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
    final title = data['title'] as String? ?? '';
    final markdown = _resolveRemoteMarkdown(data);
    return DocumentItem(
      id: data['document_id'] as String? ?? normalizedId,
      name: title,
      updatedAt:
          DateTime.tryParse(
            data['updated_at'] as String? ??
                data['created_at'] as String? ??
                '',
          ) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      type: _normalizeDocumentTypeForRead(data['doc_type'] as String?),
      markdown: _resolveMarkdown(markdown),
      status: data['status'] as String? ?? 'queued',
      errorMessage: data['error_message'] as String?,
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
    final data = await _apiClient.patch<Map<String, dynamic>>(
      '/documents/$normalizedId',
      data: {
        'title': _resolveTitle(title),
        'content_markdown': _resolveMarkdown(markdown),
      },
      decoder: (value) => (value as Map?)?.cast<String, dynamic>() ?? const {},
    );
    return DocumentItem(
      id: data['document_id'] as String? ?? normalizedId,
      name: data['title'] as String? ?? _resolveTitle(title),
      updatedAt:
          DateTime.tryParse(
            data['updated_at'] as String? ??
                data['created_at'] as String? ??
                '',
          ) ??
          DateTime.now(),
      type: _normalizeDocumentTypeForRead(data['doc_type'] as String?),
      markdown: _resolveMarkdown(_resolveRemoteMarkdown(data)),
      status: data['status'] as String? ?? 'completed',
      errorMessage: data['error_message'] as String?,
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

  String _resolveTitle(String title) {
    final normalized = title.trim();
    return normalized.isEmpty ? '未命名文档' : normalized;
  }

  String _resolveMarkdown(String? markdown) {
    return markdown?.trim() ?? '';
  }

  String _resolveUserInput({
    required String? userInput,
    required String? markdown,
  }) {
    final normalizedInput = userInput?.trim() ?? '';
    if (normalizedInput.isNotEmpty) {
      return normalizedInput;
    }
    return _resolveMarkdown(markdown);
  }

  String _resolveRemoteMarkdown(Map<String, dynamic> data) {
    final markdown =
        _readStringField(data, 'content_markdown') ??
        _readStringField(data, 'content') ??
        _readStringField(data, 'markdown');
    return _resolveMarkdown(markdown);
  }

  String? _readStringField(Map<String, dynamic> data, String key) {
    final value = data[key];
    return value is String ? value : null;
  }

  String _resolveType(String docType, String title) {
    final normalizedType = _normalizeDocumentType(docType);
    if (normalizedType != null) {
      return normalizedType;
    }
    if (title.contains('律师函')) {
      return _lawyerLetterType;
    }
    return _laborArbitrationType;
  }

  String _normalizeDocumentTypeForRead(String? value) {
    final normalized = _normalizeDocumentType(value ?? '');
    if (normalized != null) {
      return normalized;
    }
    final raw = value?.trim() ?? '';
    return raw.isNotEmpty ? raw : _laborArbitrationType;
  }

  String? _normalizeDocumentType(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      return null;
    }
    if (normalized == _lawyerLetterType) {
      return _lawyerLetterType;
    }
    if (normalized == _laborArbitrationType ||
        normalized == '劳动仲裁申请书' ||
        normalized == '仲裁文书' ||
        normalized == '仲裁申请书' ||
        normalized == '劳动仲裁文书') {
      return _laborArbitrationType;
    }
    return null;
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
