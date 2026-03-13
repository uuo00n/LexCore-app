import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:lexcore/app/router/route_names.dart';
import 'package:lexcore/features/dashboard/presentation/pages/case_dashboard_cases_page.dart';
import 'package:lexcore/features/dashboard/presentation/pages/case_dashboard_page.dart';
import 'package:lexcore/features/dashboard/presentation/pages/case_dashboard_reports_page.dart';
import 'package:lexcore/shared/widgets/app_bottom_navigation.dart';

void main() {
  Future<void> setPhoneViewport(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });
  }

  Finder bottomNavItem(String label) {
    return find.descendant(
      of: find.byType(AppBottomNavigation),
      matching: find.text(label),
    );
  }

  GoRouter buildDashboardRouter() {
    return GoRouter(
      initialLocation: RouteNames.dashboardPath,
      routes: [
        GoRoute(
          path: RouteNames.dashboardPath,
          builder: (context, state) => const CaseDashboardPage(),
        ),
        GoRoute(
          path: RouteNames.dashboardCasesPath,
          builder: (context, state) => const CaseDashboardCasesPage(),
        ),
        GoRoute(
          path: RouteNames.dashboardReportsPath,
          builder: (context, state) => const CaseDashboardReportsPage(),
        ),
      ],
    );
  }

  testWidgets('dashboard module tabs switch among overview/cases/reports', (
    tester,
  ) async {
    await setPhoneViewport(tester);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(routerConfig: buildDashboardRouter()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('进行中的案件分析'), findsOneWidget);

    await tester.tap(bottomNavItem('案件'));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey<String>('dashboard_cases_page_title')),
      findsOneWidget,
    );

    await tester.tap(bottomNavItem('报告'));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey<String>('dashboard_reports_page_title')),
      findsOneWidget,
    );

    await tester.tap(bottomNavItem('概览'));
    await tester.pumpAndSettle();
    expect(find.text('进行中的案件分析'), findsOneWidget);
  });
}
