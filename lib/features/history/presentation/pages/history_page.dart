import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:lexcore/app/adaptive/app_adaptive_split_view.dart';
import 'package:lexcore/app/adaptive/app_breakpoints.dart';
import 'package:lexcore/app/motion/app_motion.dart';
import 'package:lexcore/app/motion/app_motion_widgets.dart';
import 'package:lexcore/core/utils/date_time_utils.dart';
import 'package:lexcore/core/utils/feature_notice.dart';
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
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.text = ref.read(historySearchKeywordProvider);
    _searchController.addListener(_onKeywordChanged);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onKeywordChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(historyFilterProvider);
    final itemsAsync = ref.watch(historySearchItemsProvider);
    final allItemsAsync = ref.watch(historyAllItemsProvider);
    final startTime = ref.watch(historySearchStartTimeProvider);
    final endTime = ref.watch(historySearchEndTimeProvider);
    final hasActiveRange = startTime != null || endTime != null;

    if (itemsAsync.isLoading || allItemsAsync.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (itemsAsync.hasError || allItemsAsync.hasError) {
      return const Scaffold(body: Center(child: Text('历史记录加载失败')));
    }

    final items = itemsAsync.valueOrNull ?? const <HistoryItem>[];
    final allItems = allItemsAsync.valueOrNull ?? const <HistoryItem>[];

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

    final consultationCount = allItems
        .where((item) => item.category == HistoryCategory.consultation)
        .length;
    final analysisCount = allItems
        .where((item) => item.category == HistoryCategory.analysis)
        .length;
    final documentCount = allItems
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
                            title: '全部',
                            active: filter == null,
                            onTap: () =>
                                ref.read(historyFilterProvider.notifier).state =
                                    null,
                          ),
                          _TopTab(
                            title: '咨询记录',
                            active: filter == HistoryCategory.consultation,
                            onTap: () =>
                                ref.read(historyFilterProvider.notifier).state =
                                    HistoryCategory.consultation,
                          ),
                          _TopTab(
                            title: '法条检索',
                            active: filter == HistoryCategory.analysis,
                            onTap: () =>
                                ref.read(historyFilterProvider.notifier).state =
                                    HistoryCategory.analysis,
                          ),
                        ],
                      ),
                    ),
                  ),
                  AppFadeSlideIn(
                    delay: const Duration(milliseconds: 90),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                      child: Column(
                        children: [
                          TextField(
                            key: const ValueKey<String>(
                              'history_page_keyword_field',
                            ),
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: '搜索历史记录标题...',
                              prefixIcon: const Icon(Icons.search_rounded),
                              suffixIcon: _searchController.text.trim().isEmpty
                                  ? null
                                  : IconButton(
                                      onPressed: () {
                                        _searchController.clear();
                                        ref
                                                .read(
                                                  historySearchKeywordProvider
                                                      .notifier,
                                                )
                                                .state =
                                            '';
                                      },
                                      icon: const Icon(Icons.close_rounded),
                                      tooltip: '清除关键词',
                                    ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  key: const ValueKey<String>(
                                    'history_page_open_time_dialog_button',
                                  ),
                                  onPressed: _openTimeRangeDialog,
                                  icon: Icon(
                                    hasActiveRange
                                        ? Icons.event_available_outlined
                                        : Icons.calendar_month_outlined,
                                  ),
                                  label: Text(
                                    _rangeLabel(startTime, endTime),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              if (hasActiveRange) ...[
                                const SizedBox(width: 8),
                                TextButton(
                                  key: const ValueKey<String>(
                                    'history_page_clear_time_range_button',
                                  ),
                                  onPressed: _clearTimeRange,
                                  child: const Text('清空时间'),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
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
                              ),
                              secondary: _HistoryInsights(
                                total: allItems.length,
                                filteredTotal: items.length,
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

  void _onKeywordChanged() {
    ref.read(historySearchKeywordProvider.notifier).state =
        _searchController.text;
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _openTimeRangeDialog() async {
    if (!mounted) {
      return;
    }

    final now = DateTime.now();
    final startTime = ref.read(historySearchStartTimeProvider);
    final endTime = ref.read(historySearchEndTimeProvider);

    DateTimeRange? initialDateRange;
    if (startTime != null && endTime != null) {
      final startDate = DateTime(
        startTime.year,
        startTime.month,
        startTime.day,
      );
      final endDate = DateTime(endTime.year, endTime.month, endTime.day);
      if (!startDate.isAfter(endDate)) {
        initialDateRange = DateTimeRange(start: startDate, end: endDate);
      }
    }

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 10),
      initialDateRange: initialDateRange,
      helpText: '时间范围',
      cancelText: '取消',
      saveText: '确定',
    );
    if (picked == null) {
      return;
    }

    ref.read(historySearchStartTimeProvider.notifier).state = DateTime(
      picked.start.year,
      picked.start.month,
      picked.start.day,
    );
    ref.read(historySearchEndTimeProvider.notifier).state = DateTime(
      picked.end.year,
      picked.end.month,
      picked.end.day,
      23,
      59,
      59,
      999,
    );
  }

  void _clearTimeRange() {
    ref.read(historySearchStartTimeProvider.notifier).state = null;
    ref.read(historySearchEndTimeProvider.notifier).state = null;
  }

  String _rangeLabel(DateTime? startTime, DateTime? endTime) {
    if (startTime == null && endTime == null) {
      return '全部时间';
    }
    if (startTime != null && endTime != null) {
      return '${DateFormat('MM-dd').format(startTime)} 至 ${DateFormat('MM-dd').format(endTime)}';
    }
    if (startTime != null) {
      return '${DateFormat('MM-dd').format(startTime)} 之后';
    }
    return '${DateFormat('MM-dd').format(endTime!)} 之前';
  }
}

class _HistoryTopBar extends StatelessWidget {
  const _HistoryTopBar();

  @override
  Widget build(BuildContext context) {
    return const AppShellTopBar(title: '历史记录');
  }
}

class _HistoryTimeline extends StatelessWidget {
  const _HistoryTimeline({
    required this.today,
    required this.yesterday,
    required this.older,
  });

  final List<HistoryItem> today;
  final List<HistoryItem> yesterday;
  final List<HistoryItem> older;

  @override
  Widget build(BuildContext context) {
    if (today.isEmpty && yesterday.isEmpty && older.isEmpty) {
      return Center(
        child: AppSurfaceCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.history_toggle_off,
                size: 30,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 8),
              Text('暂无匹配记录', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 4),
              Text(
                '可尝试调整关键词、分类或时间范围。',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      children: [
        AppFadeSlideIn(
          delay: const Duration(milliseconds: 100),
          child: Column(
            children: [
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
    required this.filteredTotal,
    required this.todayCount,
    required this.consultationCount,
    required this.analysisCount,
    required this.documentCount,
  });

  final int total;
  final int filteredTotal;
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
                _MetricLine(label: '当前筛选', value: '$filteredTotal'),
                _MetricLine(label: '今日匹配', value: '$todayCount'),
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
                  onPressed: () => showFeatureInProgressSnackBar(
                    context,
                    featureLabel: '历史摘要导出',
                  ),
                  icon: const Icon(Icons.file_download_outlined),
                  label: const Text('导出历史摘要'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => showFeatureInProgressSnackBar(
                    context,
                    featureLabel: '旧记录清理',
                  ),
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
              trailing: const SizedBox.shrink(),
              showBottomDivider: index != items.length - 1,
              onTap: null,
            ),
          );
        }),
      ],
    );
  }
}
