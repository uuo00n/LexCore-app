import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lexcore/core/error/app_exception.dart';
import 'package:lexcore/features/document/data/repositories/document_repository.dart';
import 'package:lexcore/shared/models/legal_models.dart';

class DocumentState {
  const DocumentState({
    required this.documents,
    required this.loading,
    required this.saving,
    required this.exportingPdf,
    required this.detailLoading,
    this.latestSavedDocumentId,
    this.errorMessage,
    this.feedbackMessage,
  });

  factory DocumentState.initial() {
    return const DocumentState(
      documents: [],
      loading: true,
      saving: false,
      exportingPdf: false,
      detailLoading: false,
    );
  }

  final List<DocumentItem> documents;
  final bool loading;
  final bool saving;
  final bool exportingPdf;
  final bool detailLoading;
  final String? latestSavedDocumentId;
  final String? errorMessage;
  final String? feedbackMessage;

  DocumentState copyWith({
    List<DocumentItem>? documents,
    bool? loading,
    bool? saving,
    bool? exportingPdf,
    bool? detailLoading,
    String? latestSavedDocumentId,
    String? errorMessage,
    String? feedbackMessage,
    bool clearErrorMessage = false,
    bool clearFeedbackMessage = false,
  }) {
    return DocumentState(
      documents: documents ?? this.documents,
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      exportingPdf: exportingPdf ?? this.exportingPdf,
      detailLoading: detailLoading ?? this.detailLoading,
      latestSavedDocumentId:
          latestSavedDocumentId ?? this.latestSavedDocumentId,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      feedbackMessage: clearFeedbackMessage
          ? null
          : feedbackMessage ?? this.feedbackMessage,
    );
  }
}

class DocumentController extends StateNotifier<DocumentState> {
  DocumentController({required DocumentRepository repository})
    : _repository = repository,
      super(DocumentState.initial()) {
    _loadSavedDocuments();
  }

  final DocumentRepository _repository;

  Future<void> refresh() async {
    await _loadSavedDocuments();
  }

  Future<DocumentSaveOutcome> saveDraft(DocumentDraft draft) async {
    if (state.saving) {
      throw StateError('document save already in progress');
    }

    state = state.copyWith(saving: true, clearErrorMessage: true);
    try {
      final result = await _repository.saveDraft(draft);
      final documents = await _repository.loadSaved();
      state = state.copyWith(
        documents: documents,
        loading: false,
        saving: false,
        latestSavedDocumentId: result.documentId,
        clearErrorMessage: true,
        feedbackMessage: result.status == 'failed'
            ? '文档生成失败，请稍后重试'
            : result.status == 'completed'
            ? (result.result == DocumentSaveResult.created
                  ? '文档已保存并生成完成'
                  : '文档已更新并生成完成')
            : '文档已提交生成，正在处理中',
      );
      return result;
    } on AppException catch (error) {
      state = state.copyWith(
        loading: false,
        saving: false,
        errorMessage: error.message,
        feedbackMessage: error.message,
      );
      rethrow;
    } catch (_) {
      state = state.copyWith(
        loading: false,
        saving: false,
        errorMessage: '保存失败，请稍后重试',
        feedbackMessage: '保存失败，请稍后重试',
      );
      rethrow;
    }
  }

  Future<DocumentItem?> loadDetail(String documentId) async {
    final normalizedId = documentId.trim();
    if (normalizedId.isEmpty) {
      return null;
    }

    DocumentItem? cachedItem;
    for (final item in state.documents) {
      if (item.id == normalizedId) {
        cachedItem = item;
        break;
      }
    }

    state = state.copyWith(detailLoading: true, clearErrorMessage: true);
    try {
      final item = await _repository.loadById(normalizedId);
      if (item == null) {
        state = state.copyWith(detailLoading: false);
        return cachedItem;
      }

      final nextDocuments = [
        item,
        ...state.documents.where((doc) => doc.id != item.id),
      ];
      state = state.copyWith(
        documents: nextDocuments,
        detailLoading: false,
        clearErrorMessage: true,
      );
      return item;
    } catch (_) {
      state = state.copyWith(
        detailLoading: false,
        errorMessage: cachedItem == null ? '文档加载失败，请稍后重试' : null,
      );
      return cachedItem;
    }
  }

