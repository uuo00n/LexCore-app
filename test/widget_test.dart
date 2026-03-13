import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lexcore/app/app.dart';

void main() {
  Future<void> setPhoneViewport(WidgetTester tester, Size size) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: LexCoreApp()));
    await tester.pumpAndSettle();
  }

  Future<void> verifyAuthLayoutOnPhone(WidgetTester tester) async {
    await pumpApp(tester);

    final screenHeight =
        tester.view.physicalSize.height / tester.view.devicePixelRatio;
    final loginTermsBottom = tester.getBottomLeft(find.text('服务条款')).dy;
    expect(loginTermsBottom, greaterThan(screenHeight - 96));

    await tester.ensureVisible(find.text('立即注册'));
    await tester.tap(find.text('立即注册'));
    await tester.pumpAndSettle();

    expect(find.text('创建衡法智核账户'), findsOneWidget);
    expect(find.text('或'), findsOneWidget);
    expect(find.text('Google'), findsOneWidget);
    expect(find.text('微信'), findsOneWidget);
    expect(find.text('已经有账户了？'), findsOneWidget);

    final registerTermsBottom = tester.getBottomLeft(find.text('服务条款')).dy;
    expect(registerTermsBottom, greaterThan(screenHeight - 96));
    expect(
      (registerTermsBottom - loginTermsBottom).abs(),
      lessThanOrEqualTo(72),
    );
    expect(tester.takeException(), isNull);
  }

  testWidgets('App boots on login page', (WidgetTester tester) async {
    await setPhoneViewport(tester, const Size(390, 844));
    await pumpApp(tester);

    expect(
      find.byWidgetPredicate(
        (widget) => widget is SizedBox && widget.height == 54,
      ),
      findsOneWidget,
    );
    expect(find.text('LexCore'), findsOneWidget);
    expect(find.text('使用邮箱登录'), findsOneWidget);
    expect(find.text('使用微信账号继续'), findsOneWidget);
    expect(find.text('还没有账号？'), findsOneWidget);
    expect(find.text('立即注册'), findsOneWidget);
  });

  testWidgets('Footer stays fixed and aligned on tall phone', (
    WidgetTester tester,
  ) async {
    await setPhoneViewport(tester, const Size(390, 844));
    await verifyAuthLayoutOnPhone(tester);
  });

  testWidgets('Auth layout stays usable on small phone', (
    WidgetTester tester,
  ) async {
    await setPhoneViewport(tester, const Size(390, 667));
    await verifyAuthLayoutOnPhone(tester);
  });
}
