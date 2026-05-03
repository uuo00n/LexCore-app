import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lexcore/app/adaptive/app_breakpoints.dart';
import 'package:lexcore/app/navigation/app_shell_destinations.dart';
import 'package:lexcore/app/navigation/app_sidebar_navigation.dart';
import 'package:lexcore/features/home/application/home_providers.dart';
import 'package:lexcore/shared/widgets/app_bottom_navigation.dart';
import 'package:lexcore/shared/widgets/app_mobile_canvas.dart';

class MainShellPage extends ConsumerWidget {
  const MainShellPage({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewport = AppBreakpoints.fromWidth(constraints.maxWidth);
        final showSidebar = AppBreakpoints.showDesktopSidebar(viewport);

        if (!showSidebar) {
          return Scaffold(
            body: navigationShell,
            bottomNavigationBar: AppMobileCanvas(
              child: SafeArea(
                top: false,
                child: AppBottomNavigation(
                  currentIndex: navigationShell.currentIndex,
                  items: appShellDestinations,
                  onTap: (index) => _onDestinationTap(ref, index),
                ),
              ),
            ),
          );
        }

        final sidebarWidth = viewport == AppViewportSize.medium ? 220.0 : 244.0;

        return Scaffold(
          body: SafeArea(
            child: Row(
              children: [
                SizedBox(
                  width: sidebarWidth,
                  child: AppSidebarNavigation(
                    currentIndex: navigationShell.currentIndex,
                    items: appShellDestinations,
                    onSelect: (index) => _onDestinationTap(ref, index),
                  ),
                ),
                VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: Theme.of(context).dividerColor,
                ),
                Expanded(child: navigationShell),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onDestinationTap(WidgetRef ref, int index) {
    if (index == 0) {
      ref.invalidate(homeDataProvider);
    }
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
