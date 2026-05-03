import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lexcore/app/app.dart';
import 'package:lexcore/core/storage/local_storage.dart';

void main() {
  Future<void> setPhoneViewport(WidgetTester tester, Size size) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    tester.view.viewPadding = const FakeViewPadding(bottom: 34);
    tester.view.viewInsets = FakeViewPadding.zero;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.view.resetViewPadding();
      tester.view.resetViewInsets();
    });
  }

  Future<void> pumpApp(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
        child: const LexCoreApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> showKeyboard(
    WidgetTester tester, {
    double bottomInset = 320,
  }) async {
    tester.view.viewInsets = FakeViewPadding(bottom: bottomInset);
    await tester.pump();
  }

  Future<void> openRegisterPage(WidgetTester tester) async {
    await pumpApp(tester);
    await tester.ensureVisible(find.widgetWithText(TextButton, '立即注册'));
    await tester.tap(find.widgetWithText(TextButton, '立即注册'));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'login page keeps primary action size stable when keyboard appears',
    (WidgetTester tester) async {
      await setPhoneViewport(tester, const Size(390, 844));
      await pumpApp(tester);

      final loginButtonFinder = find.widgetWithText(FilledButton, '使用邮箱登录');
      final sizeBeforeKeyboard = tester.getSize(loginButtonFinder);

      await tester.tap(find.byType(TextField).first);
      await tester.pump();
      await showKeyboard(tester);

      final sizeAfterKeyboard = tester.getSize(loginButtonFinder);
      expect(sizeAfterKeyboard.width, closeTo(sizeBeforeKeyboard.width, 0.1));
      expect(sizeAfterKeyboard.height, closeTo(sizeBeforeKeyboard.height, 0.1));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'register page stays unscaled and scrolls when keyboard appears',
    (WidgetTester tester) async {
      await setPhoneViewport(tester, const Size(390, 667));
      await openRegisterPage(tester);

      final registerButtonFinder = find.widgetWithText(FilledButton, '立即注册');
      final registerButtonSize = tester.getSize(registerButtonFinder);

      await tester.tap(find.byType(TextField).at(1));
      await tester.pump();
      await showKeyboard(tester, bottomInset: 300);

      final buttonSizeWithKeyboard = tester.getSize(registerButtonFinder);
      expect(
        buttonSizeWithKeyboard.width,
        closeTo(registerButtonSize.width, 0.1),
      );
      expect(
        buttonSizeWithKeyboard.height,
        closeTo(registerButtonSize.height, 0.1),
      );

      final titleFinder = find.text('创建衡法智核账户');
      final titleDyBeforeDrag = tester.getTopLeft(titleFinder).dy;
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -220),
      );
      await tester.pump();

      expect(tester.getTopLeft(titleFinder).dy, lessThan(titleDyBeforeDrag));
      expect(tester.takeException(), isNull);
    },
  );
}
