import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lexcore/app/router/route_names.dart';
import 'package:lexcore/app/di/app_providers.dart';
import 'package:lexcore/core/export/app_export_service.dart';
import 'package:lexcore/core/network/api_client.dart';
import 'package:lexcore/features/document/data/repositories/document_repository.dart';
import 'package:lexcore/features/document/presentation/pages/document_preview_page.dart';
import 'package:lexcore/features/document/presentation/pages/saved_document_detail_page.dart';
import 'package:lexcore/shared/models/legal_models.dart';
import 'package:lexcore/shared/widgets/app_page_scaffold.dart';
import 'package:lexcore/shared/widgets/app_shell_top_bar.dart';

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
      'document_preview_page_test',
    );
    createdDirectories.add(directory);

    final displayName = 'document_export.${format.extension}';
    final file = File('${directory.path}/$displayName');
    await file.writeAsString('fake ${format.name}');

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
    List<DocumentItem>? initialDocuments,
  }) : _documents =
           initialDocuments ??
           [
             DocumentItem(
               id: 'doc_1',
               name: '劳动仲裁申请书（草稿）',
               updatedAt: DateTime.now().subtract(const Duration(days: 1)),
               type: '仲裁文书',
               markdown: '# 劳动仲裁申请书（草稿）',
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
  Future<DocumentSaveOutcome> saveDraft(DocumentDraft draft) async {
    final now = DateTime.now();
    final existingIndex = _documents.indexWhere(
      (item) => item.name == draft.title,
    );
    if (existingIndex >= 0) {
      _documents[existingIndex] = _documents[existingIndex].copyWith(
        markdown: draft.markdown,
        updatedAt: now,
      );
      return DocumentSaveOutcome(
        result: DocumentSaveResult.updated,
        documentId: _documents[existingIndex].id,
        status: _documents[existingIndex].status,
      );
    }

    final docId = 'doc_${_documents.length + 1}';
    _documents.insert(
      0,
      DocumentItem(
        id: docId,
        name: draft.title,
        updatedAt: now,
        type: '法律文书',
        markdown: draft.markdown,
        status: 'queued',
      ),
    );
    return DocumentSaveOutcome(
      result: DocumentSaveResult.created,
      documentId: docId,
      status: 'queued',
    );
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
}

class _FailingDocumentRepository extends DocumentRepository {
  _FailingDocumentRepository({required SharedPreferences preferences})
    : super(_NoopApiClient(), preferences);

  @override
  Future<List<DocumentItem>> loadSaved() async {
    return const [];
  }

  @override
  Future<DocumentSaveOutcome> saveDraft(DocumentDraft draft) async {
    throw Exception('save failed');
  }
}

Future<_InMemoryDocumentRepository> _buildInMemoryRepository() async {
  final preferences = await SharedPreferences.getInstance();
  return _InMemoryDocumentRepository(preferences: preferences);
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pumpDocumentPreviewPage(
    WidgetTester tester, {
    Size size = const Size(390, 844),
    AppExportService? exportService,
    DocumentRepository? documentRepository,
    double textScale = 1.0,
  }) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    final repository = documentRepository ?? await _buildInMemoryRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          if (exportService != null)
            appExportServiceProvider.overrideWithValue(exportService),
          documentRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp.router(
          routerConfig: GoRouter(
            initialLocation: RouteNames.documentPreviewPath,
            routes: [
              GoRoute(
                path: RouteNames.documentPreviewPath,
                name: RouteNames.documentPreview,
                builder: (context, state) {
                  final mediaQuery = MediaQuery.of(context);
                  return MediaQuery(
                    data: mediaQuery.copyWith(
                      textScaler: TextScaler.linear(textScale),
                    ),
                    child: const DocumentPreviewPage(),
                  );
                },
              ),
              GoRoute(
                path: RouteNames.savedDocumentDetailPath,
                name: RouteNames.savedDocumentDetail,
                builder: (context, state) => SavedDocumentDetailPage(
                  documentId:
                      state.pathParameters[RouteNames.savedDocumentIdParam] ??
                      '',
                  startInEditMode: state.uri.queryParameters['mode'] == 'edit',
                ),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 900));
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

  testWidgets('document preview uses unified top bar', (tester) async {
    await pumpDocumentPreviewPage(tester);

    expect(find.byType(AppShellTopBar), findsOneWidget);
    expect(
      tester.widget<AppPageScaffold>(find.byType(AppPageScaffold)).bodyPadding,
      const EdgeInsets.fromLTRB(16, 6, 16, 16),
    );
    expect(find.text('文档预览'), findsOneWidget);
    expect(find.byIcon(Icons.more_vert_rounded), findsOneWidget);
  });

  testWidgets('document preview renders evidence info card', (tester) async {
    await pumpDocumentPreviewPage(tester);

    expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);
    expect(find.text('证据材料示意（非真实图片）'), findsOneWidget);
    expect(find.text('建议材料'), findsOneWidget);
  });

  testWidgets('document preview top action exports markdown file', (
    tester,
  ) async {
    final exportService = _FakeExportService();
    addTearDown(exportService.dispose);
    mockShareChannel();
    await pumpDocumentPreviewPage(
      tester,
      size: const Size(1200, 900),
      exportService: exportService,
    );

    await tester.tap(find.byTooltip('分享'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Markdown (.md)'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(exportService.exportedFormats, <ExportFormat>[
      ExportFormat.markdown,
    ]);
    expect(find.text('分享失败，请稍后重试'), findsNothing);
  });

  testWidgets('document preview side action exports pdf file', (tester) async {
    final exportService = _FakeExportService();
    addTearDown(exportService.dispose);
    mockShareChannel();
    await pumpDocumentPreviewPage(
      tester,
      size: const Size(1200, 900),
      exportService: exportService,
    );

    final exportButton = find.widgetWithText(OutlinedButton, '导出 / 分享');
    await tester.ensureVisible(exportButton);
    await tester.tap(exportButton);
    await tester.pumpAndSettle();
    await tester.tap(find.text('PDF 文档 (.pdf)'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(exportService.exportedFormats, <ExportFormat>[ExportFormat.pdf]);
    expect(find.text('分享失败，请稍后重试'), findsNothing);
  });

  testWidgets('document preview save navigates to saved document detail', (
    tester,
  ) async {
    final repository = await _buildInMemoryRepository();
    await pumpDocumentPreviewPage(tester, documentRepository: repository);

    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    final documents = await repository.loadSaved();
    expect(documents.where((item) => item.name == '劳动仲裁申请书（草稿）'), hasLength(1));
    expect(find.byType(SavedDocumentDetailPage), findsOneWidget);
    expect(find.text('查看模式'), findsOneWidget);
  });

  testWidgets('document preview save opens detail page in view mode', (
    tester,
  ) async {
    final repository = await _buildInMemoryRepository();
    await pumpDocumentPreviewPage(tester, documentRepository: repository);

    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    expect(find.byType(SavedDocumentDetailPage), findsOneWidget);
    expect(find.text('查看模式'), findsOneWidget);
    expect(find.text('编辑模式'), findsNothing);
  });

  testWidgets('document preview save failure shows snackbar', (tester) async {
    final preferences = await SharedPreferences.getInstance();
    await pumpDocumentPreviewPage(
      tester,
      documentRepository: _FailingDocumentRepository(preferences: preferences),
    );

    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    expect(find.text('保存失败，请稍后重试'), findsOneWidget);
  });

  testWidgets('document preview keeps layout stable with larger text scale', (
    tester,
  ) async {
    await pumpDocumentPreviewPage(tester, textScale: 1.35);

    expect(tester.takeException(), isNull);
    expect(find.text('文档预览'), findsOneWidget);
    expect(find.text('劳动仲裁申请书（草稿）'), findsAtLeastNWidgets(1));
  });
}
