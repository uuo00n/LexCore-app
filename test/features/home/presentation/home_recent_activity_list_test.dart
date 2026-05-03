import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:lexcore/app/router/route_names.dart';
import 'package:lexcore/features/home/application/home_providers.dart';
import 'package:lexcore/features/home/domain/entities/home_entity.dart';
import 'package:lexcore/features/home/presentation/pages/home_page.dart';
import 'package:lexcore/shared/models/legal_models.dart';

void main() {
  HomeEntity buildHomeData({List<ActivityRecord>? activities}) {
    return HomeEntity(
      actions: const [
        QuickAction(
          title: '法律咨询',
          subtitle: '智能问答',
          icon: 'chat_bubble',
          route: '/consultation',
        ),
        QuickAction(
          title: '文书生成',
          subtitle: '自动起草',
          icon: 'description',
          route: '/document',
        ),
      ],
      activities:
          activities ??
          [
            ActivityRecord(
              title: '最新咨询记录',
              time: DateTime(2026, 4, 4, 10),
              category: HistoryCategory.consultation,
              resourceKey: 'thread_001',
            ),
            ActivityRecord(
              title: '最新文档记录',
              time: DateTime(2026, 4, 4, 9),
              category: HistoryCategory.document,
              resourceKey: 'doc_001',
            ),
            ActivityRecord(
              title: '最新分析记录',
              time: DateTime(2026, 4, 4, 8),
              category: HistoryCategory.analysis,
              resourceKey: 'LAW-123',
            ),
          ],
    );
  }

  Future<void> setDefaultSurfaceSize(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });
  }

  Future<void> pumpHomePage(WidgetTester tester, {HomeEntity? homeData}) async {
    await setDefaultSurfaceSize(tester);

    final resolvedHomeData = homeData ?? buildHomeData();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeDataProvider.overrideWith((ref) async => resolvedHomeData),
        ],
        child: const MaterialApp(home: HomePage()),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> pumpHomePageWithRouter(
    WidgetTester tester, {
    HomeEntity? homeData,
  }) async {
    await setDefaultSurfaceSize(tester);

    final resolvedHomeData = homeData ?? buildHomeData();
    final router = GoRouter(
      initialLocation: RouteNames.homePath,
      routes: [
        GoRoute(
          path: RouteNames.homePath,
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: RouteNames.historyPath,
          builder: (context, state) => const Scaffold(body: Text('历史记录页')),
        ),
        GoRoute(
          path: RouteNames.consultationPath,
          name: RouteNames.consultation,
          builder: (context, state) => const Scaffold(body: Text('咨询列表页')),
        ),
        GoRoute(
          path: RouteNames.consultationChatPath,
          name: RouteNames.consultationChat,
          builder: (context, state) {
            final threadId =
                state.pathParameters[RouteNames
                    .consultationChatThreadIdParam] ??
                '';
            return Scaffold(body: Text('咨询详情页:$threadId'));
          },
        ),
        GoRoute(
          path: RouteNames.legalArticlePath,
          name: RouteNames.legalArticle,
          builder: (context, state) => const Scaffold(body: Text('法条详情页')),
        ),
        GoRoute(
          path: RouteNames.savedDocumentsPath,
          name: RouteNames.savedDocuments,
          builder: (context, state) => const Scaffold(body: Text('文档列表页')),
        ),
        GoRoute(
          path: RouteNames.savedDocumentDetailPath,
          name: RouteNames.savedDocumentDetail,
          builder: (context, state) {
            final docId =
                state.pathParameters[RouteNames.savedDocumentIdParam] ?? '';
            final mode = state.uri.queryParameters['mode'] ?? '';
            return Scaffold(body: Text('文档详情页:$docId:$mode'));
          },
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeDataProvider.overrideWith((ref) async => resolvedHomeData),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder activityItem(int index) {
    return find.byKey(ValueKey<String>('home_recent_activity_item_$index'));
  }

  Finder activitySubtitle(int index) {
    return find.byKey(ValueKey<String>('home_recent_activity_subtitle_$index'));
  }

  testWidgets('recent activity list renders all items with mapped icons', (
    tester,
  ) async {
    await pumpHomePage(tester);

    expect(
      find.byKey(const ValueKey('home_recent_activity_list')),
      findsOneWidget,
    );
    expect(activityItem(0), findsOneWidget);
    expect(activityItem(1), findsOneWidget);
    expect(activityItem(2), findsOneWidget);
    expect(activityItem(3), findsNothing);

    expect(
      find.descendant(
        of: activityItem(0),
        matching: find.byIcon(Icons.history),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: activityItem(1),
        matching: find.byIcon(Icons.article_outlined),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: activityItem(2),
        matching: find.byIcon(Icons.analytics_outlined),
      ),
      findsOneWidget,
    );
  });

  testWidgets('recent activity subtitle includes bullet and row is tappable', (
    tester,
  ) async {
    await pumpHomePageWithRouter(tester);

    for (var i = 0; i < 3; i++) {
      final subtitle = tester.widget<Text>(activitySubtitle(i));
      expect(subtitle.data, isNotNull);
      expect(subtitle.data!, contains('•'));
      expect(
        find.descendant(
          of: activityItem(i),
          matching: find.byIcon(Icons.chevron_right),
        ),
        findsOneWidget,
      );
    }

    await tester.tap(activityItem(0));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('咨询详情页:thread_001'), findsOneWidget);
  });

  testWidgets('home quick actions no longer show legal search entry', (
    tester,
  ) async {
    await pumpHomePage(tester);

    expect(find.text('法律搜索'), findsNothing);
    expect(find.text('法规与案例检索'), findsNothing);
  });

  testWidgets('recent activity list only renders latest five items', (
    tester,
  ) async {
    final activities = List<ActivityRecord>.generate(
      6,
      (index) => ActivityRecord(
        title: '活动$index',
        time: DateTime(2026, 4, 4, 10 - index),
        category: HistoryCategory.consultation,
        resourceKey: 'thread_$index',
      ),
    );

    await pumpHomePage(tester, homeData: buildHomeData(activities: activities));

    expect(activityItem(0), findsOneWidget);
    expect(activityItem(1), findsOneWidget);
    expect(activityItem(2), findsOneWidget);
    expect(activityItem(3), findsOneWidget);
    expect(activityItem(4), findsOneWidget);
    expect(activityItem(5), findsNothing);
    expect(find.text('活动5'), findsNothing);
  });

  testWidgets('view all button navigates to history page', (tester) async {
    await pumpHomePageWithRouter(tester);

    await tester.tap(find.widgetWithText(TextButton, '查看全部'));
    await tester.pumpAndSettle();

    expect(find.text('历史记录页'), findsOneWidget);
  });

  testWidgets('analysis activity navigates to legal article page', (
    tester,
  ) async {
    final homeData = buildHomeData(
      activities: [
        ActivityRecord(
          title: '劳动法检索',
          time: DateTime(2026, 4, 4, 10),
          category: HistoryCategory.analysis,
          resourceKey: 'LAW-567',
        ),
      ],
    );
    await pumpHomePageWithRouter(tester, homeData: homeData);

    await tester.tap(activityItem(0));
    await tester.pumpAndSettle();

    expect(find.text('法条详情页'), findsOneWidget);
  });

  testWidgets(
    'consultation activity falls back to consultation list without resourceKey',
    (tester) async {
      final homeData = buildHomeData(
        activities: [
          ActivityRecord(
            title: '咨询入口降级',
            time: DateTime(2026, 4, 4, 10),
            category: HistoryCategory.consultation,
          ),
        ],
      );
      await pumpHomePageWithRouter(tester, homeData: homeData);

      await tester.tap(activityItem(0));
      await tester.pumpAndSettle();

      expect(find.text('咨询列表页'), findsOneWidget);
    },
  );

  testWidgets('document activity navigates to saved document detail page', (
    tester,
  ) async {
    final homeData = buildHomeData(
      activities: [
        ActivityRecord(
          title: '劳动仲裁申请书',
          time: DateTime(2026, 4, 4, 10),
          category: HistoryCategory.document,
          resourceKey: 'doc_567',
        ),
      ],
    );
    await pumpHomePageWithRouter(tester, homeData: homeData);

    await tester.tap(activityItem(0));
    await tester.pumpAndSettle();

    expect(find.text('文档详情页:doc_567:view'), findsOneWidget);
  });
}
