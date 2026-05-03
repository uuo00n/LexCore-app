import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lexcore/app/router/route_names.dart';
import 'package:lexcore/features/legal/presentation/pages/privacy_policy_page.dart';
import 'package:lexcore/features/legal/presentation/pages/terms_of_service_page.dart';
import 'package:lexcore/features/settings/presentation/pages/about_page.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('about page shows product and contact info', (tester) async {
    final router = GoRouter(
      initialLocation: RouteNames.aboutPath,
      routes: [
        GoRoute(
          path: RouteNames.aboutPath,
          builder: (context, state) => const AboutPage(),
        ),
        GoRoute(
          path: RouteNames.privacyPolicyPath,
          builder: (context, state) => const PrivacyPolicyPage(),
        ),
        GoRoute(
          path: RouteNames.termsOfServicePath,
          builder: (context, state) => const TermsOfServicePage(),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(child: MaterialApp.router(routerConfig: router)),
    );
    await tester.pumpAndSettle();

    expect(find.text('关于我们'), findsOneWidget);
    expect(find.text('衡法智核 LexCore'), findsOneWidget);
    expect(find.text('产品介绍'), findsOneWidget);
    expect(find.text('核心能力'), findsOneWidget);
    expect(find.textContaining('support@lexcore.cn'), findsOneWidget);
    expect(find.text('隐私政策'), findsOneWidget);
    expect(find.text('服务条款'), findsOneWidget);
  });
}
