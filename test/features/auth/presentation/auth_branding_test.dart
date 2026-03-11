import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lexcore/features/auth/presentation/pages/auth_page.dart';
import 'package:lexcore/features/auth/presentation/pages/register_page.dart';

void main() {
  testWidgets('login page shows LexCore branding copy', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: AuthPage())),
    );
    await tester.pumpAndSettle();

    expect(find.text('衡法智核 LexCore'), findsOneWidget);
    expect(find.text('智能法律服务平台\n以智能内核重塑法律服务效率'), findsOneWidget);
    expect(find.text('已阅读并同意《服务条款》《隐私政策》'), findsOneWidget);

    expect(find.text('LexiAI'), findsNothing);
    expect(find.text('您的智能阅读与学习助手，\n开启深度阅读的新篇章。'), findsNothing);
    expect(find.text('已阅读并同意《用户协议》《隐私政策》'), findsNothing);
  });

  testWidgets('register page shows LexCore branding copy', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: RegisterPage())),
    );
    await tester.pumpAndSettle();

    expect(find.text('注册 LexCore'), findsOneWidget);
    expect(find.text('创建衡法智核账户'), findsOneWidget);
    expect(find.text('衡法智核 LexCore——智能法律服务平台\n以智能内核重塑法律服务效率'), findsOneWidget);
    expect(find.text('已阅读并同意《服务条款》《隐私政策》'), findsOneWidget);

    expect(find.text('注册 LexiAI'), findsNothing);
    expect(find.text('加入 LexiAI，开启高效智能法律服务体验'), findsNothing);
    expect(find.text('已阅读并同意《用户协议》《隐私政策》'), findsNothing);
  });
}
