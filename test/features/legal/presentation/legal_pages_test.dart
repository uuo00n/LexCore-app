import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lexcore/features/legal/presentation/pages/privacy_policy_page.dart';
import 'package:lexcore/features/legal/presentation/pages/terms_of_service_page.dart';

String buildLongMarkdown(String title) {
  final buffer = StringBuffer('# $title\n\n');
  for (var i = 0; i < 40; i++) {
    buffer.writeln('## 第${i + 1}节');
    buffer.writeln(
      List<String>.filled(3, '这是用于验证法律文档页滚动体验和滚动条同步表现的测试内容。').join(),
    );
    buffer.writeln();
  }
  return buffer.toString();
}

void main() {
  const androidVariant = TargetPlatformVariant(<TargetPlatform>{
    TargetPlatform.android,
  });
  const iosVariant = TargetPlatformVariant(<TargetPlatform>{
    TargetPlatform.iOS,
  });
  final mockTermsMarkdown = buildLongMarkdown('测试服务条款');
  final mockPrivacyMarkdown = buildLongMarkdown('测试隐私政策');

  Future<void> pumpFrames(WidgetTester tester, {int count = 30}) async {
    for (var i = 0; i < count; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
  }

  Future<void> pumpUntilFound(
    WidgetTester tester,
    Finder finder, {
    int maxPumps = 600,
  }) async {
    for (var i = 0; i < maxPumps; i++) {
      final exception = tester.takeException();
      if (exception != null) {
        fail('Exception while waiting for $finder: $exception');
      }
      if (finder.evaluate().isNotEmpty) {
        return;
      }
      await tester.pump(const Duration(milliseconds: 16));
    }
    fail('Timed out waiting for finder: $finder');
  }

  Future<void> setViewport(WidgetTester tester, Size size) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });
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

  ScrollableState findScrollableState(WidgetTester tester) {
    final scrollableFinder = find.descendant(
      of: find.byType(Markdown),
      matching: find.byType(Scrollable),
    );
    return tester.state<ScrollableState>(scrollableFinder);
  }

  testWidgets(
    'terms page uses markdown only and scrolls smoothly on android',
    (tester) async {
      await setViewport(tester, const Size(390, 844));
      await tester.pumpWidget(
        MaterialApp(home: TermsOfServicePage(markdownData: mockTermsMarkdown)),
      );
      await pumpUntilFound(tester, find.byType(Markdown));

      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(find.byType(Scrollbar), findsNothing);
      expect(find.byType(RawScrollbar), findsNothing);
      expect(find.byType(Markdown), findsOneWidget);
      expect(find.byType(MarkdownBody), findsNothing);
      expect(find.text('本协议内容由文档实时加载，滚动进度会随阅读位置同步更新。'), findsNothing);
      expect(find.text('测试服务条款'), findsOneWidget);

      final scrollableState = findScrollableState(tester);
      expect(scrollableState.position.maxScrollExtent, greaterThan(0));
      expect(scrollableState.position.pixels, equals(0));

      await tester.drag(find.byType(Markdown), const Offset(0, -700));
      await pumpFrames(tester, count: 20);
      expect(scrollableState.position.pixels, greaterThan(0));

      await tester.fling(find.byType(Markdown), const Offset(0, -1200), 1800);
      await pumpFrames(tester, count: 20);
      expect(scrollableState.position.pixels, greaterThan(0));
      expect(tester.takeException(), isNull);
    },
    variant: androidVariant,
  );

  testWidgets(
    'privacy page uses markdown only and scrolls smoothly on android',
    (tester) async {
      await setViewport(tester, const Size(390, 844));
      await tester.pumpWidget(
        MaterialApp(home: PrivacyPolicyPage(markdownData: mockPrivacyMarkdown)),
      );
      await pumpUntilFound(tester, find.byType(Markdown));

      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(find.byType(Scrollbar), findsNothing);
      expect(find.byType(RawScrollbar), findsNothing);
      expect(find.byType(Markdown), findsOneWidget);
      expect(find.byType(MarkdownBody), findsNothing);
      expect(find.text('数据与隐私说明'), findsNothing);
      expect(find.text('隐私政策文档'), findsNothing);
      expect(find.text('测试隐私政策'), findsOneWidget);

      final scrollableState = findScrollableState(tester);
      expect(scrollableState.position.maxScrollExtent, greaterThan(0));

      await tester.drag(find.byType(Markdown), const Offset(0, -700));
      await pumpFrames(tester, count: 20);
      expect(scrollableState.position.pixels, greaterThan(0));
      expect(tester.takeException(), isNull);
    },
    variant: androidVariant,
  );

  testWidgets('terms page scrolls smoothly without scrollbar on ios', (
    tester,
  ) async {
    await setViewport(tester, const Size(390, 844));
    await tester.pumpWidget(
      MaterialApp(home: TermsOfServicePage(markdownData: mockTermsMarkdown)),
    );
    await pumpUntilFound(tester, find.byType(Markdown));

    expect(find.byType(Scrollbar), findsNothing);
    expect(find.byType(RawScrollbar), findsNothing);
    expect(find.text('本协议内容由文档实时加载，滚动进度会随阅读位置同步更新。'), findsNothing);

    final scrollableState = findScrollableState(tester);

    await tester.drag(find.byType(Markdown), const Offset(0, -700));
    await pumpFrames(tester, count: 20);
    expect(scrollableState.position.pixels, greaterThan(0));

    await tester.fling(find.byType(Markdown), const Offset(0, -1200), 1800);
    await pumpFrames(tester, count: 20);
    expect(scrollableState.position.pixels, greaterThan(0));
    expect(tester.takeException(), isNull);
  }, variant: iosVariant);

  testWidgets('privacy page scrolls smoothly without scrollbar on ios', (
    tester,
  ) async {
    await setViewport(tester, const Size(390, 844));
    await tester.pumpWidget(
      MaterialApp(home: PrivacyPolicyPage(markdownData: mockPrivacyMarkdown)),
    );
    await pumpUntilFound(tester, find.byType(Markdown));

    expect(find.byType(Scrollbar), findsNothing);
    expect(find.byType(RawScrollbar), findsNothing);
    expect(find.text('数据与隐私说明'), findsNothing);
    expect(find.text('隐私政策文档'), findsNothing);

    final scrollableState = findScrollableState(tester);

    await tester.drag(find.byType(Markdown), const Offset(0, -700));
    await pumpFrames(tester, count: 20);
    expect(scrollableState.position.pixels, greaterThan(0));

    await tester.fling(find.byType(Markdown), const Offset(0, -1200), 1800);
    await pumpFrames(tester, count: 20);
    expect(scrollableState.position.pixels, greaterThan(0));
    expect(tester.takeException(), isNull);
  }, variant: iosVariant);

  testWidgets('terms page shares provided markdown content', (tester) async {
    final calls = mockShareChannel();
    await setViewport(tester, const Size(390, 844));
    await tester.pumpWidget(
      MaterialApp(home: TermsOfServicePage(markdownData: mockTermsMarkdown)),
    );
    await pumpUntilFound(tester, find.byType(Markdown));

    await tester.tap(find.byTooltip('分享'));
    await tester.pumpAndSettle();

    final arguments = calls.single.arguments as Map<Object?, Object?>;
    expect(arguments['text'], contains('测试服务条款'));
    expect(arguments['subject'], contains('服务条款'));
  });

  testWidgets('privacy page shares provided markdown content', (tester) async {
    final calls = mockShareChannel();
    await setViewport(tester, const Size(390, 844));
    await tester.pumpWidget(
      MaterialApp(home: PrivacyPolicyPage(markdownData: mockPrivacyMarkdown)),
    );
    await pumpUntilFound(tester, find.byType(Markdown));

    await tester.tap(find.byTooltip('分享'));
    await tester.pumpAndSettle();

    final arguments = calls.single.arguments as Map<Object?, Object?>;
    expect(arguments['text'], contains('测试隐私政策'));
    expect(arguments['subject'], contains('隐私政策'));
  });
}
