import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lexcore/features/search/presentation/pages/legal_search_page.dart';
import 'package:lexcore/shared/components/app_list_tile_item.dart';

void main() {
  Future<void> pumpLegalSearchPage(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: LegalSearchPage())),
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
    expect(find.byType(ActionChip), findsNWidgets(12));
    expect(find.byIcon(Icons.balance_rounded), findsWidgets);
    expect(find.byIcon(Icons.description_outlined), findsWidgets);
    expect(find.byIcon(Icons.home_work_outlined), findsWidgets);

    await tester.tap(
      find.byKey(const ValueKey('search_scenario_labor_contract')),
    );
    await tester.pumpAndSettle();

    expect(find.text('预设场景'), findsNothing);
    expect(find.byType(AppListTileItem), findsNWidgets(2));
    expect(find.text('中华人民共和国劳动合同法 第三十条'), findsOneWidget);
    expect(find.text('中华人民共和国劳动合同法 第四十七条'), findsOneWidget);
  });
}
