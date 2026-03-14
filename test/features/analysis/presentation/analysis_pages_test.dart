import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lexcore/features/analysis/presentation/pages/analysis_detail_page.dart';
import 'package:lexcore/features/analysis/presentation/pages/analysis_result_page.dart';
import 'package:lexcore/shared/widgets/app_shell_top_bar.dart';

void main() {
  Future<void> pumpPage(WidgetTester tester, Widget page) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(ProviderScope(child: MaterialApp(home: page)));
    await tester.pump(const Duration(milliseconds: 900));
  }

  testWidgets('analysis detail uses unified top bar', (tester) async {
    await pumpPage(tester, const AnalysisDetailPage());

    expect(find.byType(AppShellTopBar), findsOneWidget);
    expect(find.text('分析详情'), findsOneWidget);
    expect(find.text('案件摘要与法条匹配'), findsOneWidget);
  });

  testWidgets('analysis result uses unified top bar', (tester) async {
    await pumpPage(tester, const AnalysisResultPage());

    expect(find.byType(AppShellTopBar), findsOneWidget);
    expect(find.text('案件分析结果'), findsOneWidget);
    expect(find.text('智能报告与证据评估'), findsOneWidget);
  });
}
