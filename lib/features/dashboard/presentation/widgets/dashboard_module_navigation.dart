import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:lexcore/app/router/route_names.dart';
import 'package:lexcore/shared/widgets/app_sub_page_header.dart';

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
    return AppSubPageHeader(
      title: title,
      onBackPressed: () {
        if (context.canPop()) {
          context.pop();
          return;
        }
        context.go(RouteNames.homePath);
      },
    );
  }
}
