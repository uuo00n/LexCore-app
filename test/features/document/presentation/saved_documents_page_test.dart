import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lexcore/app/router/route_names.dart';
import 'package:lexcore/features/document/presentation/pages/saved_document_detail_page.dart';
import 'package:lexcore/features/document/presentation/pages/saved_documents_page.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pumpSavedDocumentsPage(
    WidgetTester tester, {
    required Size size,
    double textScale = 1.0,
  }) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(
      ProviderScope(
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

  testWidgets('renders persisted saved document from local storage', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'saved_documents_v1': '''
[
  {
    "id": "doc_1",
    "name": "本地保存的合同审查报告",
    "updatedAt": "2026-03-14T08:00:00.000",
    "type": "审查意见"
  }
]
''',
    });

    await pumpSavedDocumentsPage(tester, size: const Size(390, 844));

    expect(find.text('本地保存的合同审查报告'), findsOneWidget);
    expect(find.textContaining('审查意见 · 更新于'), findsOneWidget);
  });

  testWidgets('view and edit buttons open the same detail page with modes', (
    tester,
  ) async {
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
      ProviderScope(child: MaterialApp.router(routerConfig: router)),
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
