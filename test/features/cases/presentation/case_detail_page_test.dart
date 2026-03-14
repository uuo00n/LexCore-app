import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lexcore/features/cases/presentation/pages/case_detail_page.dart';

void main() {
  Future<void> pumpCaseDetailPage(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(
      MaterialApp(home: CaseDetailPage(detail: CaseDetailData.demo())),
    );
    await tester.pump(const Duration(milliseconds: 800));
  }

  testWidgets('renders stitch case detail layout with themed sections', (
    tester,
  ) async {
    await pumpCaseDetailPage(tester);

    expect(find.text('案件详情'), findsOneWidget);
    expect(find.text('张三与李四房屋所有权纠纷案'), findsOneWidget);
    expect(find.text('AI 案件深度分析'), findsOneWidget);
    expect(find.text('当前进度 (65%)'), findsOneWidget);
    expect(find.text('当前节点：开庭中'), findsOneWidget);
    expect(find.text('当事人信息'), findsOneWidget);
    expect(find.text('案情摘要'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('case_detail_analysis_button')),
      findsOneWidget,
    );

    await tester.scrollUntilVisible(
      find.text('关联文档'),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('关联文档'), findsOneWidget);
  });
}
