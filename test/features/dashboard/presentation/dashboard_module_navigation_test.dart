import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:lexcore/app/router/route_names.dart';
import 'package:lexcore/features/cases/presentation/pages/case_upload_page.dart';
import 'package:lexcore/features/dashboard/presentation/pages/case_dashboard_page.dart';

void main() {
  Future<void> setPhoneViewport(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });
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
          path: RouteNames.caseUploadPath,
          builder: (context, state) => const CaseUploadPage(),
        ),
      ],
    );
  }

  GoRouter buildDashboardEntryRouter() {
    return GoRouter(
      initialLocation: '/source',
      routes: [
        GoRoute(
          path: '/source',
          builder: (context, state) => const _LabelPage(
            title: 'Source Page',
            buttonLabel: '进入案件分析',
            targetPath: RouteNames.dashboardPath,
          ),
        ),
        GoRoute(
          path: RouteNames.dashboardPath,
          builder: (context, state) => const CaseDashboardPage(),
        ),
        GoRoute(
          path: RouteNames.caseUploadPath,
          builder: (context, state) => const CaseUploadPage(),
        ),
        GoRoute(
          path: RouteNames.homePath,
          builder: (context, state) => const _LabelPage(title: 'Home Page'),
        ),
      ],
    );
  }

  GoRouter buildDashboardFallbackRouter() {
    return GoRouter(
      initialLocation: RouteNames.dashboardPath,
      routes: [
        GoRoute(
          path: RouteNames.dashboardPath,
          builder: (context, state) => const CaseDashboardPage(),
        ),
        GoRoute(
          path: RouteNames.caseUploadPath,
          builder: (context, state) => const CaseUploadPage(),
        ),
        GoRoute(
          path: RouteNames.homePath,
          builder: (context, state) => const _LabelPage(title: 'Home Page'),
        ),
      ],
    );
  }

  Finder segmentButton(String label) {
    return find.descendant(
      of: find.byType(SegmentedButton<int>),
      matching: find.text(label),
    );
  }

  testWidgets('dashboard segmented tabs switch between overview and cases', (
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

    await tester.tap(segmentButton('案件'));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey<String>('dashboard_cases_page_title')),
      findsOneWidget,
    );
    expect(segmentButton('报告'), findsNothing);

    await tester.tap(segmentButton('概览'));
    await tester.pumpAndSettle();
    expect(find.text('进行中的案件分析'), findsOneWidget);
  });

  testWidgets('back button returns to source page', (tester) async {
    await setPhoneViewport(tester);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(routerConfig: buildDashboardEntryRouter()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Source Page'), findsOneWidget);
    await tester.tap(find.text('进入案件分析'));
    await tester.pumpAndSettle();
    expect(find.text('进行中的案件分析'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Source Page'), findsOneWidget);
  });

  testWidgets('back button falls back to home when stack cannot pop', (
    tester,
  ) async {
    await setPhoneViewport(tester);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(routerConfig: buildDashboardFallbackRouter()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('进行中的案件分析'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Home Page'), findsOneWidget);
  });

  testWidgets('fab opens case upload page', (tester) async {
    await setPhoneViewport(tester);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(routerConfig: buildDashboardRouter()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey<String>('dashboard_open_case_upload_fab')),
    );
    await tester.pumpAndSettle();

    expect(find.text('上传案件'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('case_upload_submit_button')),
      findsOneWidget,
    );
  });

}

class _LabelPage extends StatelessWidget {
  const _LabelPage({required this.title, this.buttonLabel, this.targetPath});

  final String title;
  final String? buttonLabel;
  final String? targetPath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title),
            if (buttonLabel != null && targetPath != null) ...[
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () => context.push(targetPath!),
                child: Text(buttonLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
