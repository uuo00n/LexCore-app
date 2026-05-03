import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lexcore/app/router/route_names.dart';
import 'package:lexcore/core/network/api_client.dart';
import 'package:lexcore/features/document/data/repositories/document_repository.dart';
import 'package:lexcore/features/document/presentation/pages/saved_document_detail_page.dart';
import 'package:lexcore/features/document/presentation/pages/saved_documents_page.dart';
import 'package:lexcore/shared/models/legal_models.dart';

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
               name: '劳动仲裁申请书-2026-03-06',
               updatedAt: DateTime.parse('2026-03-06T10:00:00.000Z'),
               type: '仲裁文书',
               markdown: '# 劳动仲裁申请书-2026-03-06',
               status: 'completed',
             ),
             DocumentItem(
               id: 'doc_2',
               name: '仅 content 字段文档',
               updatedAt: DateTime.parse('2026-03-05T10:00:00.000Z'),
               type: '律师函',
               markdown: '# 仅 content 字段文档',
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
}

Future<_InMemoryDocumentRepository> _buildRepository({
  List<DocumentItem>? initialDocuments,
}) async {
  final preferences = await SharedPreferences.getInstance();
  return _InMemoryDocumentRepository(
    preferences: preferences,
    initialDocuments: initialDocuments,
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pumpSavedDocumentsPage(
    WidgetTester tester, {
    required Size size,
    double textScale = 1.0,
    DocumentRepository? repository,
  }) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    final resolvedRepository = repository ?? await _buildRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          documentRepositoryProvider.overrideWithValue(resolvedRepository),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              final mediaQuery = MediaQuery.of(context);
              return MediaQuery(
                data: mediaQuery.copyWith(
                  textScaler: TextScaler.linear(textScale),
                ),
                child: const SavedDocumentsPage(),
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders without overflow on compact viewport', (tester) async {
    await pumpSavedDocumentsPage(tester, size: const Size(320, 640));

    expect(tester.takeException(), isNull);
    expect(find.text('已保存的文档'), findsOneWidget);
    expect(find.text('劳动仲裁申请书-2026-03-06'), findsOneWidget);
    expect(find.text('查看'), findsWidgets);
    expect(find.text('编辑'), findsWidgets);
  });

  testWidgets('renders without overflow on compact viewport with larger text', (
    tester,
  ) async {
    await pumpSavedDocumentsPage(
      tester,
      size: const Size(320, 640),
      textScale: 1.3,
    );

    expect(tester.takeException(), isNull);
    expect(find.text('已保存的文档'), findsOneWidget);
    expect(find.text('劳动仲裁申请书-2026-03-06'), findsOneWidget);
  });

  testWidgets('renders provided saved document records', (tester) async {
    final repository = await _buildRepository(
      initialDocuments: [
        DocumentItem(
          id: 'doc_custom_1',
          name: '本地保存的合同审查报告',
          updatedAt: DateTime.parse('2026-03-14T08:00:00.000Z'),
          type: '审查意见',
          markdown: '# 本地保存的合同审查报告',
          status: 'completed',
        ),
      ],
    );

    await pumpSavedDocumentsPage(
      tester,
      size: const Size(390, 844),
      repository: repository,
    );

    expect(find.text('本地保存的合同审查报告'), findsOneWidget);
    expect(find.textContaining('审查意见 · 更新于'), findsOneWidget);
  });

  testWidgets('view and edit buttons open the same detail page with modes', (
    tester,
  ) async {
    final repository = await _buildRepository();
    final router = GoRouter(
      initialLocation: RouteNames.savedDocumentsPath,
      routes: [
        GoRoute(
          path: RouteNames.savedDocumentsPath,
          builder: (context, state) => const SavedDocumentsPage(),
        ),
        GoRoute(
          path: RouteNames.savedDocumentDetailPath,
          name: RouteNames.savedDocumentDetail,
          builder: (context, state) => SavedDocumentDetailPage(
            documentId:
                state.pathParameters[RouteNames.savedDocumentIdParam] ?? '',
            startInEditMode: state.uri.queryParameters['mode'] == 'edit',
          ),
        ),
      ],
    );

    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [documentRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('查看').first);
    await tester.pumpAndSettle();
    expect(find.byType(SavedDocumentDetailPage), findsOneWidget);
    expect(find.text('查看模式'), findsOneWidget);

    router.go(RouteNames.savedDocumentsPath);
    await tester.pumpAndSettle();

    await tester.tap(find.text('编辑').first);
    await tester.pumpAndSettle();
    expect(find.byType(SavedDocumentDetailPage), findsOneWidget);
    expect(find.text('编辑模式'), findsOneWidget);
  });
}
