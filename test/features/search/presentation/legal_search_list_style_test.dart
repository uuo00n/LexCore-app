import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import 'package:lexcore/features/search/presentation/pages/legal_search_page.dart';
import 'package:lexcore/shared/components/app_list_tile_item.dart';
import 'package:lexcore/shared/components/app_surface_card.dart';

void main() {
  Future<void> pumpLegalSearchPage(
    WidgetTester tester, {
    ThemeData? theme,
    ThemeData? darkTheme,
    ThemeMode themeMode = ThemeMode.light,
  }) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(
      ProviderScope(
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
}
