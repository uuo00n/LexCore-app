import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import 'package:lexcore/app/di/app_providers.dart';
import 'package:lexcore/core/export/app_export_service.dart';
import 'package:lexcore/core/network/api_client.dart';
import 'package:lexcore/features/document/data/repositories/document_repository.dart';
import 'package:lexcore/features/document/presentation/pages/saved_document_detail_page.dart';
import 'package:lexcore/shared/models/legal_models.dart';

class _FakeExportService implements AppExportService {
  final exportedFormats = <ExportFormat>[];
  final createdDirectories = <Directory>[];

  Future<void> dispose() async {
    for (final directory in createdDirectories) {
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    }
  }

  @override
  Future<ExportArtifact> export({
    required ExportPayload payload,
    required ExportFormat format,
  }) async {
    exportedFormats.add(format);
    final directory = await Directory.systemTemp.createTemp(
      'saved_document_detail_page_test',
    );
    createdDirectories.add(directory);

    final displayName = 'saved_document_export.${format.extension}';
    final file = File('${directory.path}/$displayName');
    await file.writeAsString(payload.markdown);

    return ExportArtifact(
      filePath: file.path,
      displayName: displayName,
      mimeType: format.mimeType,
    );
  }
}

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

class _StaleListFreshDetailRepository extends DocumentRepository {
  _StaleListFreshDetailRepository({required SharedPreferences preferences})
    : super(_NoopApiClient(), preferences);

  int loadByIdCalls = 0;

  static final DocumentItem _listItem = DocumentItem(
    id: 'doc_stale_1',
    name: '关于海米公寓不退换房租押金的问题',
    updatedAt: DateTime.parse('2026-03-14T08:00:00.000Z'),
    type: '律师函',
    markdown: '',
    status: 'completed',
  );

  static final DocumentItem _detailItem = DocumentItem(
    id: 'doc_stale_1',
    name: '关于海米公寓不退换房租押金的问题',
    updatedAt: DateTime.parse('2026-03-14T08:00:00.000Z'),
    type: '律师函',
    markdown: '# 关于海米公寓不退换房租押金的问题\n\n## 一、事实与理由\n\n正文补全内容',
    status: 'completed',
  );

  @override
  Future<List<DocumentItem>> loadSaved() async {
    return [_listItem];
  }

  @override
  Future<DocumentItem?> loadById(String id) async {
    loadByIdCalls += 1;
    await Future<void>.delayed(const Duration(milliseconds: 10));
    if (id == _detailItem.id) {
      return _detailItem;
    }
    return null;
  }

  @override
  Future<DocumentItem?> updateDocument({
    required String id,
    required String title,
    required String markdown,
  }) async {
    return null;
  }
}

class _RefreshingCompletedDocumentRepository extends DocumentRepository {
  _RefreshingCompletedDocumentRepository({
    required SharedPreferences preferences,
  }) : super(_NoopApiClient(), preferences);

  int loadByIdCalls = 0;

  static final DocumentItem _initialItem = DocumentItem(
    id: 'doc_refresh_1',
    name: '刷新前标题',
    updatedAt: DateTime.parse('2026-03-14T08:00:00.000Z'),
    type: '律师函',
    markdown: '# 刷新前标题\n\n刷新前正文',
    status: 'completed',
  );

  static final DocumentItem _freshItem = DocumentItem(
    id: 'doc_refresh_1',
    name: '刷新后标题',
    updatedAt: DateTime.parse('2026-03-14T08:05:00.000Z'),
    type: '律师函',
    markdown: '# 刷新后标题\n\n刷新后的服务端正文',
    status: 'completed',
  );

  @override
  Future<List<DocumentItem>> loadSaved() async {
    return [_initialItem];
  }

  @override
  Future<DocumentItem?> loadById(String id) async {
    loadByIdCalls += 1;
    if (id != _initialItem.id) {
      return null;
    }
    return loadByIdCalls == 1 ? _initialItem : _freshItem;
  }

  @override
  Future<DocumentItem?> updateDocument({
    required String id,
    required String title,
    required String markdown,
  }) async {
    return null;
  }
}

