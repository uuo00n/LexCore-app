import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:lexcore/app/router/route_names.dart';
import 'package:lexcore/core/network/api_client.dart';
import 'package:lexcore/features/search/data/repositories/search_repository.dart';
import 'package:lexcore/features/search/domain/entities/search_state.dart';
import 'package:lexcore/features/search/presentation/pages/legal_article_page.dart';
import 'package:lexcore/shared/models/legal_models.dart';
import 'package:lexcore/shared/widgets/in_app_webview_page.dart';

class _NoopApiClient extends ApiClient {
  _NoopApiClient() : super(Dio());
}

class _FakeSearchRepository extends SearchRepository {
  _FakeSearchRepository() : super(_NoopApiClient());

  @override
  Future<LawArticleDetail> articleDetail([LawSearchItem? item]) async {
    final current = item;
    if (current == null) {
      return const LawArticleDetail(
        title: '法律条文详情',
        tags: ['法规解读'],
        author: 'LexCore 法律研究',
        publishInfo: '最新',
        summary: '请选择法条查看详情。',
        quote: '法规详情',
        content: '请选择一条搜索结果查看详细内容。',
        bodySections: ['请选择一条搜索结果查看详细内容。'],
        citations: [LawCitationItem(title: '提示', subtitle: '示例引用')],
        fallbackMessage: '请选择法条查看详情。',
      );
    }
    if (current.articleCode == 'LAW-LINK') {
      return LawArticleDetail(
        title: current.title,
        tags: const ['地方性法规', '现行有效'],
        author: '吉林省人大常委会',
        publishInfo: '2007-11-30',
        summary: '当前法规正文未收录，可通过原文入口查看完整内容。',
        quote: current.snippet,
        content: '法规标题：吉林省劳动合同条例\n\n暂未获取到法规正文。',
        bodySections: const [],
        citations: const [
          LawCitationItem(title: '法规 ID', subtitle: 'LAW-LINK'),
        ],
        htmlUrl: 'https://example.com/law-link.html',
        pdfUrl: 'https://example.com/law-link.pdf',
        sourceUrl: 'https://example.com/law-link',
        fallbackMessage: '暂未获取到法规正文，可通过下方原文入口继续查看完整内容。',
      );
    }
    return LawArticleDetail(
      title: current.title,
      tags: const ['劳动法', '工资支付'],
      author: '全国人大',
      publishInfo: '2024-01-01',
      summary: '智能摘要：加班费应依法支付。',
      quote: current.snippet,
      content: '第四十四条 用人单位安排加班的，应当依法支付加班费。',
      bodySections: const [
        '第四十四条 用人单位安排加班的，应当依法支付加班费。',
        '休息日安排工作又不能安排补休的，应当支付相应报酬。',
      ],
      citations: const [
        LawCitationItem(title: '劳动合同法 第四十四条', subtitle: '加班费支付标准'),
      ],
      htmlUrl: 'https://example.com/laws/44.html',
      pdfUrl: 'https://example.com/laws/44.pdf',
      docxUrl: 'https://example.com/laws/44.docx',
      sourceUrl: 'https://example.com/laws/44',
    );
  }
}

