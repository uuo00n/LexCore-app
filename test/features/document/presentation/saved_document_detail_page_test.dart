import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lexcore/features/document/data/repositories/document_repository.dart';
import 'package:lexcore/features/document/presentation/pages/saved_document_detail_page.dart';
import 'package:lexcore/shared/services/mock/mock_legal_repository.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'saved_documents_v1': jsonEncode([
        {
          'id': 'doc_test_1',
          'name': '测试文档',
          'updatedAt': '2026-03-14T08:00:00.000',
          'type': '仲裁文书',
          'markdown': '# 测试文档\n\n原始正文',
        },
      ]),
    });
  });

  Future<void> pumpSavedDocumentDetailPage(
    WidgetTester tester, {
    required String documentId,
    bool startInEditMode = false,
  }) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(
      ProviderScope(
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
    await pumpSavedDocumentDetailPage(tester, documentId: 'doc_test_1');

    expect(find.text('文档详情'), findsOneWidget);
    expect(find.text('测试文档'), findsWidgets);
    expect(find.text('查看模式'), findsOneWidget);
  });

  testWidgets('saved document detail can start in edit mode', (tester) async {
    await pumpSavedDocumentDetailPage(
      tester,
      documentId: 'doc_test_1',
      startInEditMode: true,
    );

    expect(find.text('编辑文档'), findsOneWidget);
    expect(find.text('编辑模式'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
  });

  testWidgets('saved document detail saves edited content', (tester) async {
    await pumpSavedDocumentDetailPage(
      tester,
      documentId: 'doc_test_1',
      startInEditMode: true,
    );

    await tester.enterText(find.byType(TextField).first, '测试文档-更新');
    await tester.enterText(find.byType(TextField).last, '# 测试文档-更新\n\n更新后的正文');
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    final repository = DocumentRepository(const MockLegalRepository());
    final docs = await repository.loadSaved();
    final updated = docs.firstWhere((item) => item.id == 'doc_test_1');
    expect(updated.name, '测试文档-更新');
    expect(updated.markdown, contains('更新后的正文'));
  });
}
