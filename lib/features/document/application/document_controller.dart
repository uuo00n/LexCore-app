import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lexcore/features/document/data/repositories/document_repository.dart';
import 'package:lexcore/shared/models/legal_models.dart';

class DocumentState {
  const DocumentState({
    required this.documents,
    required this.loading,
    required this.saving,
    this.errorMessage,
  });

  factory DocumentState.initial() {
    return const DocumentState(documents: [], loading: true, saving: false);
  }

  final List<DocumentItem> documents;
  final bool loading;
  final bool saving;
  final String? errorMessage;

  DocumentState copyWith({
    List<DocumentItem>? documents,
    bool? loading,
    bool? saving,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return DocumentState(
      documents: documents ?? this.documents,
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
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

  Future<DocumentSaveResult> saveDraft(DocumentDraft draft) async {
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
        clearErrorMessage: true,
      );
      return result;
    } catch (_) {
      state = state.copyWith(
        loading: false,
        saving: false,
        errorMessage: '保存失败，请稍后重试',
      );
      rethrow;
    }
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
