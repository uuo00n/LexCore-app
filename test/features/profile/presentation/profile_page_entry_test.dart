import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lexcore/app/router/route_names.dart';
import 'package:lexcore/features/profile/presentation/pages/profile_billing_page.dart';
import 'package:lexcore/features/profile/presentation/pages/profile_page.dart';
import 'package:lexcore/features/profile/presentation/pages/profile_personal_info_page.dart';
import 'package:lexcore/features/profile/presentation/pages/profile_security_page.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pumpProfileRouter(WidgetTester tester) async {
    final router = GoRouter(
      initialLocation: RouteNames.profilePath,
      routes: [
        GoRoute(
          path: RouteNames.profilePath,
          builder: (context, state) => const ProfilePage(),
        ),
        GoRoute(
          path: RouteNames.profilePersonalInfoPath,
          builder: (context, state) => const ProfilePersonalInfoPage(),
        ),
        GoRoute(
          path: RouteNames.profileSecurityPath,
          builder: (context, state) => const ProfileSecurityPage(),
        ),
        GoRoute(
          path: RouteNames.profileBillingPath,
          builder: (context, state) => const ProfileBillingPage(),
        ),
        GoRoute(
          path: RouteNames.savedDocumentsPath,
          builder: (context, state) => const Scaffold(body: Text('我的文档页')),
        ),
        GoRoute(
          path: RouteNames.historyPath,
          builder: (context, state) => const Scaffold(body: Text('历史页')),
        ),
        GoRoute(
          path: RouteNames.settingsPath,
          builder: (context, state) => const Scaffold(body: Text('设置页')),
        ),
      ],
    );

    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(
      ProviderScope(child: MaterialApp.router(routerConfig: router)),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('profile page groups entries and removes duplicate exits/help', (
    tester,
  ) async {
    await pumpProfileRouter(tester);

    expect(find.text('账号与订阅'), findsOneWidget);
    expect(find.text('内容与记录'), findsOneWidget);
    expect(find.text('帮助与支持'), findsNothing);
    expect(find.text('退出登录'), findsNothing);
    expect(find.byIcon(Icons.edit), findsNothing);
  });

  testWidgets('profile account entries navigate to dedicated pages', (
    tester,
  ) async {
    await pumpProfileRouter(tester);

    await tester.tap(find.text('个人信息').first);
    await tester.pumpAndSettle();
    expect(find.byType(ProfilePersonalInfoPage), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('账号安全').first);
    await tester.pumpAndSettle();
    expect(find.byType(ProfileSecurityPage), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('账单与订阅').first);
    await tester.pumpAndSettle();
    expect(find.byType(ProfileBillingPage), findsOneWidget);
  });
}