class _QueuedThenCompletedRepository extends DocumentRepository {
  _QueuedThenCompletedRepository({required SharedPreferences preferences})
    : super(_NoopApiClient(), preferences);

  int loadByIdCalls = 0;

  @override
  Future<List<DocumentItem>> loadSaved() async {
    return [
      DocumentItem(
        id: 'doc_queue_1',
        name: '排队中的文书',
        updatedAt: DateTime.parse('2026-03-14T08:00:00.000Z'),
        type: '仲裁文书',
        markdown: '',
        status: 'queued',
      ),
    ];
  }

  @override
  Future<DocumentItem?> loadById(String id) async {
    loadByIdCalls += 1;
    if (id != 'doc_queue_1') {
      return null;
    }
    if (loadByIdCalls == 1) {
      return DocumentItem(
        id: 'doc_queue_1',
        name: '排队中的文书',
        updatedAt: DateTime.parse('2026-03-14T08:00:00.000Z'),
        type: '仲裁文书',
        markdown: '',
        status: 'queued',
      );
    }
    return DocumentItem(
      id: 'doc_queue_1',
      name: '排队中的文书',
      updatedAt: DateTime.parse('2026-03-14T08:00:00.000Z'),
      type: '仲裁文书',
      markdown: '# 排队中的文书\\n\\n生成完成正文',
      status: 'completed',
    );
  }

  @override
  Future<DocumentItem?> updateDocument({
    required String id,
    required String title,
    required String markdown,
  }) async {
    return null;
  }
}

class _FailedDocumentRepository extends DocumentRepository {
  _FailedDocumentRepository({required SharedPreferences preferences})
    : super(_NoopApiClient(), preferences);

  @override
  Future<List<DocumentItem>> loadSaved() async {
    return [
      DocumentItem(
        id: 'doc_failed_1',
        name: '失败文书',
        updatedAt: DateTime.parse('2026-03-14T08:00:00.000Z'),
        type: '仲裁文书',
        markdown: '',
        status: 'failed',
        errorMessage: 'yuanqi business error: 400',
      ),
    ];
  }

  @override
  Future<DocumentItem?> loadById(String id) async {
    if (id != 'doc_failed_1') {
      return null;
    }
    return DocumentItem(
      id: 'doc_failed_1',
      name: '失败文书',
      updatedAt: DateTime.parse('2026-03-14T08:00:00.000Z'),
      type: '仲裁文书',
      markdown: '',
      status: 'failed',
      errorMessage: 'yuanqi business error: 400',
    );
  }

