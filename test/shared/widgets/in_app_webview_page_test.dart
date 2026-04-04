import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lexcore/shared/widgets/in_app_webview_page.dart';

void main() {
  testWidgets('shows loading indicator while webview is loading', (
    tester,
  ) async {
    final loadState = ValueNotifier(InAppWebViewLoadState.loading);

    await tester.pumpWidget(
      MaterialApp(
        home: InAppWebViewPage(
          title: 'HTML 原文',
          url: 'https://example.com/law.html',
          kind: InAppWebViewKind.html,
          loadStateListenable: loadState,
          webViewChild: const Placeholder(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 120));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(Placeholder), findsOneWidget);
  });

  testWidgets('shows error state and retry action when loading fails', (
    tester,
  ) async {
    final loadState = ValueNotifier(InAppWebViewLoadState.error);
    var reloaded = false;

    await tester.pumpWidget(
      MaterialApp(
        home: InAppWebViewPage(
          title: 'PDF 原文',
          url: 'https://example.com/law.pdf',
          kind: InAppWebViewKind.pdf,
          loadStateListenable: loadState,
          webViewChild: const Placeholder(),
          onReloadOverride: () async {
            reloaded = true;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('页面加载失败，请稍后重试。'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, '重新加载'));
    await tester.pump();

    expect(reloaded, isTrue);
  });

  testWidgets('opens external browser from fallback action', (tester) async {
    final loadState = ValueNotifier(InAppWebViewLoadState.error);
    Uri? openedUri;

    await tester.pumpWidget(
      MaterialApp(
        home: InAppWebViewPage(
          title: 'HTML 原文',
          url: 'https://example.com/law.html',
          kind: InAppWebViewKind.html,
          loadStateListenable: loadState,
          webViewChild: const Placeholder(),
          onOpenExternalOverride: (uri) async {
            openedUri = uri;
            return true;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(TextButton, '在浏览器中打开'));
    await tester.pump();

    expect(openedUri?.toString(), 'https://example.com/law.html');
  });
}
