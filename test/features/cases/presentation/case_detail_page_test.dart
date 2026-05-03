import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:lexcore/app/router/route_names.dart';
import 'package:lexcore/features/cases/presentation/pages/case_detail_page.dart';
import 'package:lexcore/features/cases/presentation/widgets/case_analysis_preview_card.dart';
import 'package:lexcore/shared/widgets/app_page_scaffold.dart';
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
              CaseDetailPage(detail: _sampleCaseDetail()),
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

  List<MethodCall> mockShareChannel() {
    const channel = MethodChannel('dev.fluttercommunity.plus/share');
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          return '';
        });
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });
    return calls;
  }

  testWidgets('renders case detail page with analysis preview card', (
    tester,
  ) async {
    await pumpCaseDetailPage(tester);

    expect(find.text('案件详情'), findsOneWidget);
    expect(find.byType(AppShellTopBar), findsOneWidget);
    expect(
      tester.widget<AppPageScaffold>(find.byType(AppPageScaffold)).bodyPadding,
      isNull,
    );
    expect(find.byIcon(Icons.share_outlined), findsOneWidget);
    expect(find.byIcon(Icons.more_vert_rounded), findsOneWidget);
    expect(find.text('张三与李四房屋所有权纠纷案'), findsOneWidget);
    expect(find.text('案件分析速览'), findsOneWidget);
    expect(find.text('当前版本暂未接入案件分析数据。'), findsNothing);
    expect(find.text('已生成分析'), findsOneWidget);
    expect(find.text('事实完整度'), findsOneWidget);
    expect(find.text('证据强度'), findsOneWidget);
    expect(find.text('程序风险'), findsOneWidget);
    expect(find.text('重点提示'), findsOneWidget);
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

  testWidgets('preview CTA row is visible when analysis data is ready', (
    tester,
  ) async {
    await pumpCaseDetailPage(tester);
    expect(find.byKey(CaseAnalysisPreviewCard.ctaKey), findsOneWidget);
  });

  testWidgets('shares case summary from top action', (tester) async {
    final calls = mockShareChannel();
    await pumpCaseDetailPage(tester);

    await tester.tap(find.byTooltip('分享'));
    await tester.pumpAndSettle();

    final arguments = calls.single.arguments as Map<Object?, Object?>;
    expect(arguments['subject'], '张三与李四房屋所有权纠纷案');
    expect(arguments['text'], contains('(2023) 沪0115民初12345号'));
    expect(arguments['text'], contains('关联文档'));
  });
}

CaseDetailData _sampleCaseDetail() {
  return const CaseDetailData(
    status: CaseDetailStatus.inProgress,
    statusLabel: '进行中',
    lastUpdatedLabel: '更新于 2小时前',
    title: '张三与李四房屋所有权纠纷案',
    caseNumber: '(2023) 沪0115民初12345号',
    dateLabel: '立案日期',
    dateValue: '2023-10-15',
    progress: 0.65,
    progressLabel: '开庭中',
    activeStepIndex: 2,
    progressSteps: ['证据交换', '庭审准备', '开庭中', '判决'],
    summary:
        '原告张三与被告李四于 2022 年签订房屋买卖协议，原告已支付全部房款，但被告迟迟未办理房产过户手续。原告遂起诉要求被告履行合同义务并赔偿违约金。',
    plaintiffName: '张三',
    plaintiffCounsel: '代理律师：王律师',
    defendantName: '李四',
    defendantCounsel: '未指定代理',
    documents: [
      CaseDocumentData(
        type: CaseDocumentType.pdf,
        title: '起诉状_张三.pdf',
        meta: '1.2 MB · 2023-10-16',
      ),
      CaseDocumentData(
        type: CaseDocumentType.image,
        title: '房产证复印件.jpg',
        meta: '2.5 MB · 2023-10-18',
      ),
    ],
  );
}

class _LabelPage extends StatelessWidget {
  const _LabelPage({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text(title)));
  }
}
