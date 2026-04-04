import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lexcore/core/network/api_client.dart';
import 'package:lexcore/features/document/data/repositories/document_repository.dart';
import 'package:lexcore/features/document/presentation/pages/saved_document_detail_page.dart';
import 'package:lexcore/shared/models/legal_models.dart';

class _NoopApiClient extends ApiClient {
  _NoopApiClient() : super(Dio());
}

class _InMemoryDocumentRepository extends DocumentRepository {
  _InMemoryDocumentRepository({
    required SharedPreferences preferences,
    List<DocumentItem>? seed,
  }) : _documents =
           seed ??
           [
             DocumentItem(
               id: 'doc_test_1',
               name: '测试文档',
               updatedAt: DateTime.parse('2026-03-14T08:00:00.000Z'),
               type: '仲裁文书',
               markdown: '# 测试文档\n\n原始正文',
               status: 'completed',
             ),
           ],
       super(_NoopApiClient(), preferences);

  final List<DocumentItem> _documents;

  @override
  Future<List<DocumentItem>> loadSaved() async {
    return [..._documents];
  }

  @override
  Future<DocumentItem?> loadById(String id) async {
    for (final item in _documents) {
      if (item.id == id) {
        return item;
      }
    }
    return null;
  }

  @override
  Future<DocumentItem?> updateDocument({
    required String id,
    required String title,
    required String markdown,
  }) async {
    final index = _documents.indexWhere((item) => item.id == id);
    if (index < 0) {
      return null;
    }
    final updated = _documents[index].copyWith(
      name: title,
      markdown: markdown,
      updatedAt: DateTime.now(),
    );
    _documents[index] = updated;
    return updated;
  }
}

Future<_InMemoryDocumentRepository> _buildRepository() async {
  final preferences = await SharedPreferences.getInstance();
  return _InMemoryDocumentRepository(preferences: preferences);
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pumpSavedDocumentDetailPage(
    WidgetTester tester, {
    required String documentId,
    bool startInEditMode = false,
    required DocumentRepository repository,
  }) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [documentRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp(
          home: SavedDocumentDetailPage(
            documentId: documentId,
            startInEditMode: startInEditMode,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('saved document detail renders read-only mode by default', (
    tester,
  ) async {
    final repository = await _buildRepository();
    await pumpSavedDocumentDetailPage(
      tester,
      documentId: 'doc_test_1',
      repository: repository,
    );

    expect(find.text('文档详情'), findsOneWidget);
    expect(find.text('测试文档'), findsWidgets);
    expect(find.text('查看模式'), findsOneWidget);
  });

  testWidgets('saved document detail can start in edit mode', (tester) async {
    final repository = await _buildRepository();
    await pumpSavedDocumentDetailPage(
      tester,
      documentId: 'doc_test_1',
      startInEditMode: true,
      repository: repository,
    );

    expect(find.text('编辑文档'), findsOneWidget);
    expect(find.text('编辑模式'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
  });

  testWidgets('saved document detail saves edited content', (tester) async {
    final repository = await _buildRepository();
    await pumpSavedDocumentDetailPage(
      tester,
      documentId: 'doc_test_1',
      startInEditMode: true,
      repository: repository,
    );

    await tester.enterText(find.byType(TextField).first, '测试文档-更新');
    await tester.enterText(find.byType(TextField).last, '# 测试文档-更新\n\n更新后的正文');
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    final docs = await repository.loadSaved();
    final updated = docs.firstWhere((item) => item.id == 'doc_test_1');
    expect(updated.name, '测试文档-更新');
    expect(updated.markdown, contains('更新后的正文'));
  });
}
