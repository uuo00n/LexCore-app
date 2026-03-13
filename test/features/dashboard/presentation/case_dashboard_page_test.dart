import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lexcore/features/dashboard/presentation/pages/case_dashboard_page.dart';
import 'package:lexcore/shared/components/app_list_tile_item.dart';
import 'package:lexcore/shared/widgets/app_shell_top_bar.dart';

void main() {
  Future<void> pumpDashboardPage(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: CaseDashboardPage())),
    );
    await tester.pump(const Duration(milliseconds: 900));
  }

  testWidgets('uses shell top bar style with back arrow', (tester) async {
    await pumpDashboardPage(tester);

    expect(find.byType(AppShellTopBar), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    expect(find.byIcon(Icons.search_rounded), findsOneWidget);
  });

  testWidgets('uses segmented button for tab navigation', (tester) async {
    await pumpDashboardPage(tester);

    expect(find.byType(SegmentedButton<int>), findsOneWidget);
    expect(find.text('概览'), findsOneWidget);
    expect(find.text('案件'), findsOneWidget);
    expect(find.text('报告'), findsOneWidget);
    expect(find.text('设置'), findsNothing);
  });

  testWidgets('total and in-progress cards are evenly split in one row', (
    tester,
  ) async {
    await pumpDashboardPage(tester);

    final totalSize = tester.getSize(
      find.byKey(const ValueKey<String>('dashboard_metric_total_cases')),
    );
    final progressSize = tester.getSize(
      find.byKey(const ValueKey<String>('dashboard_metric_in_progress')),
    );

    expect(totalSize.width, progressSize.width);
  });

  testWidgets('uses shared list tile style for in-progress case list', (
    tester,
  ) async {
    await pumpDashboardPage(tester);

    expect(find.byType(AppListTileItem), findsAtLeastNWidgets(1));
    expect(
      find.byKey(const ValueKey<String>('dashboard_case_item_0')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('dashboard_case_progress_text_0')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('dashboard_case_progress_bar_0')),
      findsOneWidget,
    );
  });
}
