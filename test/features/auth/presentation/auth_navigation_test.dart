import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lexcore/app/app.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: LexCoreApp()));
    await tester.pumpAndSettle();
  }

  Future<void> openRegisterPage(WidgetTester tester) async {
    await pumpApp(tester);

    await tester.ensureVisible(find.widgetWithText(TextButton, '立即注册'));
    await tester.tap(find.widgetWithText(TextButton, '立即注册'));
    await tester.pumpAndSettle();

    expect(find.text('注册 LexCore'), findsOneWidget);
    expect(find.text('创建衡法智核账户'), findsOneWidget);
  }

  void expectAuthPageVisible() {
    expect(find.text('LexCore'), findsOneWidget);
    expect(find.text('使用邮箱登录'), findsOneWidget);
    expect(find.text('创建衡法智核账户'), findsNothing);
  }

  testWidgets('system back returns from register page to auth page', (
    WidgetTester tester,
  ) async {
    await openRegisterPage(tester);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expectAuthPageVisible();
  });

  testWidgets('top back button returns from register page to auth page', (
    WidgetTester tester,
  ) async {
    await openRegisterPage(tester);

    await tester.tap(find.byTooltip('返回'));
    await tester.pumpAndSettle();

    expectAuthPageVisible();
  });

  testWidgets('footer login action returns from register page to auth page', (
    WidgetTester tester,
  ) async {
    await openRegisterPage(tester);

    await tester.ensureVisible(find.widgetWithText(TextButton, '登录'));
    await tester.tap(find.widgetWithText(TextButton, '登录'));
    await tester.pumpAndSettle();

    expectAuthPageVisible();
  });
}
