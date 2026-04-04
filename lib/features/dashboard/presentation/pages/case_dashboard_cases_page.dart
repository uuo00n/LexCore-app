import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:lexcore/app/motion/app_motion_widgets.dart';
import 'package:lexcore/app/router/route_names.dart';
import 'package:lexcore/features/cases/presentation/pages/case_detail_page.dart';

class CaseDashboardCasesContent extends StatefulWidget {
  const CaseDashboardCasesContent({super.key});

  @override
  State<CaseDashboardCasesContent> createState() =>
      _CaseDashboardCasesContentState();
}

class _CaseDashboardCasesContentState extends State<CaseDashboardCasesContent> {
  _DashboardCaseListFilter _selectedFilter = _DashboardCaseListFilter.all;

  static const List<_DashboardCaseItem> _cases = [
    _DashboardCaseItem(
      caseNumber: '(2023) 沪01民初1024号',
      status: _DashboardCaseStatus.inProgress,
      title: '张三与李四房屋所有权纠纷案',
      dateLabel: '立案日期',
      dateValue: '2023-11-15',
      progressLabel: '证据交换',
      progress: 0.65,
    ),
    _DashboardCaseItem(
      caseNumber: '(2023) 浙02知民初256号',
      status: _DashboardCaseStatus.closed,
      title: '某科技公司专利侵权损害赔偿案',
      dateLabel: '结案日期',
      dateValue: '2023-12-01',
      progressLabel: '案件执行完毕',
      progress: 1.0,
    ),
    _DashboardCaseItem(
      caseNumber: '(2024) 京01刑初002号',
      status: _DashboardCaseStatus.waiting,
      title: '王五职务侵占刑事辩护案',
      dateLabel: '开庭日期',
      dateValue: '2024-02-10',
      progressLabel: '审判阶段',
      progress: 0.3,
    ),
    _DashboardCaseItem(
      caseNumber: '(2024) 粤03民特18号',
      status: _DashboardCaseStatus.inProgress,
      title: '跨境电商劳动合同仲裁案件',
      dateLabel: '立案日期',
      dateValue: '2024-01-05',
      progressLabel: '调解中',
      progress: 0.45,
    ),
  ];

  List<_DashboardCaseItem> get _filteredCases {
    switch (_selectedFilter) {
      case _DashboardCaseListFilter.all:
        return _cases;
      case _DashboardCaseListFilter.inProgress:
        return _cases
            .where((item) => item.status == _DashboardCaseStatus.inProgress)
            .toList(growable: false);
      case _DashboardCaseListFilter.closed:
        return _cases
            .where((item) => item.status == _DashboardCaseStatus.closed)
            .toList(growable: false);
      case _DashboardCaseListFilter.waiting:
        return _cases
            .where((item) => item.status == _DashboardCaseStatus.waiting)
            .toList(growable: false);
      case _DashboardCaseListFilter.draft:
        return const [];
    }
  }

  void _selectFilter(_DashboardCaseListFilter filter) {
    if (_selectedFilter == filter) return;
    setState(() {
      _selectedFilter = filter;
    });
  }

