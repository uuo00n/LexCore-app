import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:lexcore/app/router/route_names.dart';
import 'package:lexcore/features/cases/presentation/pages/case_detail_page.dart';
import 'package:lexcore/features/dashboard/presentation/pages/case_dashboard_cases_page.dart';

void main() {
  Future<void> pumpCasesPage(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: CaseDashboardCasesContent())),
    );
    await tester.pump(const Duration(milliseconds: 800));
  }

  testWidgets('filters cases with primary status chips', (tester) async {
    await pumpCasesPage(tester);

    expect(find.text('草稿'), findsNothing);
    expect(find.text('张三与李四房屋所有权纠纷案'), findsOneWidget);
    expect(find.text('某科技公司专利侵权损害赔偿案'), findsOneWidget);
    expect(find.text('王五职务侵占刑事辩护案'), findsOneWidget);
    expect(find.text('跨境电商劳动合同仲裁案件'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey<String>('dashboard_cases_filter_in_progress')),
    );
    await tester.pumpAndSettle();

    expect(find.text('张三与李四房屋所有权纠纷案'), findsOneWidget);
    expect(find.text('跨境电商劳动合同仲裁案件'), findsOneWidget);
    expect(find.text('某科技公司专利侵权损害赔偿案'), findsNothing);
    expect(find.text('王五职务侵占刑事辩护案'), findsNothing);

    await tester.tap(
      find.byKey(const ValueKey<String>('dashboard_cases_filter_closed')),
    );
    await tester.pumpAndSettle();

    expect(find.text('某科技公司专利侵权损害赔偿案'), findsOneWidget);
    expect(find.text('张三与李四房屋所有权纠纷案'), findsNothing);
    expect(find.text('王五职务侵占刑事辩护案'), findsNothing);
    expect(find.text('跨境电商劳动合同仲裁案件'), findsNothing);
  });

  testWidgets('selects waiting cases from more filters and resets to all', (
    tester,
  ) async {
    await pumpCasesPage(tester);

    await tester.tap(
      find.byKey(const ValueKey<String>('dashboard_cases_filter_more')),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('dashboard_cases_more_waiting_option')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('dashboard_cases_more_draft_option')),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('dashboard_cases_more_waiting_option')),
    );
    await tester.pumpAndSettle();

    expect(find.text('王五职务侵占刑事辩护案'), findsOneWidget);
    expect(find.text('张三与李四房屋所有权纠纷案'), findsNothing);
    expect(find.text('某科技公司专利侵权损害赔偿案'), findsNothing);
    expect(find.text('跨境电商劳动合同仲裁案件'), findsNothing);

    await tester.tap(
      find.byKey(const ValueKey<String>('dashboard_cases_filter_all')),
    );
    await tester.pumpAndSettle();

    expect(find.text('张三与李四房屋所有权纠纷案'), findsOneWidget);
    expect(find.text('某科技公司专利侵权损害赔偿案'), findsOneWidget);
    expect(find.text('王五职务侵占刑事辩护案'), findsOneWidget);
    expect(find.text('跨境电商劳动合同仲裁案件'), findsOneWidget);
  });

  testWidgets('shows empty state when draft filter is selected from more', (
    tester,
  ) async {
    await pumpCasesPage(tester);

    await tester.tap(
      find.byKey(const ValueKey<String>('dashboard_cases_filter_more')),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey<String>('dashboard_cases_more_draft_option')),
    );
    await tester.pumpAndSettle();

    expect(find.text('暂无草稿案件'), findsOneWidget);
    expect(find.text('当前还没有保存到草稿的案件分析。'), findsOneWidget);
    expect(find.text('张三与李四房屋所有权纠纷案'), findsNothing);
    expect(find.text('某科技公司专利侵权损害赔偿案'), findsNothing);
    expect(find.text('王五职务侵占刑事辩护案'), findsNothing);
    expect(find.text('跨境电商劳动合同仲裁案件'), findsNothing);
  });

  testWidgets('opens case detail page from detail action', (tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) =>
              const Scaffold(body: CaseDashboardCasesContent()),
        ),
        GoRoute(
          path: RouteNames.caseDetailPath,
          builder: (context, state) => CaseDetailPage(
            detail: state.extra is CaseDetailData
                ? state.extra! as CaseDetailData
                : CaseDetailData.demo(),
          ),
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
    await tester.pump(const Duration(milliseconds: 800));

    await tester.tap(
      find.byKey(const ValueKey<String>('dashboard_cases_detail_button_0')),
    );
    await tester.pumpAndSettle();

    expect(find.text('案件详情'), findsOneWidget);
    expect(find.text('张三与李四房屋所有权纠纷案'), findsOneWidget);
    expect(find.text('案件分析速览'), findsOneWidget);
  });
}
