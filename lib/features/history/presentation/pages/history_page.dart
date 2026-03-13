import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lexcore/app/adaptive/app_adaptive_split_view.dart';
import 'package:lexcore/app/adaptive/app_breakpoints.dart';
import 'package:lexcore/app/motion/app_motion.dart';
import 'package:lexcore/app/motion/app_motion_widgets.dart';
import 'package:lexcore/core/utils/date_time_utils.dart';
import 'package:lexcore/features/history/application/history_controller.dart';
import 'package:lexcore/shared/components/app_list_tile_item.dart';
import 'package:lexcore/shared/components/app_surface_card.dart';
import 'package:lexcore/shared/models/legal_models.dart';
import 'package:lexcore/shared/widgets/app_mobile_canvas.dart';
import 'package:lexcore/shared/widgets/app_shell_top_bar.dart';

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

    final consultationCount = items
        .where((item) => item.category == HistoryCategory.consultation)
        .length;
    final analysisCount = items
        .where((item) => item.category == HistoryCategory.analysis)
        .length;
    final documentCount = items
        .where((item) => item.category == HistoryCategory.document)
        .length;

    return Scaffold(
      body: AppMobileCanvas(
        child: SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final viewport = AppBreakpoints.fromWidth(constraints.maxWidth);
              final splitLayout =
                  viewport == AppViewportSize.expanded ||
                  viewport == AppViewportSize.ultra;

              return Column(
                children: [
                  const AppFadeSlideIn(
                    delay: Duration(milliseconds: 20),
                    beginOffset: Offset(0, -0.02),
                    child: _HistoryTopBar(),
                  ),
                  AppFadeSlideIn(
                    delay: const Duration(milliseconds: 60),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Theme.of(context).dividerColor,
                          ),
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
                            title: '法条检索',
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
                              ref.read(historyFilterProvider.notifier).state =
                                  null;
                            }),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                      child: splitLayout
                          ? AppAdaptiveSplitView(
                              splitMinWidth: 980,
                              secondaryMaxWidth: 340,
                              primary: _HistoryTimeline(
                                today: today,
                                yesterday: yesterday,
                                older: older,
                                filter: filter,
                              ),
                              secondary: _HistoryInsights(
                                total: items.length,
                                todayCount: today.length,
                                consultationCount: consultationCount,
                                analysisCount: analysisCount,
                                documentCount: documentCount,
                              ),
                            )
                          : _HistoryTimeline(
                              today: today,
                              yesterday: yesterday,
                              older: older,
                              filter: filter,
                            ),
                    ),
                  ),
                ],
              );
            },
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
    return AppShellTopBar(
      title: '历史记录',
      actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.search))],
    );
  }
}

class _HistoryTimeline extends StatelessWidget {
  const _HistoryTimeline({
    required this.today,
    required this.yesterday,
    required this.older,
    required this.filter,
  });

  final List<HistoryItem> today;
  final List<HistoryItem> yesterday;
  final List<HistoryItem> older;
  final HistoryCategory? filter;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        AppFadeSlideIn(
          delay: const Duration(milliseconds: 100),
          child: Column(
            children: [
              if (filter != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    '当前筛选：${filter!.name}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
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
    );
  }
}

class _HistoryInsights extends StatelessWidget {
  const _HistoryInsights({
    required this.total,
    required this.todayCount,
    required this.consultationCount,
    required this.analysisCount,
    required this.documentCount,
  });

  final int total;
  final int todayCount;
  final int consultationCount;
  final int analysisCount;
  final int documentCount;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        AppFadeSlideIn(
          delay: const Duration(milliseconds: 90),
          child: AppSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('记录概览', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 12),
                _MetricLine(label: '总记录数', value: '$total'),
                _MetricLine(label: '今日新增', value: '$todayCount'),
                _MetricLine(label: '咨询类', value: '$consultationCount'),
                _MetricLine(label: '检索类', value: '$analysisCount'),
                _MetricLine(label: '文档类', value: '$documentCount'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        AppFadeSlideIn(
          delay: const Duration(milliseconds: 130),
          child: AppSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('建议操作', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 10),
                FilledButton.tonalIcon(
                  onPressed: () {},
                  icon: const Icon(Icons.file_download_outlined),
                  label: const Text('导出历史摘要'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.cleaning_services_outlined),
                  label: const Text('清理旧记录'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MetricLine extends StatelessWidget {
  const _MetricLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
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
                color: active
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(
                        context,
                      ).colorScheme.surface.withValues(alpha: 0),
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
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
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
              color: Theme.of(context).colorScheme.onSurfaceVariant,
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
            child: AppListTileItem(
              title: item.title,
              subtitle: DateTimeUtils.relativeFromNow(item.time),
              leadingIcon: icon,
              showBottomDivider: index != items.length - 1,
              onTap: () {},
            ),
          );
        }),
      ],
    );
  }
}
