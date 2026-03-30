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

  testWidgets('history timeline uses unified list tile style', (tester) async {
    await pumpHistoryPage(tester);

    expect(find.byType(AppListTileItem), findsWidgets);
    expect(find.text('工资拖欠咨询会话'), findsOneWidget);
    expect(find.textContaining('当前筛选'), findsNothing);
    expect(find.byIcon(Icons.chevron_right), findsNothing);
    expect(
      find.byKey(const ValueKey<String>('history_page_keyword_field')),
      findsOneWidget,
    );
  });
}
