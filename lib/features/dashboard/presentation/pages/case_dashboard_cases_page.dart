import 'package:flutter/material.dart';

class CaseDashboardCasesContent extends StatelessWidget {
  const CaseDashboardCasesContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(
          '案件',
          key: const ValueKey<String>('dashboard_cases_page_title'),
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}
