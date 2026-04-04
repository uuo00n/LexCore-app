import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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