  Future<DocumentItem?> updateDocument({
    required String id,
    required String title,
    required String markdown,
  }) async {
    if (state.saving) {
      return null;
    }

    state = state.copyWith(
      saving: true,
      clearErrorMessage: true,
      clearFeedbackMessage: true,
    );
    try {
      final updated = await _repository.updateDocument(
        id: id,
        title: title,
        markdown: markdown,
      );
      if (updated == null) {
        state = state.copyWith(
          saving: false,
          errorMessage: '文档不存在或已删除',
          feedbackMessage: '文档不存在或已删除',
        );
        return null;
      }

      final documents = await _repository.loadSaved();
      state = state.copyWith(
        documents: documents,
        loading: false,
        saving: false,
        clearErrorMessage: true,
        feedbackMessage: '文档已更新',
      );
      for (final item in documents) {
        if (item.id == updated.id) {
          return item;
        }
      }
      return updated;
    } on AppException catch (error) {
      state = state.copyWith(
        saving: false,
        errorMessage: error.message,
        feedbackMessage: error.message,
      );
      return null;
    } catch (_) {
      state = state.copyWith(
        saving: false,
        errorMessage: '保存失败，请稍后重试',
        feedbackMessage: '保存失败，请稍后重试',
      );
      return null;
    }
  }

  Future<DocumentPdfExportResult?> exportDraftPdf(
    DocumentDraft draft, {
    String? preferredDocumentId,
    int maxPollAttempts = 20,
    Duration pollInterval = const Duration(seconds: 2),
  }) async {
    if (state.exportingPdf) {
      return null;
    }

    var targetDocumentId = preferredDocumentId?.trim();
    if (targetDocumentId == null || targetDocumentId.isEmpty) {
      targetDocumentId = state.latestSavedDocumentId?.trim();
    }
    if (targetDocumentId == null || targetDocumentId.isEmpty) {
      try {
        final saveOutcome = await saveDraft(draft);
        targetDocumentId = saveOutcome.documentId.trim();
      } catch (_) {
        return null;
      }
    }
    if (targetDocumentId.isEmpty) {
      final fallback = _findDocumentByTitle(draft.title);
      targetDocumentId = fallback?.id ?? '';
    }
    if (targetDocumentId.isEmpty) {
      return null;
    }

    state = state.copyWith(exportingPdf: true, clearErrorMessage: true);
    try {
      final result = await _repository.exportPdf(
        targetDocumentId,
        maxPollAttempts: maxPollAttempts,
        pollInterval: pollInterval,
      );
      state = state.copyWith(
        exportingPdf: false,
        errorMessage: result.errorMessage,
        clearErrorMessage: result.completed,
      );
      return result;
    } catch (_) {
      state = state.copyWith(
        exportingPdf: false,
        errorMessage: 'PDF 导出失败，请稍后重试',
      );
      return null;
    }
  }

  DocumentItem? _findDocumentByTitle(String title) {
    final normalized = title.trim();
    if (normalized.isEmpty) {
      return null;
    }
    for (final item in state.documents) {
      if (item.name.trim() == normalized) {
        return item;
      }
    }
    return null;
  }

  void clearFeedbackMessage() {
    state = state.copyWith(clearFeedbackMessage: true);
  }

  Future<void> _loadSavedDocuments() async {
    state = state.copyWith(loading: true, clearErrorMessage: true);
    try {
      final documents = await _repository.loadSaved();
      state = state.copyWith(
        documents: documents,
        loading: false,
        clearErrorMessage: true,
      );
    } catch (_) {
      state = state.copyWith(loading: false, errorMessage: '文档加载失败，请稍后重试');
    }
  }
}
