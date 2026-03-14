import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:lexcore/app/router/route_names.dart';
import 'package:lexcore/features/cases/presentation/pages/case_detail_page.dart';
import 'package:lexcore/features/cases/presentation/widgets/case_analysis_preview_card.dart';
import 'package:lexcore/shared/widgets/app_shell_top_bar.dart';

void main() {
  Future<void> setPhoneViewport(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });
  }

  GoRouter buildRouter() {
    return GoRouter(
      initialLocation: RouteNames.caseDetailPath,
      routes: [
        GoRoute(
          path: RouteNames.caseDetailPath,
          builder: (context, state) =>
              CaseDetailPage(detail: CaseDetailData.demo()),
        ),
        GoRoute(
          path: RouteNames.analysisDetailPath,
          builder: (context, state) => const _LabelPage(title: '分析详情占位'),
        ),
      ],
    );
  }

  Future<void> pumpCaseDetailPage(WidgetTester tester) async {
    await setPhoneViewport(tester);
    await tester.pumpWidget(
      ProviderScope(child: MaterialApp.router(routerConfig: buildRouter())),
    );
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();
  }

  testWidgets('renders case detail page with analysis preview card', (
    tester,
  ) async {
    await pumpCaseDetailPage(tester);

    expect(find.text('案件详情'), findsOneWidget);
    expect(find.byType(AppShellTopBar), findsOneWidget);
    expect(find.byIcon(Icons.share_outlined), findsOneWidget);
    expect(find.byIcon(Icons.more_vert_rounded), findsOneWidget);
    expect(find.text('张三与李四房屋所有权纠纷案'), findsOneWidget);
    expect(find.text('案件分析速览'), findsOneWidget);
    expect(find.text('已生成分析'), findsOneWidget);
    expect(find.text('事实完整度'), findsOneWidget);
    expect(find.text('82%'), findsOneWidget);
    expect(find.text('证据强度'), findsOneWidget);
    expect(find.text('76%'), findsOneWidget);
    expect(find.text('程序风险'), findsOneWidget);
    expect(find.text('中'), findsOneWidget);
    expect(find.text('重点提示'), findsOneWidget);
    expect(find.text('关键书面证据缺失'), findsOneWidget);
    expect(find.text('查看完整分析'), findsOneWidget);
    expect(find.text('开始分析'), findsNothing);
    expect(find.text('当前进度 (65%)'), findsOneWidget);
    expect(find.text('当前节点：开庭中'), findsOneWidget);
    expect(find.text('当事人信息'), findsOneWidget);
    expect(find.byKey(CaseAnalysisPreviewCard.cardKey), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('案情摘要'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('案情摘要'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('关联文档'),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('关联文档'), findsOneWidget);
  });

  testWidgets('opens analysis detail page when tapping analysis preview card', (
    tester,
  ) async {
    await pumpCaseDetailPage(tester);

    await tester.tap(find.byKey(CaseAnalysisPreviewCard.cardKey));
    await tester.pumpAndSettle();

    expect(find.text('分析详情占位'), findsOneWidget);
  });

  testWidgets('opens analysis detail page when tapping preview CTA row', (
    tester,
  ) async {
    await pumpCaseDetailPage(tester);

    await tester.tap(find.byKey(CaseAnalysisPreviewCard.ctaKey));
    await tester.pumpAndSettle();

    expect(find.text('分析详情占位'), findsOneWidget);
  });
}

class _LabelPage extends StatelessWidget {
  const _LabelPage({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text(title)));
  }
}
