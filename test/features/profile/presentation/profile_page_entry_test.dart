import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lexcore/app/router/route_names.dart';
import 'package:lexcore/core/storage/local_storage.dart';
import 'package:lexcore/features/profile/presentation/pages/profile_billing_page.dart';
import 'package:lexcore/features/profile/presentation/pages/profile_billing_orders_page.dart';
import 'package:lexcore/features/profile/presentation/pages/profile_billing_payment_methods_page.dart';
import 'package:lexcore/features/profile/presentation/pages/profile_page.dart';
import 'package:lexcore/features/profile/presentation/pages/profile_personal_info_page.dart';
import 'package:lexcore/features/profile/presentation/pages/profile_security_page.dart';
import 'package:lexcore/features/profile/presentation/pages/profile_subscription_cancel_renewal_page.dart';
import 'package:lexcore/features/profile/presentation/pages/profile_subscription_manage_page.dart';
import 'package:lexcore/features/profile/presentation/pages/profile_subscription_renewal_cycle_page.dart';
import 'package:lexcore/features/profile/presentation/pages/profile_subscription_upgrade_page.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> tapTopBackButton(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();
  }

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
          path: RouteNames.profileBillingOrdersPath,
          builder: (context, state) => const ProfileBillingOrdersPage(),
        ),
        GoRoute(
          path: RouteNames.profileBillingPaymentMethodsPath,
          builder: (context, state) => const ProfileBillingPaymentMethodsPage(),
        ),
        GoRoute(
          path: RouteNames.profileSubscriptionManagePath,
          builder: (context, state) => const ProfileSubscriptionManagePage(),
        ),
        GoRoute(
          path: RouteNames.profileSubscriptionUpgradePath,
          builder: (context, state) => const ProfileSubscriptionUpgradePage(),
        ),
        GoRoute(
          path: RouteNames.profileSubscriptionRenewalCyclePath,
          builder: (context, state) =>
              const ProfileSubscriptionRenewalCyclePage(),
        ),
        GoRoute(
          path: RouteNames.profileSubscriptionCancelRenewalPath,
          builder: (context, state) =>
              const ProfileSubscriptionCancelRenewalPage(),
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
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(
            await SharedPreferences.getInstance(),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
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

    await tapTopBackButton(tester);
    await tester.tap(find.text('账号安全').first);
    await tester.pumpAndSettle();
    expect(find.byType(ProfileSecurityPage), findsOneWidget);

    await tapTopBackButton(tester);
    await tester.tap(find.text('账单与订阅').first);
    await tester.pumpAndSettle();
    expect(find.byType(ProfileBillingPage), findsOneWidget);
  });

  testWidgets('history entry on profile page does not navigate', (
    tester,
  ) async {
    await pumpProfileRouter(tester);

    await tester.ensureVisible(find.text('历史记录').first);
    await tester.tap(find.text('历史记录').first, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.byType(ProfilePage), findsOneWidget);
    expect(find.text('历史页'), findsNothing);
  });

  testWidgets('manage subscription entry navigates to dedicated page', (
    tester,
  ) async {
    await pumpProfileRouter(tester);

    await tester.tap(find.text('管理订阅'));
    await tester.pumpAndSettle();

    expect(find.byType(ProfileSubscriptionManagePage), findsOneWidget);
  });

  testWidgets('billing sub entries navigate to dedicated pages', (
    tester,
  ) async {
    await pumpProfileRouter(tester);

    await tester.tap(find.text('账单与订阅').first);
    await tester.pumpAndSettle();
    expect(find.byType(ProfileBillingPage), findsOneWidget);

    await tester.tap(find.text('历史订单').first);
    await tester.pumpAndSettle();
    expect(find.byType(ProfileBillingOrdersPage), findsOneWidget);

    await tapTopBackButton(tester);
    await tester.tap(find.text('支付方式').first);
    await tester.pumpAndSettle();
    expect(find.byType(ProfileBillingPaymentMethodsPage), findsOneWidget);
  });

  testWidgets('manage subscription sub entries navigate to dedicated pages', (
    tester,
  ) async {
    await pumpProfileRouter(tester);

    await tester.tap(find.text('管理订阅'));
    await tester.pumpAndSettle();
    expect(find.byType(ProfileSubscriptionManagePage), findsOneWidget);

    await tester.tap(find.text('升级套餐').first);
    await tester.pumpAndSettle();
    expect(find.byType(ProfileSubscriptionUpgradePage), findsOneWidget);

    await tapTopBackButton(tester);
    await tester.tap(find.text('调整续费周期').first);
    await tester.pumpAndSettle();
    expect(find.byType(ProfileSubscriptionRenewalCyclePage), findsOneWidget);

    await tapTopBackButton(tester);
    await tester.tap(find.text('取消自动续费').first);
    await tester.pumpAndSettle();
    expect(find.byType(ProfileSubscriptionCancelRenewalPage), findsOneWidget);
  });
}
