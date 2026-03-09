import 'package:flutter/material.dart';

class AppShellDestination {
  const AppShellDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

const appShellDestinations = [
  AppShellDestination(
    label: '首页',
    icon: Icons.home_outlined,
    selectedIcon: Icons.home,
  ),
  AppShellDestination(
    label: '搜索',
    icon: Icons.search_outlined,
    selectedIcon: Icons.search,
  ),
  AppShellDestination(
    label: '历史',
    icon: Icons.history_outlined,
    selectedIcon: Icons.history,
  ),
  AppShellDestination(
    label: '我的',
    icon: Icons.person_outline,
    selectedIcon: Icons.person,
  ),
];
