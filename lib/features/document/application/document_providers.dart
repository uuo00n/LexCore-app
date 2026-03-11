import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lexcore/features/document/data/repositories/document_repository.dart';
import 'package:lexcore/shared/models/legal_models.dart';
import 'package:lexcore/shared/services/mock/mock_providers.dart';

final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  return DocumentRepository(ref.watch(mockLegalRepositoryProvider));
});

final generatedDraftProvider = Provider<DocumentDraft>((ref) {
  return ref.watch(documentRepositoryProvider).generatePreview();
});

final savedDocumentsProvider = Provider<List<DocumentItem>>((ref) {
  return ref.watch(documentRepositoryProvider).loadSaved();
});
