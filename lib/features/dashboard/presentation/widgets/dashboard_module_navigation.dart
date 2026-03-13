import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:lexcore/app/navigation/app_shell_destinations.dart';
import 'package:lexcore/app/router/route_names.dart';
import 'package:lexcore/shared/widgets/app_shell_top_bar.dart';

const dashboardModuleDestinations = <AppShellDestination>[
  AppShellDestination(
    label: '概览',
    icon: Icons.dashboard_outlined,
    selectedIcon: Icons.dashboard,
  ),
  AppShellDestination(
    label: '案件',
    icon: Icons.folder_open_outlined,
    selectedIcon: Icons.folder_open,
  ),
  AppShellDestination(
    label: '报告',
    icon: Icons.summarize_outlined,
    selectedIcon: Icons.summarize,
  ),
];

void onDashboardModuleTap(BuildContext context, int index) {
  final targetPath = switch (index) {
    0 => RouteNames.dashboardPath,
    1 => RouteNames.dashboardCasesPath,
    2 => RouteNames.dashboardReportsPath,
    _ => RouteNames.dashboardPath,
  };

  if (GoRouterState.of(context).uri.path == targetPath) {
    return;
  }

  context.go(targetPath);
}

class DashboardModuleTopBar extends StatelessWidget {
  const DashboardModuleTopBar({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return AppShellTopBar(
      title: title,
      sideWidth: 96,
      leading: Align(
        alignment: Alignment.centerLeft,
        child: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
          constraints: const BoxConstraints.tightFor(width: 40, height: 40),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      actions: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.search_rounded)),
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.16),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Icon(
            Icons.person,
            size: 18,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
