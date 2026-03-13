import 'package:flutter/material.dart';

class CaseDashboardReportsContent extends StatelessWidget {
  const CaseDashboardReportsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(
          '报告',
          key: const ValueKey<String>('dashboard_reports_page_title'),
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}
