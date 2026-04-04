import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lexcore/features/document/application/document_controller.dart';
import 'package:lexcore/features/document/data/repositories/document_repository.dart';
import 'package:lexcore/shared/models/legal_models.dart';

final generatedDraftProvider = Provider<DocumentDraft>((ref) {
  return ref.watch(documentRepositoryProvider).generatePreview();
});

final documentControllerProvider =
    StateNotifierProvider<DocumentController, DocumentState>((ref) {
      return DocumentController(
        repository: ref.watch(documentRepositoryProvider),
      );
    });

final savedDocumentsProvider = Provider<List<DocumentItem>>((ref) {
  return ref.watch(documentControllerProvider).documents;
});

final documentByIdProvider = Provider.family<DocumentItem?, String>((
  ref,
  documentId,
) {
  final normalizedId = documentId.trim();
  if (normalizedId.isEmpty) {
    return null;
  }
  final documents = ref.watch(savedDocumentsProvider);
  for (final item in documents) {
    if (item.id == normalizedId) {
      return item;
    }
  }
  return null;
});
