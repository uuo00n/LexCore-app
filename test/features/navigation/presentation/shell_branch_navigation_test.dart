import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:lexcore/app/navigation/main_shell_page.dart';
import 'package:lexcore/app/router/route_names.dart';
import 'package:lexcore/core/extensions/router_navigation_extensions.dart';
import 'package:lexcore/features/home/application/home_providers.dart';
import 'package:lexcore/features/home/domain/entities/home_entity.dart';
import 'package:lexcore/features/home/presentation/pages/home_page.dart';
import 'package:lexcore/shared/models/legal_models.dart';
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

  GoRouter buildProfileHistoryRouter() {
    return GoRouter(
      initialLocation: RouteNames.profilePath,
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
                  builder: (context, state) => const _LabelPage('首页页'),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RouteNames.legalSearchPath,
                  builder: (context, state) => const _LabelPage('搜索页'),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RouteNames.historyPath,
                  builder: (context, state) => const _LabelPage('History Root'),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RouteNames.profilePath,
                  builder: (context, state) => const _ProfileMenuTestPage(),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  GoRouter buildReselectRouter() {
    return GoRouter(
      initialLocation: '${RouteNames.profilePath}/detail',
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
                  builder: (context, state) => const _LabelPage('首页页'),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RouteNames.legalSearchPath,
                  builder: (context, state) => const _LabelPage('搜索页'),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RouteNames.historyPath,
                  builder: (context, state) => const _LabelPage('历史页'),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RouteNames.profilePath,
                  builder: (context, state) => const _LabelPage('Profile Root'),
                  routes: [
                    GoRoute(
                      path: 'detail',
                      builder: (context, state) =>
                          const _LabelPage('Profile Detail'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  GoRouter buildHomeRefreshRouter() {
    return GoRouter(
      initialLocation: RouteNames.profilePath,
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
                  builder: (context, state) => const HomePage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RouteNames.legalSearchPath,
                  builder: (context, state) => const _LabelPage('搜索页'),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RouteNames.historyPath,
                  builder: (context, state) => const _LabelPage('历史页'),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RouteNames.profilePath,
                  builder: (context, state) => const _LabelPage('Profile Root'),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  testWidgets(
    'navigating from profile history menu keeps bottom nav functional',
    (tester) async {
      await setPhoneViewport(tester);
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(routerConfig: buildProfileHistoryRouter()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Profile Root'), findsOneWidget);

      await tester.tap(find.text('Go History'));
      await tester.pumpAndSettle();
      expect(find.text('History Root'), findsOneWidget);

      await tester.tap(bottomNavItem('我的'));
      await tester.pumpAndSettle();
      expect(find.text('Profile Root'), findsOneWidget);
    },
  );

  testWidgets('reselecting current tab returns to branch root page', (
    tester,
  ) async {
    await setPhoneViewport(tester);
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(routerConfig: buildReselectRouter()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Profile Detail'), findsOneWidget);

    await tester.tap(bottomNavItem('我的'));
    await tester.pumpAndSettle();
    expect(find.text('Profile Root'), findsOneWidget);
  });

  testWidgets('switching to home tab refreshes home data provider', (
    tester,
  ) async {
    await setPhoneViewport(tester);
    var loadCount = 0;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeDataProvider.overrideWith((ref) async {
            loadCount += 1;
            return const HomeEntity(
              actions: [
                QuickAction(
                  title: '法律咨询',
                  subtitle: '智能问答',
                  icon: 'chat_bubble',
                  route: '/consultation',
                ),
              ],
              activities: [],
            );
          }),
        ],
        child: MaterialApp.router(routerConfig: buildHomeRefreshRouter()),
      ),
    );
    await tester.pumpAndSettle();

    final beforeSwitch = loadCount;
    expect(find.text('Profile Root'), findsOneWidget);

    await tester.tap(bottomNavItem('首页'));
    await tester.pumpAndSettle();

    expect(find.byType(HomePage), findsOneWidget);
    expect(loadCount, greaterThan(beforeSwitch));
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

class _ProfileMenuTestPage extends StatelessWidget {
  const _ProfileMenuTestPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Profile Root'),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () => context.navigateByRoute(RouteNames.historyPath),
              child: const Text('Go History'),
            ),
          ],
        ),
      ),
    );
  }
}
