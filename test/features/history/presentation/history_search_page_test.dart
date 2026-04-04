import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:lexcore/app/router/route_names.dart';
import 'package:lexcore/features/history/application/history_controller.dart';
import 'package:lexcore/features/history/presentation/pages/history_page.dart';
import 'package:lexcore/shared/components/app_list_tile_item.dart';
import 'package:lexcore/shared/models/legal_models.dart';

void main() {
  final sampleItems = [
    HistoryItem(
      id: 'h1',
      title: '工资拖欠咨询会话',
      category: HistoryCategory.consultation,
      time: DateTime(2026, 4, 4, 9),
    ),
    HistoryItem(
      id: 'h2',
      title: '劳动仲裁风险分析',
      category: HistoryCategory.analysis,
      time: DateTime(2026, 4, 3, 9),
    ),
    HistoryItem(
      id: 'h3',
      title: '劳动仲裁申请书草稿',
      category: HistoryCategory.document,
      time: DateTime(2026, 4, 2, 9),
    ),
  ];

  Future<void> pumpHistoryPage(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          historyAllItemsProvider.overrideWith((ref) async => sampleItems),
        ],
        child: const MaterialApp(home: HistoryPage()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('history page supports keyword and category filtering', (
    tester,
  ) async {
    await pumpHistoryPage(tester);

    expect(find.byType(AppListTileItem), findsNWidgets(3));

    await tester.enterText(
      find.byKey(const ValueKey<String>('history_page_keyword_field')),
      '仲裁',
    );
    await tester.pumpAndSettle();

    expect(find.byType(AppListTileItem), findsNWidgets(2));
    expect(find.text('劳动仲裁风险分析'), findsOneWidget);
    expect(find.text('劳动仲裁申请书草稿'), findsOneWidget);

    await tester.tap(find.text('法条检索'));
    await tester.pumpAndSettle();

    expect(find.byType(AppListTileItem), findsOneWidget);
    expect(find.text('劳动仲裁风险分析'), findsOneWidget);
    expect(find.text('劳动仲裁申请书草稿'), findsNothing);
  });

  testWidgets('calendar action opens material date range picker', (
    tester,
  ) async {
    await pumpHistoryPage(tester);

    await tester.tap(
      find.byKey(
        const ValueKey<String>('history_page_open_time_dialog_button'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(DateRangePickerDialog), findsOneWidget);
  });

  testWidgets('history page has no secondary search entry', (tester) async {
    await pumpHistoryPage(tester);

    expect(
      find.byKey(const ValueKey<String>('history_page_open_search_button')),
      findsNothing,
    );
    expect(find.text('历史记录搜索'), findsNothing);
  });

  testWidgets('history item can open legal article detail route', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: RouteNames.historyPath,
      routes: [
        GoRoute(
          path: RouteNames.historyPath,
          name: RouteNames.history,
          builder: (context, state) => const HistoryPage(),
        ),
        GoRoute(
          path: RouteNames.legalArticlePath,
          name: RouteNames.legalArticle,
          builder: (context, state) => const Scaffold(body: Text('法规详情占位页')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    final overrideItems = [
      HistoryItem(
        id: 'analysis_1',
        title: '劳动合同法（LAW-001）',
        category: HistoryCategory.analysis,
        time: DateTime(2026, 4, 4, 9),
        resourceKey: 'LAW-001',
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          historyAllItemsProvider.overrideWith((ref) async => overrideItems),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('劳动合同法（LAW-001）'));
    await tester.pumpAndSettle();

    expect(find.text('法规详情占位页'), findsOneWidget);
  });
}
