import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lexcore/shared/widgets/app_shell_top_bar.dart';

void main() {
  const viewportSize = Size(390, 844);

  Future<void> pumpTopBar(
    WidgetTester tester, {
    required AppShellTopBar topBar,
  }) async {
    await tester.binding.setSurfaceSize(viewportSize);
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                topBar,
                const Expanded(child: SizedBox()),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  void expectTitleCentered(WidgetTester tester, String title) {
    final centerX = tester.getCenter(find.text(title)).dx;
    expect(centerX, closeTo(viewportSize.width / 2, 2.0));
  }

  testWidgets('centers title without leading or actions', (tester) async {
    await pumpTopBar(tester, topBar: const AppShellTopBar(title: 'LexCore'));

    expectTitleCentered(tester, 'LexCore');
  });

  testWidgets('centers title with a single trailing action', (tester) async {
    await pumpTopBar(
      tester,
      topBar: AppShellTopBar(
        title: '历史记录',
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.search))],
      ),
    );

    expectTitleCentered(tester, '历史记录');
  });

  testWidgets('centers title with leading and one trailing action', (
    tester,
  ) async {
    await pumpTopBar(
      tester,
      topBar: AppShellTopBar(
        title: '法律咨询',
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add_comment_outlined),
          ),
        ],
      ),
    );

    expectTitleCentered(tester, '法律咨询');
  });

  testWidgets('centers title with leading and two trailing actions', (
    tester,
  ) async {
    await pumpTopBar(
      tester,
      topBar: AppShellTopBar(
        title: '案件详情',
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.share_outlined)),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert_rounded),
          ),
        ],
      ),
    );

    expectTitleCentered(tester, '案件详情');
  });

  testWidgets('centers title with three trailing actions and truncates text', (
    tester,
  ) async {
    const title = '中华人民共和国劳动合同法第四十七条';

    await pumpTopBar(
      tester,
      topBar: AppShellTopBar(
        title: title,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.bookmark_border)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.share_outlined)),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert_rounded),
          ),
        ],
      ),
    );

    expectTitleCentered(tester, title);
    final titleText = tester.widget<Text>(find.text(title));
    expect(titleText.maxLines, 1);
    expect(titleText.overflow, TextOverflow.ellipsis);
  });
}
