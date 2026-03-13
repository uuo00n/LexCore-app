import 'package:flutter/material.dart';

import 'package:lexcore/app/motion/app_motion.dart';

import 'app_shell_destinations.dart';

class AppSidebarNavigation extends StatelessWidget {
  const AppSidebarNavigation({
    super.key,
    required this.currentIndex,
    required this.onSelect,
    required this.items,
  });

  final int currentIndex;
  final ValueChanged<int> onSelect;
  final List<AppShellDestination> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: theme.colorScheme.primary.withValues(
                          alpha: 0.14,
                        ),
                      ),
                      child: Icon(
                        Icons.gavel_rounded,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('LexCore', style: theme.textTheme.titleSmall),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ...List.generate(items.length, (index) {
                final item = items[index];
                final selected = index == currentIndex;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => onSelect(index),
                    child: AnimatedContainer(
                      duration: AppMotion.navItem,
                      curve: AppMotion.easeInOut,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: selected
                            ? theme.colorScheme.primary.withValues(alpha: 0.14)
                            : theme.colorScheme.surface.withValues(alpha: 0),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            selected ? item.selectedIcon : item.icon,
                            color: selected
                                ? theme.colorScheme.primary
                                : theme.textTheme.bodyMedium?.color,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              item.label,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: selected
                                    ? theme.colorScheme.primary
                                    : theme.textTheme.bodyMedium?.color,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
