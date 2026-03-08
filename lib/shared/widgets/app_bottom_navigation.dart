import 'package:flutter/material.dart';

import 'package:lexcore/app/motion/app_motion.dart';

class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    const items = [
      _NavItem('首页', Icons.home_outlined, Icons.home),
      _NavItem('搜索', Icons.search_outlined, Icons.search),
      _NavItem('历史', Icons.history_outlined, Icons.history),
      _NavItem('我的', Icons.person_outline, Icons.person),
    ];

    return Container(
      height: 82,
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final selected = currentIndex == index;
          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                if (selected) return;
                onTap(index);
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: AppMotion.navItem,
                    curve: AppMotion.easeInOut,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.14)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Icon(
                      selected ? item.selectedIcon : item.icon,
                      size: 22,
                      color: selected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  AnimatedDefaultTextStyle(
                    duration: AppMotion.navItem,
                    curve: AppMotion.easeInOut,
                    style:
                        (Theme.of(context).textTheme.labelMedium ??
                                const TextStyle())
                            .copyWith(
                              color: selected
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(
                                      context,
                                    ).textTheme.bodySmall?.color,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                    child: Text(item.label),
                  ),
                  AnimatedContainer(
                    duration: AppMotion.navItem,
                    curve: AppMotion.easeOut,
                    margin: const EdgeInsets.only(top: 2),
                    width: selected ? 10 : 0,
                    height: 2,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.label, this.icon, this.selectedIcon);

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
