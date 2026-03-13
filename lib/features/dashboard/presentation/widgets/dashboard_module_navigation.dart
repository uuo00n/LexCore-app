import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:lexcore/app/router/route_names.dart';
import 'package:lexcore/shared/widgets/app_shell_top_bar.dart';

class DashboardSegmentedTabs extends StatelessWidget {
  const DashboardSegmentedTabs({
    super.key,
    required this.selectedIndex,
    required this.onSelectionChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SizedBox(
        width: double.infinity,
        child: SegmentedButton<int>(
          segments: const [
            ButtonSegment<int>(value: 0, label: Text('概览')),
            ButtonSegment<int>(value: 1, label: Text('案件')),
            ButtonSegment<int>(value: 2, label: Text('报告')),
          ],
          selected: {selectedIndex},
          onSelectionChanged: (selected) {
            onSelectionChanged(selected.first);
          },
          showSelectedIcon: false,
        ),
      ),
    );
  }
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
          onPressed: () {
            if (context.canPop()) {
              context.pop();
              return;
            }
            context.go(RouteNames.homePath);
          },
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
