import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:lexcore/shared/widgets/app_bottom_navigation.dart';
import 'package:lexcore/shared/widgets/app_mobile_canvas.dart';

class MainShellPage extends StatelessWidget {
  const MainShellPage({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppMobileCanvas(child: navigationShell),
      bottomNavigationBar: AppMobileCanvas(
        child: SafeArea(
          top: false,
          child: AppBottomNavigation(
            currentIndex: navigationShell.currentIndex,
            onTap: (index) {
              if (index == navigationShell.currentIndex) return;
              navigationShell.goBranch(index);
            },
          ),
        ),
      ),
    );
  }
}
