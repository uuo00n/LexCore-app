import 'package:lexcore/shared/models/legal_models.dart';
import 'package:lexcore/shared/services/mock/mock_legal_repository.dart';

class DocumentRepository {
  const DocumentRepository(this._mock);

  final MockLegalRepository _mock;

  DocumentDraft generatePreview() => _mock.generatedDraft();

  List<DocumentItem> loadSaved() => _mock.savedDocuments();
}
