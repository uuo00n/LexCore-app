import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lexcore/features/search/presentation/pages/legal_article_page.dart';
import 'package:lexcore/shared/models/legal_models.dart';

void main() {
  Future<void> pumpLegalArticlePage(
    WidgetTester tester, {
    LawSearchItem? item,
  }) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(home: LegalArticlePage(searchItem: item)),
      ),
    );
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

  testWidgets('legal article shares detail summary', (tester) async {
    final calls = mockShareChannel();
    const item = LawSearchItem(
      title: '劳动合同法第四十四条',
      snippet: '用人单位安排加班的，应当依法支付加班费。',
      articleCode: '法条 44',
    );

    await pumpLegalArticlePage(tester, item: item);
    await tester.tap(find.byTooltip('分享'));
    await tester.pumpAndSettle();

    final arguments = calls.single.arguments as Map<Object?, Object?>;
    expect(arguments['subject'], '劳动合同法第四十四条');
    expect(arguments['text'], contains('智能摘要'));
    expect(arguments['text'], contains('用人单位安排加班的，应当依法支付加班费。'));
  });

  testWidgets('citations are displayed without jump affordance', (
    tester,
  ) async {
    await pumpLegalArticlePage(tester);

    expect(find.text('法律引用与关联'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsNothing);
  });
}
