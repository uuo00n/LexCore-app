import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lexcore/features/document/data/repositories/document_repository.dart';
import 'package:lexcore/shared/models/legal_models.dart';
import 'package:lexcore/shared/services/mock/mock_legal_repository.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('loadSaved returns seeded documents when storage is empty', () async {
    final repository = DocumentRepository(const MockLegalRepository());

    final documents = await repository.loadSaved();

    expect(documents, isNotEmpty);
    expect(documents.first.name, '劳动仲裁申请书-2026-03-06');
  });

  test('saveDraft adds a new document and persists it', () async {
    final repository = DocumentRepository(const MockLegalRepository());
    const draft = DocumentDraft(title: '新生成的民事起诉状', markdown: '# 新生成的民事起诉状');

    final result = await repository.saveDraft(draft);
    final documents = await repository.loadSaved();

    expect(result, DocumentSaveResult.created);
    expect(documents.first.name, draft.title);
    expect(documents.first.markdown, draft.markdown);
    expect(documents.where((item) => item.name == draft.title), hasLength(1));
  });

  test(
    'saveDraft updates an existing title instead of creating duplicates',
    () async {
      final repository = DocumentRepository(const MockLegalRepository());
      const draft = DocumentDraft(title: '劳动仲裁申请书（草稿）', markdown: '# 劳动仲裁申请书');

      final firstResult = await repository.saveDraft(draft);
      final secondResult = await repository.saveDraft(draft);
      final documents = await repository.loadSaved();

      expect(firstResult, DocumentSaveResult.created);
      expect(secondResult, DocumentSaveResult.updated);
      expect(documents.where((item) => item.name == draft.title), hasLength(1));
      expect(documents.first.type, '仲裁文书');
      expect(documents.first.markdown, draft.markdown);
    },
  );

  test(
    'loadSaved provides markdown fallback for legacy stored record',
    () async {
      SharedPreferences.setMockInitialValues({
        'saved_documents_v1': '''
[
  {
    "id": "legacy_1",
    "name": "旧版本文档",
    "updatedAt": "2026-03-14T08:00:00.000",
    "type": "审查意见"
  }
]
''',
      });

      final repository = DocumentRepository(const MockLegalRepository());
      final documents = await repository.loadSaved();

      expect(documents, hasLength(1));
      expect(documents.first.name, '旧版本文档');
      expect(documents.first.markdown, contains('旧版本文档'));
    },
  );
}
