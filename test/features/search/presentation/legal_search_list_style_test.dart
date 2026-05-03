import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import 'package:lexcore/core/storage/local_storage.dart';
import 'package:lexcore/features/search/application/search_controller.dart';
import 'package:lexcore/features/search/presentation/pages/legal_search_page.dart';
import 'package:lexcore/shared/components/app_list_tile_item.dart';
import 'package:lexcore/shared/components/app_surface_card.dart';
import 'package:lexcore/shared/models/legal_models.dart';

void main() {
  const mockHotResults = <LawSearchItem>[
    LawSearchItem(
      title: '中华人民共和国劳动合同法 第三十条',
      snippet: '用人单位应当按照劳动合同约定和国家规定，向劳动者及时足额支付劳动报酬。',
      articleCode: 'LCL-30',
    ),
    LawSearchItem(
      title: '中华人民共和国劳动合同法 第四十七条',
      snippet: '经济补偿按劳动者在本单位工作的年限，每满一年支付一个月工资。',
      articleCode: 'LCL-47',
    ),
    LawSearchItem(
      title: '中华人民共和国民法典 第一百六十五条',
      snippet: '民事法律行为可以基于双方或者多方的意思表示一致成立。',
      articleCode: 'CC-165',
    ),
    LawSearchItem(
      title: '中华人民共和国民法典 第一百七十六条',
      snippet: '民事主体依照法律规定或者按照当事人约定，履行民事义务。',
      articleCode: 'CC-176',
    ),
    LawSearchItem(
      title: '中华人民共和国公司法 第二十条',
      snippet: '公司股东应当遵守法律、行政法规和公司章程，依法行使股东权利。',
      articleCode: 'CL-20',
    ),
    LawSearchItem(
      title: '中华人民共和国公司法 第七十四条',
      snippet: '股东会作出公司合并、分立决议时，异议股东可以请求公司收购其股权。',
      articleCode: 'CL-74',
    ),
    LawSearchItem(
      title: '中华人民共和国道路交通安全法 第七十六条',
      snippet: '机动车发生交通事故造成人身伤亡、财产损失的，先由保险公司赔偿。',
      articleCode: 'RTSL-76',
    ),
    LawSearchItem(
      title: '中华人民共和国行政处罚法 第三十二条',
      snippet: '当事人有权进行陈述和申辩，行政机关必须充分听取并复核。',
      articleCode: 'APL-32',
    ),
    LawSearchItem(
      title: '中华人民共和国消费者权益保护法 第八条',
      snippet: '消费者享有知悉其购买、使用商品或者接受服务真实情况的权利。',
      articleCode: 'CPL-8',
    ),
    LawSearchItem(
      title: '中华人民共和国合同法（历史） 第六十条',
      snippet: '当事人应当按照约定全面履行自己的义务。',
      articleCode: 'OLD-CL-60',
    ),
  ];

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pumpLegalSearchPage(
    WidgetTester tester, {
    ThemeData? theme,
    ThemeData? darkTheme,
    ThemeMode themeMode = ThemeMode.light,
    List<Override> overrides = const [],
  }) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    final preferences = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
          filteredHotSearchArticlesProvider.overrideWith((ref) {
            final keyword = ref.watch(searchControllerProvider).trim();
            if (keyword.isEmpty) {
              return const AsyncValue.data(mockHotResults);
            }
            if (keyword.contains('劳动')) {
              return AsyncValue.data(mockHotResults.take(2).toList());
            }
            final matched = mockHotResults
                .where(
                  (item) =>
                      item.title.contains(keyword) ||
                      item.snippet.contains(keyword),
                )
                .toList();
            return AsyncValue.data(matched);
          }),
          searchNoticeProvider.overrideWith(
            (ref) => const AsyncValue.data(null),
          ),
          ...overrides,
        ],
        child: MaterialApp(
          theme: theme,
          darkTheme: darkTheme,
          themeMode: themeMode,
          home: const LegalSearchPage(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 900));
  }

  testWidgets('search filter chips align with data categories in order', (
    tester,
  ) async {
    await pumpLegalSearchPage(tester);

    final filterListFinder = find.byType(ListView).first;

    expect(find.text('全部'), findsOneWidget);
    expect(find.text('裁判文书'), findsOneWidget);
    expect(find.text('地方性法规'), findsOneWidget);
    expect(find.text('行政法规'), findsOneWidget);

    await tester.drag(filterListFinder, const Offset(-260, 0));
    await tester.pumpAndSettle();

    expect(find.text('司法解释'), findsOneWidget);
    expect(find.text('法律'), findsOneWidget);
    expect(find.text('部门规章'), findsOneWidget);

    await tester.drag(filterListFinder, const Offset(-220, 0));
    await tester.pumpAndSettle();

    expect(find.text('宪法'), findsOneWidget);
  });

  testWidgets('search results use unified list tile style', (tester) async {
    await pumpLegalSearchPage(tester);

    expect(find.text('热门搜索'), findsOneWidget);
    expect(find.byType(AppListTileItem), findsNWidgets(10));
    expect(find.text('中华人民共和国劳动合同法 第三十条'), findsOneWidget);
    expect(find.byIcon(Icons.gavel_outlined), findsWidgets);
    expect(
      find.byKey(const ValueKey('legal_search_scenario_button')),
      findsOneWidget,
    );
    expect(find.text('推荐话题'), findsNothing);
  });

  testWidgets('scenario drawer filters hot articles inside top-right entry', (
    tester,
  ) async {
    await pumpLegalSearchPage(tester);

    await tester.tap(
      find.byKey(const ValueKey('legal_search_scenario_button')),
    );
    await tester.pumpAndSettle();
    expect(find.text('预设场景'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('legal_search_scenario_drawer')),
      findsOneWidget,
    );
    expect(find.byType(TDSideBar), findsOneWidget);
    expect(find.byType(FilterChip), findsNWidgets(2));
    expect(find.byType(ActionChip), findsNothing);
    expect(find.byType(AppSurfaceCard), findsNothing);
    expect(find.byIcon(Icons.balance_rounded), findsWidgets);
    expect(
      find.byKey(const ValueKey('search_scenario_reset_button')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('search_scenario_labor_contract')),
      findsOneWidget,
    );
    final firstChipY = tester
        .getTopLeft(
          find.byKey(const ValueKey('search_scenario_labor_contract')),
        )
        .dy;
    final secondChipY = tester
        .getTopLeft(
          find.byKey(const ValueKey('search_scenario_labor_arbitration')),
        )
        .dy;
    expect(secondChipY, greaterThan(firstChipY));
    expect(
      find.byKey(const ValueKey('search_scenario_contract_breach')),
      findsNothing,
    );

    await tester.tap(find.text('合同纠纷').first);
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('search_scenario_labor_contract')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('search_scenario_contract_breach')),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.description_outlined), findsWidgets);

    await tester.tap(find.text('劳动用工').first);
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey('search_scenario_labor_contract')),
    );
    await tester.pumpAndSettle();

    expect(find.text('预设场景'), findsNothing);
    expect(find.text('搜索结果'), findsOneWidget);
    expect(find.text('热门搜索'), findsNothing);
    expect(find.byType(AppListTileItem), findsNWidgets(2));
    expect(find.text('中华人民共和国劳动合同法 第三十条'), findsOneWidget);
    expect(find.text('中华人民共和国劳动合同法 第四十七条'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('legal_search_scenario_button')),
    );
    await tester.pumpAndSettle();
    final selectedChip = tester.widget<FilterChip>(
      find.byKey(const ValueKey('search_scenario_labor_contract')),
    );
    expect(selectedChip.selected, isTrue);

    await tester.tap(
      find.byKey(const ValueKey('search_scenario_reset_button')),
    );
    await tester.pumpAndSettle();
    final resetChip = tester.widget<FilterChip>(
      find.byKey(const ValueKey('search_scenario_labor_contract')),
    );
    expect(resetChip.selected, isFalse);
    expect(find.byType(AppListTileItem), findsNWidgets(10));
    expect(find.text('热门搜索'), findsOneWidget);
  });

  testWidgets('side bar uses current theme colors in dark mode', (
    tester,
  ) async {
    final lightTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
    );
    final darkTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.indigo,
        brightness: Brightness.dark,
      ),
    );

    await pumpLegalSearchPage(
      tester,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.dark,
    );
    await tester.tap(
      find.byKey(const ValueKey('legal_search_scenario_button')),
    );
    await tester.pumpAndSettle();

    final sideBar = tester.widget<TDSideBar>(find.byType(TDSideBar));
    final chipPane = tester.widget<ColoredBox>(
      find.byKey(const ValueKey('search_scenario_chip_pane')),
    );
    final drawerBuildContext = tester.element(
      find.byKey(const ValueKey('legal_search_scenario_drawer')),
    );
    final colorScheme = Theme.of(drawerBuildContext).colorScheme;

    expect(sideBar.selectedColor, colorScheme.primary);
    expect(sideBar.unSelectedColor, colorScheme.onSurfaceVariant);
    expect(sideBar.selectedBgColor, colorScheme.surfaceContainerLowest);
    expect(sideBar.unSelectedBgColor, colorScheme.surfaceContainerLow);
    expect(chipPane.color, sideBar.selectedBgColor);
  });

  testWidgets('empty state is centered in blank area without card wrapper', (
    tester,
  ) async {
    await pumpLegalSearchPage(tester);

    await tester.enterText(find.byType(TextField).first, '完全不匹配的关键词');
    await tester.pumpAndSettle();

    expect(find.text('搜索结果'), findsOneWidget);
    expect(find.text('暂无匹配法条'), findsOneWidget);
    expect(find.byType(AppSurfaceCard), findsNothing);
    expect(
      find.ancestor(of: find.text('暂无匹配法条'), matching: find.byType(Center)),
      findsWidgets,
    );
  });

  testWidgets('search input and filters stay fixed while results scroll', (
    tester,
  ) async {
    await pumpLegalSearchPage(tester);

    final searchFieldFinder = find.byType(TextField).first;
    final firstResultFinder = find.text('中华人民共和国劳动合同法 第三十条');
    final scrollViewFinder = find.byKey(
      const ValueKey('legal_search_results_scroll_view'),
    );

    final searchFieldTopBefore = tester.getTopLeft(searchFieldFinder).dy;
    final firstResultTopBefore = tester.getTopLeft(firstResultFinder).dy;

    await tester.drag(scrollViewFinder, const Offset(0, -120));
    await tester.pumpAndSettle();

    final searchFieldTopAfter = tester.getTopLeft(searchFieldFinder).dy;
    final firstResultTopAfter = tester.getTopLeft(firstResultFinder).dy;

    expect(searchFieldTopAfter, closeTo(searchFieldTopBefore, 6));
    expect(firstResultTopAfter, lessThan(firstResultTopBefore));
  });

  testWidgets(
    'back-to-top button appears after one viewport and hides at top',
    (tester) async {
      final longResults = List<LawSearchItem>.generate(
        40,
        (index) => LawSearchItem(
          title: '测试法条 ${index + 1}',
          snippet: '用于验证返回顶部按钮滚动阈值与回顶行为',
          articleCode: 'TEST-${index + 1}',
        ),
      );

      await pumpLegalSearchPage(
        tester,
        overrides: [
          filteredHotSearchArticlesProvider.overrideWith(
            (ref) => AsyncValue.data(longResults),
          ),
          searchNoticeProvider.overrideWith(
            (ref) => const AsyncValue.data(null),
          ),
        ],
      );

      const backToTopButtonKey = ValueKey<String>(
        'legal_search_back_to_top_button',
      );
      final scrollViewFinder = find.byKey(
        const ValueKey('legal_search_results_scroll_view'),
      );

      expect(find.byKey(backToTopButtonKey), findsNothing);

      await tester.fling(scrollViewFinder, const Offset(0, -2400), 3200);
      await tester.pumpAndSettle();

      expect(find.byKey(backToTopButtonKey), findsOneWidget);

      final scrollView = tester.widget<SingleChildScrollView>(scrollViewFinder);
      final controller = scrollView.controller!;
      expect(
        controller.offset,
        greaterThanOrEqualTo(controller.position.viewportDimension),
      );

      await tester.tap(find.byKey(backToTopButtonKey));
      await tester.pumpAndSettle();

      expect(controller.offset, 0);
      expect(find.byKey(backToTopButtonKey), findsNothing);
    },
  );
}
