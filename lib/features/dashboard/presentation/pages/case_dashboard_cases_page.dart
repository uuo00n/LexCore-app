import 'package:flutter/material.dart';

import 'package:lexcore/app/motion/app_motion_widgets.dart';
import 'package:lexcore/features/dashboard/presentation/widgets/dashboard_module_navigation.dart';
import 'package:lexcore/shared/widgets/app_bottom_navigation.dart';
import 'package:lexcore/shared/widgets/app_mobile_canvas.dart';

class CaseDashboardCasesPage extends StatelessWidget {
  const CaseDashboardCasesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: AppMobileCanvas(
        maxContentWidth: 430,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const AppFadeSlideIn(
                delay: Duration(milliseconds: 20),
                beginOffset: Offset(0, -0.02),
                child: DashboardModuleTopBar(title: 'LexCore 案件分析'),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  child: AppFadeSlideIn(
                    delay: const Duration(milliseconds: 60),
                    beginOffset: const Offset(0, 0.02),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        '案件',
                        key: const ValueKey<String>(
                          'dashboard_cases_page_title',
                        ),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppMobileCanvas(
        maxContentWidth: 430,
        child: SafeArea(
          top: false,
          child: AppBottomNavigation(
            currentIndex: 1,
            items: dashboardModuleDestinations,
            onTap: (index) => onDashboardModuleTap(context, index),
          ),
        ),
      ),
    );
  }
}
