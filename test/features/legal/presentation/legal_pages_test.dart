import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lexcore/features/legal/presentation/pages/privacy_policy_page.dart';
import 'package:lexcore/features/legal/presentation/pages/terms_of_service_page.dart';

void main() {
  testWidgets(
    'terms page shows dynamic reading progress and markdown content',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: TermsOfServicePage()));
      await tester.pumpAndSettle();

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.text('确认并同意'), findsNothing);
      expect(find.text('衡法智核 LexCore 用户服务协议'), findsOneWidget);

      final initialIndicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      final initialProgress = initialIndicator.value ?? 0;

      await tester.drag(find.byType(Markdown), const Offset(0, -700));
      await tester.pumpAndSettle();

      final updatedIndicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      final updatedProgress = updatedIndicator.value ?? 0;
      expect(updatedProgress, greaterThan(initialProgress));
    },
  );

  testWidgets('privacy page keeps redesigned header and dynamic progress', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: PrivacyPolicyPage()));
    await tester.pumpAndSettle();

    expect(find.text('专业法律AI助手 LexiAI'), findsNothing);
    expect(find.text('隐私政策文档'), findsOneWidget);
    expect(find.text('衡法智核 LexCore 隐私政策'), findsOneWidget);

    final initialIndicator = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );
    final initialProgress = initialIndicator.value ?? 0;

    await tester.drag(find.byType(Markdown), const Offset(0, -700));
    await tester.pumpAndSettle();

    final updatedIndicator = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );
    final updatedProgress = updatedIndicator.value ?? 0;
    expect(updatedProgress, greaterThan(initialProgress));
  });
}
