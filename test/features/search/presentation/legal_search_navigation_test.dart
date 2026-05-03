import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lexcore/app/router/route_names.dart';
import 'package:lexcore/core/storage/local_storage.dart';
import 'package:lexcore/features/cases/presentation/pages/case_detail_page.dart';
import 'package:lexcore/features/search/application/search_controller.dart';
import 'package:lexcore/features/search/domain/entities/search_state.dart';
import 'package:lexcore/features/search/presentation/pages/legal_search_page.dart';
import 'package:lexcore/shared/models/legal_models.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pumpSearchWithResult(
    WidgetTester tester, {
    required LawSearchItem item,
  }) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    final preferences = await SharedPreferences.getInstance();
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const LegalSearchPage(),
          routes: [
            GoRoute(
              path: 'article',
              name: RouteNames.legalArticle,
              builder: (context, state) {
                final current = state.extra is LawSearchItem
                    ? state.extra! as LawSearchItem
                    : null;
                return Scaffold(body: Text('article:${current?.articleCode}'));
              },
            ),
          ],
        ),
        GoRoute(
          path: RouteNames.caseDetailPath,
          name: RouteNames.caseDetail,
          builder: (context, state) {
            final detail = state.extra is CaseDetailData
                ? state.extra! as CaseDetailData
                : null;
            return Scaffold(body: Text('case:${detail?.caseNumber}'));
          },
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
          filteredHotSearchArticlesProvider.overrideWith(
            (ref) => AsyncValue.data([item]),
          ),
          searchNoticeProvider.overrideWith(
            (ref) => const AsyncValue.data(null),
          ),
          searchScenarioGroupsProvider.overrideWith((ref) => const []),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('law result opens legal article route', (tester) async {
    const item = LawSearchItem(
      title: '中华人民共和国民法典 第一千零四十条',
      snippet: '婚姻家庭受国家保护。',
      articleCode: 'LAW-1040',
      resultType: SearchResultType.law,
    );

    await pumpSearchWithResult(tester, item: item);

    await tester.tap(find.text(item.title));
    await tester.pumpAndSettle();

    expect(find.text('article:LAW-1040'), findsOneWidget);
  });

  testWidgets('case result opens case detail route', (tester) async {
    const item = LawSearchItem(
      title: '婚姻纠纷案件示例',
      snippet: '上海市第一中级人民法院 · 2024-11-11 · 民事',
      articleCode: '(2024) 沪01民终0001号',
      resultType: SearchResultType.caseDoc,
      courtName: '上海市第一中级人民法院',
      judgementDate: '2024-11-11',
      caseType: '民事',
    );

    await pumpSearchWithResult(tester, item: item);

    await tester.tap(find.text(item.title));
    await tester.pumpAndSettle();

    expect(find.text('case:(2024) 沪01民终0001号'), findsOneWidget);
  });
}
