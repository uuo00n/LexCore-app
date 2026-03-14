import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lexcore/shared/widgets/app_page_scaffold.dart';
import 'package:lexcore/shared/widgets/app_shell_top_bar.dart';

void main() {
  const viewportSize = Size(390, 844);

  Future<void> pumpPageScaffold(
    WidgetTester tester, {
    required AppPageScaffold scaffold,
  }) async {
    await tester.binding.setSurfaceSize(viewportSize);
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(MaterialApp(home: scaffold));
    await tester.pumpAndSettle();
  }

  void expectTitleCentered(WidgetTester tester, String title) {
    final centerX = tester.getCenter(find.text(title)).dx;
    expect(centerX, closeTo(viewportSize.width / 2, 2.0));
  }

  testWidgets('renders AppShellTopBar and centers title with many actions', (
    tester,
  ) async {
    await pumpPageScaffold(
      tester,
      scaffold: AppPageScaffold(
        title: '文章详情',
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.bookmark_border)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.share_outlined)),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert_rounded),
          ),
        ],
        body: const SizedBox.expand(),
      ),
    );

    expect(find.byType(AppShellTopBar), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    expectTitleCentered(tester, '文章详情');
  });

  testWidgets('keeps title centered when back button is hidden', (
    tester,
  ) async {
    await pumpPageScaffold(
      tester,
      scaffold: AppPageScaffold(
        title: '设置',
        showBackButton: false,
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.search))],
        body: const SizedBox.expand(),
      ),
    );

    expect(find.byType(AppShellTopBar), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_rounded), findsNothing);
    expectTitleCentered(tester, '设置');
  });
}
