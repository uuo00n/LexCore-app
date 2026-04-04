import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:lexcore/app/router/route_names.dart';
import 'package:lexcore/features/consultation/presentation/pages/consultation_opinion_detail_page.dart';
import 'package:lexcore/features/consultation/presentation/pages/consultation_stitch_detail_page.dart';
import 'package:lexcore/shared/widgets/app_page_scaffold.dart';
import 'package:lexcore/shared/widgets/app_shell_top_bar.dart';

void main() {
  const sampleSummary = '''
**问题理解**

用户希望了解租赁合同履行中的关键注意事项，并确认风险点与证据准备建议。

**建议重点**

1. 核对合同条款与付款凭证。
2. 保留沟通记录与房屋现状照片。
3. 结合当地租赁管理规定进一步核验。
''';

  Future<void> pumpStitchDetailPage(
    WidgetTester tester, {
    String? summary = sampleSummary,
  }) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(
      MaterialApp(home: ConsultationStitchDetailPage(summary: summary)),
    );
    await tester.pump(const Duration(milliseconds: 900));
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

  testWidgets('consultation stitch detail uses unified top bar', (
    tester,
  ) async {
    await pumpStitchDetailPage(tester);

    expect(find.byType(AppShellTopBar), findsOneWidget);
    expect(
      tester.widget<AppPageScaffold>(find.byType(AppPageScaffold)).bodyPadding,
      isNull,
    );
    expect(find.text('LexCore 解答详情'), findsOneWidget);
    expect(find.text('AI 生成摘要与建议重点'), findsOneWidget);
    expect(find.text('智能解答摘要'), findsOneWidget);
    expect(find.text('回复内容'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, '生成法律意见书'), findsOneWidget);
  });

  testWidgets('consultation stitch detail shares summary content', (
    tester,
  ) async {
    final calls = mockShareChannel();
    await pumpStitchDetailPage(tester);

    await tester.tap(find.byTooltip('分享'));
    await tester.pumpAndSettle();

    final arguments = calls.single.arguments as Map<Object?, Object?>;
    expect(arguments['subject'], 'LexCore 解答详情');
    expect(arguments['text'], contains('问题理解'));
    expect(arguments['text'], contains('建议重点'));
  });

  testWidgets('empty state hides bottom action', (tester) async {
    await pumpStitchDetailPage(tester, summary: null);

    expect(find.text('暂无解答详情'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, '生成法律意见书'), findsNothing);
    expect(find.byTooltip('分享'), findsNothing);
  });

  testWidgets('opinion detail route receives summary payload', (tester) async {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) =>
              const ConsultationStitchDetailPage(summary: '测试摘要内容'),
        ),
        GoRoute(
          path: '/opinion-detail',
          name: RouteNames.consultationOpinionDetail,
          builder: (context, state) =>
              ConsultationOpinionDetailPage(summary: state.extra as String?),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.text('LexCore 解答详情'), findsOneWidget);
    router.pushNamed(RouteNames.consultationOpinionDetail, extra: '测试摘要内容');
    await tester.pumpAndSettle();

    expect(find.byType(ConsultationOpinionDetailPage), findsOneWidget);
    expect(find.text('测试摘要内容'), findsOneWidget);
  });

  testWidgets('long summary does not overflow on small screens', (
    tester,
  ) async {
    final errors = <FlutterErrorDetails>[];
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      errors.add(details);
    };
    addTearDown(() {
      FlutterError.onError = originalOnError;
    });

    final longSummary = List.generate(
      24,
      (index) =>
          '''
**第${index + 1}部分**

这是用于验证详情页滚动能力的超长文本段落，包含多行说明与连续内容，确保在小屏设备上不会再出现 RenderFlex 溢出问题。
''',
    ).join('\n\n');

    await pumpStitchDetailPage(tester, summary: longSummary);
    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(FilledButton, '生成法律意见书'), findsOneWidget);
    expect(
      errors.where(
        (details) =>
            details.exceptionAsString().contains('RenderFlex overflowed'),
      ),
      isEmpty,
    );
  });
}
