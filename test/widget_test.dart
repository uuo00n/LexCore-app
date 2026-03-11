import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lexcore/app/app.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: LexCoreApp()));
    await tester.pumpAndSettle();
  }

  testWidgets('App boots on login page', (WidgetTester tester) async {
    await pumpApp(tester);

    expect(
      find.byWidgetPredicate(
        (widget) => widget is SizedBox && widget.height == 54,
      ),
      findsOneWidget,
    );
    expect(find.text('LexiAI'), findsOneWidget);
    expect(find.text('使用邮箱登录'), findsOneWidget);
    expect(find.text('使用 Google 账号继续'), findsOneWidget);
    expect(find.text('还没有账号？'), findsOneWidget);
    expect(find.text('立即注册'), findsOneWidget);

    final screenHeight =
        tester.view.physicalSize.height / tester.view.devicePixelRatio;
    final termsBottom = tester.getBottomLeft(find.text('服务条款')).dy;
    expect(termsBottom, greaterThan(screenHeight - 96));
  });

  testWidgets('Navigate to register page keeps social buttons style', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);

    await tester.ensureVisible(find.text('立即注册'));
    await tester.tap(find.text('立即注册'));
    await tester.pumpAndSettle();

    expect(find.text('创建您的账户'), findsOneWidget);
    expect(find.text('或'), findsOneWidget);
    expect(find.text('Google'), findsOneWidget);
    expect(find.text('微信'), findsOneWidget);
    expect(find.text('已经有账户了？'), findsOneWidget);

    final screenHeight =
        tester.view.physicalSize.height / tester.view.devicePixelRatio;
    final termsBottom = tester.getBottomLeft(find.text('服务条款')).dy;
    expect(termsBottom, greaterThan(screenHeight - 96));
  });
}
