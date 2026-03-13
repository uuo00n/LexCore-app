import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:lexcore/app/navigation/main_shell_page.dart';
import 'package:lexcore/app/router/route_names.dart';
import 'package:lexcore/features/history/presentation/pages/history_page.dart';
import 'package:lexcore/features/history/presentation/pages/history_search_page.dart';
import 'package:lexcore/shared/components/app_list_tile_item.dart';
import 'package:lexcore/shared/widgets/app_bottom_navigation.dart';

void main() {
  Future<void> setPhoneViewport(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });
  }

  Future<void> pumpHistorySearchPage(WidgetTester tester) async {
    await setPhoneViewport(tester);
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HistorySearchPage())),
    );
    await tester.pump(const Duration(milliseconds: 900));
  }

  GoRouter buildHistoryShellRouter() {
    final rootNavigatorKey = GlobalKey<NavigatorState>();

    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: RouteNames.historyPath,
      routes: [
        StatefulShellRoute(
          builder: (context, state, navigationShell) =>
              MainShellPage(navigationShell: navigationShell),
          navigatorContainerBuilder: (context, navigationShell, children) =>
              IndexedStack(
                index: navigationShell.currentIndex,
                children: children,
              ),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RouteNames.homePath,
                  builder: (context, state) => const _LabelPage('首页'),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RouteNames.legalSearchPath,
                  builder: (context, state) => const _LabelPage('搜索'),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RouteNames.historyPath,
                  builder: (context, state) => const HistoryPage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RouteNames.profilePath,
                  builder: (context, state) => const _LabelPage('我的'),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: RouteNames.historySearchPath,
          name: RouteNames.historySearch,
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) => const HistorySearchPage(),
        ),
      ],
    );
  }

  testWidgets('history search supports keyword and category filtering', (
    tester,
  ) async {
    await pumpHistorySearchPage(tester);

    expect(find.byType(AppListTileItem), findsNWidgets(3));

    await tester.enterText(
      find.byKey(const ValueKey<String>('history_search_keyword_field')),
      '仲裁',
    );
    await tester.pumpAndSettle();

    expect(find.byType(AppListTileItem), findsNWidgets(2));
    expect(find.text('劳动仲裁风险分析'), findsOneWidget);
    expect(find.text('劳动仲裁申请书草稿'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey<String>('history_search_filter_analysis')),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AppListTileItem), findsOneWidget);
    expect(find.text('劳动仲裁风险分析'), findsOneWidget);
    expect(find.text('劳动仲裁申请书草稿'), findsNothing);

    await tester.tap(
      find.byKey(const ValueKey<String>('history_search_reset_button')),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AppListTileItem), findsNWidgets(3));
  });

  testWidgets('calendar action opens material date range picker', (
    tester,
  ) async {
    await pumpHistorySearchPage(tester);

    await tester.tap(
      find.byKey(
        const ValueKey<String>('history_search_open_time_dialog_button'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(DateRangePickerDialog), findsOneWidget);
  });

  testWidgets('history search entry opens fullscreen page without bottom nav', (
    tester,
  ) async {
    await setPhoneViewport(tester);
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(routerConfig: buildHistoryShellRouter()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('历史记录'), findsOneWidget);
    expect(find.byType(AppBottomNavigation), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey<String>('history_page_open_search_button')),
    );
    await tester.pumpAndSettle();

    expect(find.text('历史记录搜索'), findsOneWidget);
    expect(find.byType(AppBottomNavigation), findsNothing);
  });
}

class _LabelPage extends StatelessWidget {
  const _LabelPage(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text(title)));
  }
}
