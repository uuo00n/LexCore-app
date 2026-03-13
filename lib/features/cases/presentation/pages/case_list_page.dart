import 'package:flutter/material.dart';

import 'package:lexcore/app/motion/app_motion_widgets.dart';
import 'package:lexcore/shared/widgets/app_mobile_canvas.dart';

class CaseListPage extends StatelessWidget {
  const CaseListPage({super.key});

  static const List<_CaseItem> _cases = [
    _CaseItem(
      caseNumber: '(2023) 沪01民初1024号',
      status: _CaseStatus.inProgress,
      title: '张三与李四房屋所有权纠纷案',
      dateLabel: '立案日期',
      dateValue: '2023-11-15',
      progressLabel: '证据交换',
      progress: 0.65,
    ),
    _CaseItem(
      caseNumber: '(2023) 浙02知民初256号',
      status: _CaseStatus.closed,
      title: '某科技公司专利侵权损害赔偿案',
      dateLabel: '结案日期',
      dateValue: '2023-12-01',
      progressLabel: '案件执行完毕',
      progress: 1.0,
    ),
    _CaseItem(
      caseNumber: '(2024) 京01刑初002号',
      status: _CaseStatus.waiting,
      title: '王五职务侵占刑事辩护案',
      dateLabel: '开庭日期',
      dateValue: '2024-02-10',
      progressLabel: '审判阶段',
      progress: 0.3,
    ),
    _CaseItem(
      caseNumber: '(2024) 粤03民特18号',
      status: _CaseStatus.inProgress,
      title: '跨境电商劳动合同仲裁案件',
      dateLabel: '立案日期',
      dateValue: '2024-01-05',
      progressLabel: '调解中',
      progress: 0.45,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      body: AppMobileCanvas(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const _CaseListHeader(),
              Expanded(
                child: ListView.builder(
                  key: const ValueKey<String>('cases_page_list'),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: _cases.length + 1,
                  itemBuilder: (context, index) {
                    if (index == _cases.length) {
                      return const SizedBox(height: 96);
                    }
                    final item = _cases[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AppFadeSlideIn(
                        delay: Duration(milliseconds: 30 + (index * 30)),
                        beginOffset: const Offset(0, 0.02),
                        child: _CaseCard(item: item, index: index),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class _CaseListHeader extends StatelessWidget {
  const _CaseListHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.menu,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '案件列表',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.notifications_outlined,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.12),
                  ),
                ),
                child: Icon(
                  Icons.account_circle,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            key: const ValueKey<String>('cases_page_search_field'),
            readOnly: true,
            decoration: InputDecoration(
              hintText: '搜索案件、当事人或案号...',
              hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.24),
                ),
                borderRadius: BorderRadius.circular(999),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.24),
                ),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: const [
                _CaseFilterChip(label: '全部', selected: true),
                SizedBox(width: 8),
                _CaseFilterChip(label: '进行中'),
                SizedBox(width: 8),
                _CaseFilterChip(label: '已结案'),
                SizedBox(width: 8),
                _CaseFilterChip(label: '草稿'),
                SizedBox(width: 8),
                _CaseFilterChip(label: '更多', icon: Icons.filter_list),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CaseFilterChip extends StatelessWidget {
  const _CaseFilterChip({
    required this.label,
    this.selected = false,
    this.icon,
  });

  final String label;
  final bool selected;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final foreground = selected
        ? Theme.of(context).colorScheme.onPrimary
        : Theme.of(context).colorScheme.onSurfaceVariant;

    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: selected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: selected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outline.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: foreground),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: foreground,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CaseCard extends StatelessWidget {
  const _CaseCard({required this.item, required this.index});

  final _CaseItem item;
  final int index;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusStyle = _CaseStatusStyle.resolve(context, item.status);

    return Container(
      key: ValueKey<String>('cases_page_card_$index'),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  '案号: ${item.caseNumber}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colorScheme.primary.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusStyle.background,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  statusStyle.label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: statusStyle.foreground,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                '${item.dateLabel}: ${item.dateValue}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  '诉讼进度: ${item.progressLabel}',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Text(
                '${(item.progress * 100).toStringAsFixed(0)}%',
                key: ValueKey<String>('cases_page_progress_text_$index'),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: statusStyle.foreground,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              key: ValueKey<String>('cases_page_progress_bar_$index'),
              minHeight: 6,
              value: item.progress,
              backgroundColor: colorScheme.surfaceContainerHighest,
              color: statusStyle.foreground,
            ),
          ),
        ],
      ),
    );
  }
}

class _CaseStatusStyle {
  const _CaseStatusStyle({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  factory _CaseStatusStyle.resolve(BuildContext context, _CaseStatus status) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status) {
      case _CaseStatus.inProgress:
        return _CaseStatusStyle(
          label: '进行中',
          background: colorScheme.primaryContainer.withValues(alpha: 0.55),
          foreground: colorScheme.primary,
        );
      case _CaseStatus.closed:
        return _CaseStatusStyle(
          label: '已结案',
          background: colorScheme.secondaryContainer.withValues(alpha: 0.55),
          foreground: colorScheme.secondary,
        );
      case _CaseStatus.waiting:
        return _CaseStatusStyle(
          label: '等待开庭',
          background: colorScheme.tertiaryContainer.withValues(alpha: 0.55),
          foreground: colorScheme.tertiary,
        );
    }
  }
}

enum _CaseStatus { inProgress, closed, waiting }

class _CaseItem {
  const _CaseItem({
    required this.caseNumber,
    required this.status,
    required this.title,
    required this.dateLabel,
    required this.dateValue,
    required this.progressLabel,
    required this.progress,
  });

  final String caseNumber;
  final _CaseStatus status;
  final String title;
  final String dateLabel;
  final String dateValue;
  final String progressLabel;
  final double progress;
}