void main() {
  Future<void> pumpLegalArticlePage(
    WidgetTester tester, {
    LawSearchItem? item,
  }) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => LegalArticlePage(searchItem: item),
        ),
        GoRoute(
          path: RouteNames.inAppWebViewPath,
          name: RouteNames.inAppWebView,
          builder: (context, state) {
            final args = state.extra! as InAppWebViewRouteArgs;
            return Scaffold(
              body: Text('WebView:${args.title}:${args.kind.name}:${args.url}'),
            );
          },
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          searchRepositoryProvider.overrideWithValue(_FakeSearchRepository()),
        ],
        child: MaterialApp.router(routerConfig: router),
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

  List<MethodCall> mockUrlLauncherChannel() {
    const channel = MethodChannel('plugins.flutter.io/url_launcher');
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          if (call.method == 'canLaunch') {
            return true;
          }
          if (call.method == 'launch' || call.method == 'launchUrl') {
            return true;
          }
          return true;
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
    expect(arguments['text'], contains('查看原文：https://example.com/laws/44'));
    expect(arguments['text'], contains('PDF：https://example.com/laws/44.pdf'));
  });

  testWidgets('shows body content and raw entry actions', (tester) async {
    const item = LawSearchItem(
      title: '劳动合同法第四十四条',
      snippet: '用人单位安排加班的，应当依法支付加班费。',
      articleCode: '法条 44',
    );

    await pumpLegalArticlePage(tester, item: item);

    expect(find.text('法规正文'), findsOneWidget);
    expect(find.text('第四十四条 用人单位安排加班的，应当依法支付加班费。'), findsOneWidget);
    expect(find.text('休息日安排工作又不能安排补休的，应当支付相应报酬。'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, '查看原文'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, '打开 HTML'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, '下载 PDF'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, '下载 DOCX'), findsOneWidget);
  });

  testWidgets('opens html raw link in in-app webview when tapping action', (
    tester,
  ) async {
    const item = LawSearchItem(
      title: '劳动合同法第四十四条',
      snippet: '用人单位安排加班的，应当依法支付加班费。',
      articleCode: '法条 44',
    );

    await pumpLegalArticlePage(tester, item: item);
    await tester.tap(find.widgetWithText(OutlinedButton, '查看原文').first);
    await tester.pumpAndSettle();

    expect(
      find.text('WebView:查看原文:html:https://example.com/laws/44'),
      findsOneWidget,
    );
  });

  testWidgets('opens external pdf link when tapping action', (tester) async {
    const item = LawSearchItem(
      title: '劳动合同法第四十四条',
      snippet: '用人单位安排加班的，应当依法支付加班费。',
      articleCode: '法条 44',
    );

    await pumpLegalArticlePage(tester, item: item);
    await tester.tap(find.widgetWithText(OutlinedButton, '下载 PDF').first);
    await tester.pumpAndSettle();

    expect(
      find.text('WebView:下载 PDF:pdf:https://example.com/laws/44.pdf'),
      findsOneWidget,
    );
  });

  testWidgets('keeps docx action opening externally', (tester) async {
    final calls = mockUrlLauncherChannel();
    const item = LawSearchItem(
      title: '劳动合同法第四十四条',
      snippet: '用人单位安排加班的，应当依法支付加班费。',
      articleCode: '法条 44',
    );

    await pumpLegalArticlePage(tester, item: item);
    await tester.tap(find.widgetWithText(OutlinedButton, '下载 DOCX').first);
    await tester.pumpAndSettle();

    expect(
      calls.any(
        (call) => call.arguments.toString().contains(
          'https://example.com/laws/44.docx',
        ),
      ),
      isTrue,
    );
  });

  testWidgets('shows fallback message and entry when body is missing', (
    tester,
  ) async {
    const item = LawSearchItem(
      title: '吉林省劳动合同条例',
      snippet: '地方性法规 · 现行有效',
      articleCode: 'LAW-LINK',
    );

    await pumpLegalArticlePage(tester, item: item);

    expect(find.text('暂未获取到法规正文，可通过下方原文入口继续查看完整内容。'), findsOneWidget);
    expect(
      find.widgetWithText(OutlinedButton, '查看原文'),
      findsAtLeastNWidgets(1),
    );
    expect(
      find.widgetWithText(OutlinedButton, '下载 PDF'),
      findsAtLeastNWidgets(1),
    );
    expect(find.text('法律引用与关联'), findsOneWidget);
  });

  testWidgets('citations are displayed without jump affordance', (
    tester,
  ) async {
    await pumpLegalArticlePage(tester);

    expect(find.text('法律引用与关联'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsNothing);
  });
}
