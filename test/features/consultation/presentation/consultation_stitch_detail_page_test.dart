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
  Future<void> pumpStitchDetailPage(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(
      const MaterialApp(home: ConsultationStitchDetailPage()),
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
    expect(find.text('专业法律智能分析'), findsOneWidget);
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
}
