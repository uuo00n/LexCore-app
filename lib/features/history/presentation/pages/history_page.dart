import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lexcore/app/motion/app_motion.dart';
import 'package:lexcore/app/motion/app_motion_widgets.dart';
import 'package:lexcore/app/theme/app_colors.dart';
import 'package:lexcore/core/utils/date_time_utils.dart';
import 'package:lexcore/features/history/application/history_controller.dart';
import 'package:lexcore/shared/models/legal_models.dart';
import 'package:lexcore/shared/widgets/app_mobile_canvas.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(historyFilterProvider);
    final items = ref.watch(historyItemsProvider);

    final today = <HistoryItem>[];
    final yesterday = <HistoryItem>[];
    final older = <HistoryItem>[];

    for (final item in items) {
      final days = DateTime.now().difference(item.time).inDays;
      if (days == 0) {
        today.add(item);
      } else if (days == 1) {
        yesterday.add(item);
      } else {
        older.add(item);
      }
    }

    return Scaffold(
      body: AppMobileCanvas(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
                child: AppFadeSlideIn(
                  delay: Duration(milliseconds: 20),
                  beginOffset: Offset(0, -0.02),
                  child: _HistoryTopBar(),
                ),
              ),
              AppFadeSlideIn(
                delay: const Duration(milliseconds: 60),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Theme.of(context).dividerColor),
                    ),
                  ),
                  child: Row(
                    children: [
                      _TopTab(
                        title: '咨询记录',
                        active: _tabIndex == 0,
                        onTap: () => setState(() {
                          _tabIndex = 0;
                          ref.read(historyFilterProvider.notifier).state =
                              HistoryCategory.consultation;
                        }),
                      ),
                      _TopTab(
                        title: '法律搜索',
                        active: _tabIndex == 1,
                        onTap: () => setState(() {
                          _tabIndex = 1;
                          ref.read(historyFilterProvider.notifier).state =
                              HistoryCategory.analysis;
                        }),
                      ),
                      _TopTab(
                        title: '全部',
                        active: _tabIndex == 2,
                        onTap: () => setState(() {
                          _tabIndex = 2;
                          ref.read(historyFilterProvider.notifier).state = null;
                        }),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  children: [
                    AppFadeSlideIn(
                      delay: const Duration(milliseconds: 100),
                      child: Column(
                        children: [
                          if (filter != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                '当前筛选：${filter.name}',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                    ),
                              ),
                            ),
                          _HistorySection(title: '今天', items: today),
                          _HistorySection(title: '昨天', items: yesterday),
                          _HistorySection(title: '更早以前', items: older),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryTopBar extends StatelessWidget {
  const _HistoryTopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.menu_rounded)),
        Expanded(
          child: Text(
            '历史记录',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
      ],
    );
  }
}

class _TopTab extends StatelessWidget {
  const _TopTab({
    required this.title,
    required this.active,
    required this.onTap,
  });

  final String title;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppMotion.component,
          curve: AppMotion.easeInOut,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: active ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: AnimatedDefaultTextStyle(
            duration: AppMotion.component,
            curve: AppMotion.easeOut,
            style: (Theme.of(context).textTheme.bodyMedium ?? const TextStyle())
                .copyWith(
                  color: active
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                ),
            child: Text(title),
          ),
        ),
      ),
    );
  }
}

class _HistorySection extends StatelessWidget {
  const _HistorySection({required this.title, required this.items});

  final String title;
  final List<HistoryItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(2, 12, 2, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ),
        ...items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final icon = switch (item.category) {
            HistoryCategory.consultation => Icons.chat_bubble_outline,
            HistoryCategory.analysis => Icons.gavel_outlined,
            HistoryCategory.document => Icons.description_outlined,
          };
          return AppFadeSlideIn(
            delay: Duration(milliseconds: 20 + (index * 35)),
            beginOffset: const Offset(0, 0.02),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.7),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppColors.primary.withValues(alpha: 0.1),
                    ),
                    child: Icon(icon, color: AppColors.primary),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateTimeUtils.relativeFromNow(item.time),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