  Future<void> _showMoreFiltersSheet() async {
    final selectedFilter = await showModalBottomSheet<_DashboardCaseListFilter>(
      context: context,
      useSafeArea: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DashboardCaseSheetOption(
                key: const ValueKey<String>(
                  'dashboard_cases_more_waiting_option',
                ),
                icon: Icons.hourglass_top_rounded,
                title: '等待开庭',
                selected: _selectedFilter == _DashboardCaseListFilter.waiting,
                onTap: () => Navigator.of(
                  sheetContext,
                ).pop(_DashboardCaseListFilter.waiting),
              ),
              _DashboardCaseSheetOption(
                key: const ValueKey<String>(
                  'dashboard_cases_more_draft_option',
                ),
                icon: Icons.edit_note_rounded,
                title: '草稿',
                selected: _selectedFilter == _DashboardCaseListFilter.draft,
                onTap: () => Navigator.of(
                  sheetContext,
                ).pop(_DashboardCaseListFilter.draft),
              ),
              const SizedBox(height: 6),
            ],
          ),
        );
      },
    );
    if (!mounted || selectedFilter == null) return;
    _selectFilter(selectedFilter);
  }

  @override
  Widget build(BuildContext context) {
    final filteredCases = _filteredCases;

    return Column(
      key: const ValueKey<String>('dashboard_cases_page_title'),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: TextField(
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
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _DashboardCaseFilterChip(
                  key: const ValueKey<String>('dashboard_cases_filter_all'),
                  label: '全部',
                  selected: _selectedFilter == _DashboardCaseListFilter.all,
                  onTap: () => _selectFilter(_DashboardCaseListFilter.all),
                ),
                const SizedBox(width: 8),
                _DashboardCaseFilterChip(
                  key: const ValueKey<String>(
                    'dashboard_cases_filter_in_progress',
                  ),
                  label: '进行中',
                  selected:
                      _selectedFilter == _DashboardCaseListFilter.inProgress,
                  onTap: () =>
                      _selectFilter(_DashboardCaseListFilter.inProgress),
                ),
                const SizedBox(width: 8),
                _DashboardCaseFilterChip(
                  key: const ValueKey<String>('dashboard_cases_filter_closed'),
                  label: '已结案',
                  selected: _selectedFilter == _DashboardCaseListFilter.closed,
                  onTap: () => _selectFilter(_DashboardCaseListFilter.closed),
                ),
                const SizedBox(width: 8),
                _DashboardCaseFilterChip(
                  key: const ValueKey<String>('dashboard_cases_filter_more'),
                  label: '更多',
                  icon: Icons.filter_list,
                  selected:
                      _selectedFilter == _DashboardCaseListFilter.waiting ||
                      _selectedFilter == _DashboardCaseListFilter.draft,
                  onTap: _showMoreFiltersSheet,
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: filteredCases.isEmpty
              ? _DashboardCaseEmptyState(filter: _selectedFilter)
              : ListView.builder(
                  key: const ValueKey<String>('dashboard_cases_page_list'),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: filteredCases.length + 1,
                  itemBuilder: (context, index) {
                    if (index == filteredCases.length) {
                      return const SizedBox(height: 80);
                    }
                    final item = filteredCases[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AppFadeSlideIn(
                        delay: Duration(milliseconds: 30 + (index * 30)),
                        beginOffset: const Offset(0, 0.02),
                        child: _DashboardCaseCard(
                          item: item,
                          index: index,
                          onOpenDetail: () => context.push(
                            RouteNames.caseDetailPath,
                            extra: _detailDataFor(item),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  CaseDetailData _detailDataFor(_DashboardCaseItem item) {
    switch (item.caseNumber) {
      case '(2023) 沪01民初1024号':
        return CaseDetailData(
          status: _toDetailStatus(item.status),
          statusLabel: _DashboardCaseStatusStyle.resolve(
            context,
            item.status,
          ).label,
          lastUpdatedLabel: '更新于 2小时前',
          title: item.title,
          caseNumber: '(2023) 沪0115民初12345号',
          dateLabel: item.dateLabel,
          dateValue: '2023-10-15',
          progress: item.progress,
          progressLabel: '开庭中',
          activeStepIndex: 2,
          progressSteps: const ['证据交换', '庭审准备', '开庭中', '判决'],
          summary:
              '原告张三与被告李四于 2022 年签订房屋买卖协议，原告已支付全部房款，但被告迟迟未办理房产过户手续。原告遂起诉要求被告履行合同义务并赔偿违约金。',
          plaintiffName: '张三',
          plaintiffCounsel: '代理律师：王律师',
          defendantName: '李四',
          defendantCounsel: '未指定代理',
          documents: const [
            CaseDocumentData(
              type: CaseDocumentType.pdf,
              title: '起诉状_张三.pdf',
              meta: '1.2 MB · 2023-10-16',
            ),
            CaseDocumentData(
              type: CaseDocumentType.image,
              title: '房产证复印件.jpg',
              meta: '2.5 MB · 2023-10-18',
            ),
          ],
        );
      case '(2023) 浙02知民初256号':
        return CaseDetailData(
          status: _toDetailStatus(item.status),
          statusLabel: _DashboardCaseStatusStyle.resolve(
            context,
            item.status,
          ).label,
          lastUpdatedLabel: '更新于 昨日 18:20',
          title: item.title,
          caseNumber: item.caseNumber,
          dateLabel: item.dateLabel,
          dateValue: item.dateValue,
          progress: item.progress,
          progressLabel: '案件执行完毕',
          activeStepIndex: 3,
          progressSteps: const ['立案', '技术比对', '一审判决', '执行完毕'],
          summary:
              '原告主张被告未经授权使用其专利方案开展量产经营，要求停止侵权并赔偿经济损失。经技术特征比对及销售数据核验后，法院已支持主要诉请。',
          plaintiffName: '某科技公司',
          plaintiffCounsel: '代理律师：周律师',
          defendantName: '某制造企业',
          defendantCounsel: '代理律师：徐律师',
          documents: const [
            CaseDocumentData(
              type: CaseDocumentType.pdf,
              title: '专利比对意见.pdf',
              meta: '3.1 MB · 2023-11-28',
            ),
            CaseDocumentData(
              type: CaseDocumentType.note,
              title: '执行回款记录.docx',
              meta: '540 KB · 2023-12-01',
            ),
          ],
        );
      case '(2024) 京01刑初002号':
        return CaseDetailData(
          status: _toDetailStatus(item.status),
          statusLabel: _DashboardCaseStatusStyle.resolve(
            context,
            item.status,
          ).label,
          lastUpdatedLabel: '更新于 30分钟前',
          title: item.title,
          caseNumber: item.caseNumber,
          dateLabel: item.dateLabel,
          dateValue: item.dateValue,
          progress: item.progress,
          progressLabel: item.progressLabel,
          activeStepIndex: 1,
          progressSteps: const ['侦查阶段', '审查起诉', '开庭准备', '正式开庭'],
          summary: '案件目前已完成阅卷与会见，重点争议集中在资金流向是否构成非法占有目的。辩护策略将围绕主观故意不足及证据链断点展开。',
          plaintiffName: '北京市人民检察院',
          plaintiffCounsel: '公诉机关',
          defendantName: '王五',
          defendantCounsel: '代理律师：刘律师',
          documents: const [
            CaseDocumentData(
              type: CaseDocumentType.pdf,
              title: '阅卷摘要.pdf',
              meta: '860 KB · 2024-02-04',
            ),
            CaseDocumentData(
              type: CaseDocumentType.note,
              title: '会见笔录.docx',
              meta: '220 KB · 2024-02-08',
            ),
          ],
        );
      case '(2024) 粤03民特18号':
        return CaseDetailData(
          status: _toDetailStatus(item.status),
          statusLabel: _DashboardCaseStatusStyle.resolve(
            context,
            item.status,
          ).label,
          lastUpdatedLabel: '更新于 今日 09:40',
          title: item.title,
          caseNumber: item.caseNumber,
          dateLabel: item.dateLabel,
          dateValue: item.dateValue,
          progress: item.progress,
          progressLabel: item.progressLabel,
          activeStepIndex: 2,
          progressSteps: const ['立案受理', '证据整理', '调解中', '仲裁庭审'],
          summary: '申请人主张公司违法解除劳动合同并拖欠加班工资，现双方已进入调解阶段。关键证据包括工资流水、考勤导出及录用通知邮件。',
          plaintiffName: '跨境电商运营团队',
          plaintiffCounsel: '代理律师：陈律师',
          defendantName: '某跨境平台公司',
          defendantCounsel: '法务代表：何女士',
          documents: const [
            CaseDocumentData(
              type: CaseDocumentType.pdf,
              title: '仲裁申请书.pdf',
              meta: '1.4 MB · 2024-01-06',
            ),
            CaseDocumentData(
              type: CaseDocumentType.image,
              title: '考勤截图汇总.png',
              meta: '4.8 MB · 2024-01-11',
            ),
          ],
        );
      default:
        return CaseDetailData(
          status: _toDetailStatus(item.status),
          statusLabel: _DashboardCaseStatusStyle.resolve(
            context,
            item.status,
          ).label,
          lastUpdatedLabel: '更新于 刚刚',
          title: item.title,
          caseNumber: item.caseNumber,
          dateLabel: item.dateLabel,
          dateValue: item.dateValue,
          progress: item.progress,
          progressLabel: item.progressLabel,
          activeStepIndex: 1,
          progressSteps: const ['立案', '证据整理', '审理中', '结案'],
          summary: '该案件处于演示数据模式，后续将由真实后端数据替换。',
          plaintiffName: '原告（演示）',
          plaintiffCounsel: '代理律师：演示',
          defendantName: '被告（演示）',
          defendantCounsel: '代理律师：演示',
          documents: const [
            CaseDocumentData(
              type: CaseDocumentType.note,
              title: '演示材料说明.txt',
              meta: '12 KB · 今天',
            ),
          ],
        );
    }
  }

  CaseDetailStatus _toDetailStatus(_DashboardCaseStatus status) {
    return switch (status) {
      _DashboardCaseStatus.inProgress => CaseDetailStatus.inProgress,
      _DashboardCaseStatus.closed => CaseDetailStatus.closed,
      _DashboardCaseStatus.waiting => CaseDetailStatus.waiting,
    };
  }
}

class _DashboardCaseFilterChip extends StatelessWidget {
  const _DashboardCaseFilterChip({
    super.key,
    required this.label,
    this.selected = false,
    this.icon,
    this.onTap,
  });

  final String label;
  final bool selected;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = selected
        ? Theme.of(context).colorScheme.onPrimary
        : Theme.of(context).colorScheme.onSurfaceVariant;

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
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
                  : Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.18),
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
        ),
      ),
    );
  }
}

class _DashboardCaseCard extends StatelessWidget {
  const _DashboardCaseCard({
    required this.item,
    required this.index,
    required this.onOpenDetail,
  });

  final _DashboardCaseItem item;
  final int index;
  final VoidCallback onOpenDetail;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusStyle = _DashboardCaseStatusStyle.resolve(context, item.status);

    return Container(
      key: ValueKey<String>('dashboard_cases_case_card_$index'),
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
              minHeight: 6,
              value: item.progress,
              backgroundColor: colorScheme.surfaceContainerHighest,
              color: statusStyle.foreground,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  '已同步案件进度与核心材料',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              TextButton.icon(
                key: ValueKey<String>('dashboard_cases_detail_button_$index'),
                onPressed: onOpenDetail,
                icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                label: const Text('详细'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DashboardCaseEmptyState extends StatelessWidget {
  const _DashboardCaseEmptyState({required this.filter});

  final _DashboardCaseListFilter filter;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final title = switch (filter) {
      _DashboardCaseListFilter.draft => '暂无草稿案件',
      _DashboardCaseListFilter.all => '暂无案件数据',
      _ => '暂无匹配案件',
    };
    final message = switch (filter) {
      _DashboardCaseListFilter.draft => '当前还没有保存到草稿的案件分析。',
      _DashboardCaseListFilter.all => '完成后端接口接入后，案件列表将自动显示。',
      _ => '可尝试切换筛选条件查看其他案件。',
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_rounded,
              size: 32,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 10),
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardCaseSheetOption extends StatelessWidget {
  const _DashboardCaseSheetOption({
    super.key,
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(
        icon,
        color: selected ? colorScheme.primary : colorScheme.onSurfaceVariant,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
        ),
      ),
      trailing: selected
          ? Icon(Icons.check_rounded, color: colorScheme.primary)
          : null,
      onTap: onTap,
    );
  }
}

class _DashboardCaseStatusStyle {
  const _DashboardCaseStatusStyle({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  factory _DashboardCaseStatusStyle.resolve(
    BuildContext context,
    _DashboardCaseStatus status,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status) {
      case _DashboardCaseStatus.inProgress:
        return _DashboardCaseStatusStyle(
          label: '进行中',
          background: colorScheme.primaryContainer.withValues(alpha: 0.55),
          foreground: colorScheme.primary,
        );
      case _DashboardCaseStatus.closed:
        return _DashboardCaseStatusStyle(
          label: '已结案',
          background: colorScheme.secondaryContainer.withValues(alpha: 0.55),
          foreground: colorScheme.secondary,
        );
      case _DashboardCaseStatus.waiting:
        return _DashboardCaseStatusStyle(
          label: '等待开庭',
          background: colorScheme.tertiaryContainer.withValues(alpha: 0.55),
          foreground: colorScheme.tertiary,
        );
    }
  }
}

enum _DashboardCaseListFilter { all, inProgress, closed, waiting, draft }

enum _DashboardCaseStatus { inProgress, closed, waiting }

class _DashboardCaseItem {
  const _DashboardCaseItem({
    required this.caseNumber,
    required this.status,
    required this.title,
    required this.dateLabel,
    required this.dateValue,
    required this.progressLabel,
    required this.progress,
  });

  final String caseNumber;
  final _DashboardCaseStatus status;
  final String title;
  final String dateLabel;
  final String dateValue;
  final String progressLabel;
  final double progress;
}