  @override
  Future<DocumentItem?> updateDocument({
    required String id,
    required String title,
    required String markdown,
  }) async {
    return null;
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
    AppExportService? exportService,
    bool settle = true,
  }) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          documentRepositoryProvider.overrideWithValue(repository),
          if (exportService != null)
            appExportServiceProvider.overrideWithValue(exportService),
        ],
        child: MaterialApp(
          home: SavedDocumentDetailPage(
            documentId: documentId,
            startInEditMode: startInEditMode,
          ),
        ),
      ),
    );
    if (settle) {
      await tester.pumpAndSettle();
      return;
    }
    await tester.pump();
  }

  List<TextField> editFields(WidgetTester tester) {
    return tester.widgetList<TextField>(find.byType(TextField)).toList();
  }

  List<MethodCall> mockShareChannel() {
    const channel = MethodChannel('dev.fluttercommunity.plus/share');
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          return '';
        });
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });
    return calls;
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

    final fields = editFields(tester);
    expect(fields.first.controller?.text, '测试文档');
    expect(fields.last.controller?.text, '# 测试文档\n\n原始正文');
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

  testWidgets('saved document detail shares markdown file', (tester) async {
    final repository = await _buildRepository();
    final exportService = _FakeExportService();
    addTearDown(exportService.dispose);
    mockShareChannel();
    await pumpSavedDocumentDetailPage(
      tester,
      documentId: 'doc_test_1',
      repository: repository,
      exportService: exportService,
    );

    await tester.tap(find.byTooltip('分享文档'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Markdown (.md)'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(exportService.exportedFormats, <ExportFormat>[
      ExportFormat.markdown,
    ]);
    expect(find.text('分享失败，请稍后重试'), findsNothing);
  });

  testWidgets('saved document detail falls back to local pdf export', (
    tester,
  ) async {
    final repository = await _buildRepository();
    final exportService = _FakeExportService();
    addTearDown(exportService.dispose);
    mockShareChannel();
    await pumpSavedDocumentDetailPage(
      tester,
      documentId: 'doc_test_1',
      repository: repository,
      exportService: exportService,
    );

    await tester.tap(find.byTooltip('分享文档'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('PDF 文档 (.pdf)'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(exportService.exportedFormats, <ExportFormat>[ExportFormat.pdf]);
    expect(find.text('分享失败，请稍后重试'), findsNothing);
  });

  testWidgets(
    'saved document detail refreshes markdown from detail api when list markdown is empty',
    (tester) async {
      final preferences = await SharedPreferences.getInstance();
      final repository = _StaleListFreshDetailRepository(
        preferences: preferences,
      );
      await pumpSavedDocumentDetailPage(
        tester,
        documentId: 'doc_stale_1',
        repository: repository,
      );

      expect(repository.loadByIdCalls, greaterThanOrEqualTo(1));
      expect(find.text('一、事实与理由'), findsOneWidget);
    },
  );

  testWidgets(
    'saved document edit mode fills content after fresh detail replaces empty list item',
    (tester) async {
      final preferences = await SharedPreferences.getInstance();
      final repository = _StaleListFreshDetailRepository(
        preferences: preferences,
      );
      await pumpSavedDocumentDetailPage(
        tester,
        documentId: 'doc_stale_1',
        startInEditMode: true,
        repository: repository,
      );

      final fields = editFields(tester);
      expect(fields.first.controller?.text, '关于海米公寓不退换房租押金的问题');
      expect(fields.last.controller?.text, contains('正文补全内容'));
    },
  );

  testWidgets('saved document refresh does not overwrite local edits', (
    tester,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    final repository = _RefreshingCompletedDocumentRepository(
      preferences: preferences,
    );
    await pumpSavedDocumentDetailPage(
      tester,
      documentId: 'doc_refresh_1',
      startInEditMode: true,
      repository: repository,
    );

    await tester.enterText(find.byType(TextField).last, '# 用户正在编辑\n\n本地正文');
    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pumpAndSettle();

    final fields = editFields(tester);
    expect(repository.loadByIdCalls, greaterThanOrEqualTo(2));
    expect(fields.last.controller?.text, '# 用户正在编辑\n\n本地正文');
    expect(fields.last.controller?.text, isNot(contains('服务端正文')));
  });

  testWidgets('saved document detail auto polls queued document to completed', (
    tester,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    final repository = _QueuedThenCompletedRepository(preferences: preferences);
    await pumpSavedDocumentDetailPage(
      tester,
      documentId: 'doc_queue_1',
      repository: repository,
    );

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(repository.loadByIdCalls, greaterThanOrEqualTo(2));
    expect(find.text('已完成'), findsOneWidget);
  });

  testWidgets('saved document detail shows generation animation state', (
    tester,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    final repository = _QueuedThenCompletedRepository(preferences: preferences);
    await pumpSavedDocumentDetailPage(
      tester,
      documentId: 'doc_queue_1',
      repository: repository,
      settle: false,
    );
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('文书生成中'), findsOneWidget);
    expect(find.textContaining('正在整理案件要点'), findsOneWidget);
    expect(find.byType(Shimmer), findsWidgets);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });

  testWidgets('saved document detail shows backend failure message', (
    tester,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    final repository = _FailedDocumentRepository(preferences: preferences);
    await pumpSavedDocumentDetailPage(
      tester,
      documentId: 'doc_failed_1',
      repository: repository,
    );

    expect(find.text('文书生成失败'), findsOneWidget);
    expect(find.text('yuanqi business error: 400'), findsOneWidget);
    expect(find.text('重试刷新'), findsOneWidget);
  });
}
