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
      sideWidth: 56,
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
    );
  }
}
