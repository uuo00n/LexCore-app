import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lexcore/features/history/presentation/pages/history_page.dart';
import 'package:lexcore/shared/components/app_list_tile_item.dart';

void main() {
  Future<void> pumpHistoryPage(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HistoryPage())),
    );
    await tester.pump(const Duration(milliseconds: 900));
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
}
