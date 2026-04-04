import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:lexcore/features/history/application/history_controller.dart';
import 'package:lexcore/shared/components/app_list_tile_item.dart';
import 'package:lexcore/shared/components/app_surface_card.dart';
import 'package:lexcore/shared/models/legal_models.dart';
import 'package:lexcore/shared/widgets/app_page_scaffold.dart';

class HistorySearchPage extends ConsumerStatefulWidget {
  const HistorySearchPage({super.key});

  @override
  ConsumerState<HistorySearchPage> createState() => _HistorySearchPageState();
}

class _HistorySearchPageState extends ConsumerState<HistorySearchPage> {
  final TextEditingController _keywordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _keywordController.text = ref.read(historySearchKeywordProvider);
    _keywordController.addListener(_onKeywordChanged);
  }

  @override
  void dispose() {
    _keywordController
      ..removeListener(_onKeywordChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedCategory = ref.watch(historyFilterProvider);
    final startTime = ref.watch(historySearchStartTimeProvider);
    final endTime = ref.watch(historySearchEndTimeProvider);
    final resultsAsync = ref.watch(historySearchItemsProvider);
    final hasActiveRange = startTime != null || endTime != null;
    final resultCount = resultsAsync.maybeWhen(
      data: (items) => items.length,
      orElse: () => 0,
    );

    return AppPageScaffold(
      title: '历史记录搜索',
      actions: [
        hasActiveRange
            ? IconButton.filledTonal(
                key: const ValueKey<String>(
                  'history_search_open_time_dialog_button',
                ),
                onPressed: _openTimeRangeDialog,
                icon: const Icon(Icons.calendar_month_outlined),
                tooltip: '时间范围',
              )
            : IconButton(
                key: const ValueKey<String>(
                  'history_search_open_time_dialog_button',
                ),
                onPressed: _openTimeRangeDialog,
                icon: const Icon(Icons.calendar_month_outlined),
                tooltip: '时间范围',
              ),
      ],
      body: ListView(
        children: [
          TextField(
            key: const ValueKey<String>('history_search_keyword_field'),
            controller: _keywordController,
            decoration: InputDecoration(
              hintText: '搜索历史记录标题...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _keywordController.text.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        _keywordController.clear();
                        ref.read(historySearchKeywordProvider.notifier).state =
                            '';
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          _HistoryCategoryFilters(
            selectedCategory: selectedCategory,
            onSelected: (category) =>
                ref.read(historyFilterProvider.notifier).state = category,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                '搜索结果（$resultCount）',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const Spacer(),
              TextButton(
                key: const ValueKey<String>('history_search_reset_button'),
                onPressed: _resetFilters,
                child: const Text('重置筛选'),
              ),
            ],
          ),
          const SizedBox(height: 2),
          ...resultsAsync.when(
            loading: () => const [Center(child: CircularProgressIndicator())],
            error: (error, stackTrace) => const [_HistorySearchErrorState()],
            data: (results) {
              if (results.isEmpty) {
                return const [_HistorySearchEmptyState()];
              }
              return results.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return AppListTileItem(
                  title: item.title,
                  subtitle:
                      '${_categoryLabel(item.category)} · ${DateFormat('yyyy-MM-dd HH:mm').format(item.time)}',
                  leadingIcon: _iconForCategory(item.category),
                  showBottomDivider: index != results.length - 1,
                  onTap: () {},
                );
              }).toList();
            },
          ),
        ],
      ),
    );
  }

  void _onKeywordChanged() {
    ref.read(historySearchKeywordProvider.notifier).state =
        _keywordController.text;
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

  void _resetFilters() {
    _keywordController.clear();
    ref.read(historySearchKeywordProvider.notifier).state = '';
    ref.read(historyFilterProvider.notifier).state = null;
    _clearTimeRange();
  }

  void _clearTimeRange() {
    ref.read(historySearchStartTimeProvider.notifier).state = null;
    ref.read(historySearchEndTimeProvider.notifier).state = null;
  }

  IconData _iconForCategory(HistoryCategory category) {
    return switch (category) {
      HistoryCategory.consultation => Icons.chat_bubble_outline,
      HistoryCategory.analysis => Icons.gavel_outlined,
      HistoryCategory.document => Icons.description_outlined,
    };
  }

  String _categoryLabel(HistoryCategory category) {
    return switch (category) {
      HistoryCategory.consultation => '咨询记录',
      HistoryCategory.analysis => '法条检索',
      HistoryCategory.document => '文档记录',
    };
  }
}

class _HistoryCategoryFilters extends StatelessWidget {
  const _HistoryCategoryFilters({
    required this.selectedCategory,
    required this.onSelected,
  });

  final HistoryCategory? selectedCategory;
  final ValueChanged<HistoryCategory?> onSelected;

  @override
  Widget build(BuildContext context) {
    final labels = <({String text, HistoryCategory? value})>[
      (text: '全部', value: null),
      (text: '咨询记录', value: HistoryCategory.consultation),
      (text: '法条检索', value: HistoryCategory.analysis),
    ];

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: labels.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final option = labels[index];
          final selected = selectedCategory == option.value;
          return ChoiceChip(
            key: ValueKey<String>(
              'history_search_filter_${option.value?.name ?? 'all'}',
            ),
            label: Text(option.text),
            selected: selected,
            onSelected: (_) => onSelected(option.value),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            selectedColor: Theme.of(context).colorScheme.primary,
            labelStyle: TextStyle(
              color: selected
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          );
        },
      ),
    );
  }
}

class _HistorySearchEmptyState extends StatelessWidget {
  const _HistorySearchEmptyState();

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
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
    );
  }
}

class _HistorySearchErrorState extends StatelessWidget {
  const _HistorySearchErrorState();

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '历史记录加载失败，请稍后重试',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
