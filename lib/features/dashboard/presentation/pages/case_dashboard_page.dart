import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lexcore/app/motion/app_motion_widgets.dart';
import 'package:lexcore/app/router/route_names.dart';
import 'package:lexcore/features/dashboard/application/dashboard_provider.dart';
import 'package:lexcore/features/dashboard/domain/entities/dashboard_entity.dart';
import 'package:lexcore/features/dashboard/presentation/pages/case_dashboard_cases_page.dart';
import 'package:lexcore/features/dashboard/presentation/widgets/dashboard_module_navigation.dart';
import 'package:lexcore/shared/components/app_list_tile_item.dart';
import 'package:lexcore/shared/components/app_surface_card.dart';
import 'package:lexcore/shared/widgets/app_mobile_canvas.dart';

class CaseDashboardPage extends ConsumerStatefulWidget {
  const CaseDashboardPage({super.key});

  @override
  ConsumerState<CaseDashboardPage> createState() => _CaseDashboardPageState();
}

class _CaseDashboardPageState extends ConsumerState<CaseDashboardPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(dashboardProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: AppMobileCanvas(
        maxContentWidth: 430,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const AppFadeSlideIn(
                delay: Duration(milliseconds: 20),
                beginOffset: Offset(0, -0.02),
                child: DashboardModuleTopBar(title: 'LexCore 案件分析'),
              ),
              AppFadeSlideIn(
                delay: const Duration(milliseconds: 40),
                beginOffset: const Offset(0, -0.02),
                child: DashboardSegmentedTabs(
                  selectedIndex: _tabController.index,
                  onSelectionChanged: (index) {
                    _tabController.animateTo(index);
                  },
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _OverviewContent(data: data),
                    const CaseDashboardCasesContent(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        key: const ValueKey<String>('dashboard_open_case_upload_fab'),
        onPressed: () => context.push(RouteNames.caseUploadPath),
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

class _OverviewContent extends StatelessWidget {
  const _OverviewContent({required this.data});

  final DashboardEntity data;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StatsGrid(data: data),
          const SizedBox(height: 24),
          _TrendSection(points: data.trendPoints),
          const SizedBox(height: 24),
          const _SectionHeader(title: '进行中的案件分析', actionLabel: '查看全部'),
          const SizedBox(height: 6),
          ...data.cases.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == data.cases.length - 1;
            return AppFadeSlideIn(
              delay: Duration(milliseconds: 80 + (index * 35)),
              beginOffset: const Offset(0, 0.02),
              child: _ProgressListItem(
                item: item,
                index: index,
                showBottomDivider: !isLast,
              ),
            );
          }),
          const SizedBox(height: 18),
          const _SectionHeader(title: '快速操作'),
          const SizedBox(height: 12),
          const _QuickActionsRow(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.data});

  final DashboardEntity data;

  @override
  Widget build(BuildContext context) {
    return AppFadeSlideIn(
      delay: const Duration(milliseconds: 30),
      beginOffset: const Offset(0, 0.02),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: AppSurfaceCard(
                  key: const ValueKey<String>('dashboard_metric_total_cases'),
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  padding: const EdgeInsets.all(18),
                  child: _MetricBlock(
                    label: '总案件量',
                    value: _formatCount(data.totalCases),
                    icon: Icons.folder_open,
                    caption: '本月 +12%',
                    captionIcon: Icons.trending_up,
                    valueColor: Theme.of(
                      context,
                    ).colorScheme.onPrimaryContainer,
                    iconColor: Theme.of(context).colorScheme.onPrimaryContainer,
                    captionColor: Theme.of(
                      context,
                    ).colorScheme.onPrimaryContainer.withValues(alpha: 0.82),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppSurfaceCard(
                  key: const ValueKey<String>('dashboard_metric_in_progress'),
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest,
                  padding: const EdgeInsets.all(18),
                  child: _MetricBlock(
                    label: '分析中',
                    value: '${data.inProgress}',
                    icon: Icons.auto_graph,
                    caption: '平均用时 4h',
                    captionIcon: Icons.schedule,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: AppSurfaceCard(
              padding: const EdgeInsets.all(18),
              child: _MetricBlock(
                label: '准确率',
                value: '${data.accuracy.toStringAsFixed(1)}%',
                icon: Icons.verified,
                caption: '符合司法标准',
                captionIcon: Icons.check_circle,
                captionColor: Theme.of(context).colorScheme.primaryFixedDim,
                iconColor: Theme.of(context).colorScheme.primaryFixedDim,
                valueColor: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCount(int value) {
    final text = value.toString();
    if (text.length <= 3) return text;
    return '${text.substring(0, text.length - 3)},${text.substring(text.length - 3)}';
  }
}

class _TrendSection extends StatelessWidget {
  const _TrendSection({required this.points});

  final List<double> points;

  @override
  Widget build(BuildContext context) {
    return AppFadeSlideIn(
      delay: const Duration(milliseconds: 70),
      child: AppSurfaceCard(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '分析趋势',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '过去7天的案件处理效率',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant,
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  icon: const Text('本周'),
                  label: const Icon(Icons.expand_more, size: 16),
                ),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 148,
              width: double.infinity,
              child: CustomPaint(
                painter: _TrendPainter(
                  points: points,
                  lineColor: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                _WeekdayLabel('周一'),
                _WeekdayLabel('周二'),
                _WeekdayLabel('周三'),
                _WeekdayLabel('周四'),
                _WeekdayLabel('周五'),
                _WeekdayLabel('周六'),
                _WeekdayLabel('周日'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.actionLabel});

  final String title;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const Spacer(),
        if (actionLabel != null)
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              actionLabel!,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
      ],
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _QuickActionCard(
            key: const ValueKey<String>('dashboard_quick_action_new_case'),
            icon: Icons.add,
            label: '新建案件',
            onTap: () => context.push(RouteNames.caseUploadPath),
          ),
          const SizedBox(width: 12),
          const _QuickActionCard(icon: Icons.upload_file, label: '批量上传'),
          const SizedBox(width: 12),
          const _QuickActionCard(icon: Icons.auto_stories, label: '法典查询'),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      padding: EdgeInsets.zero,
      child: Material(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: SizedBox(
            width: 104,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MetricBlock extends StatelessWidget {
  const _MetricBlock({
    required this.label,
    required this.value,
    required this.icon,
    required this.caption,
    required this.captionIcon,
    this.valueColor,
    this.iconColor,
    this.captionColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final String caption;
  final IconData captionIcon;
  final Color? valueColor;
  final Color? iconColor;
  final Color? captionColor;

  @override
  Widget build(BuildContext context) {
    final resolvedCaptionColor =
        captionColor ?? Theme.of(context).colorScheme.onSurfaceVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Icon(
              icon,
              size: 20,
              color:
                  iconColor ?? Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: valueColor ?? Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(captionIcon, size: 14, color: resolvedCaptionColor),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                caption,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: resolvedCaptionColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProgressListItem extends StatelessWidget {
  const _ProgressListItem({
    required this.item,
    required this.index,
    required this.showBottomDivider,
  });

  final DashboardCaseItem item;
  final int index;
  final bool showBottomDivider;

  @override
  Widget build(BuildContext context) {
    return AppListTileItem(
      key: ValueKey<String>('dashboard_case_item_$index'),
      title: item.title,
      subtitle: _caseSubtitle(item),
      leadingIcon: _CaseVisuals.iconFrom(item.icon),
      showBottomDivider: showBottomDivider,
      onTap: () {},
      trailing: SizedBox(
        width: 72,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${(item.progress * 100).toStringAsFixed(0)}%',
              key: ValueKey<String>('dashboard_case_progress_text_$index'),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                key: ValueKey<String>('dashboard_case_progress_bar_$index'),
                minHeight: 6,
                value: item.progress,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _caseSubtitle(DashboardCaseItem item) {
    switch (item.icon) {
      case 'gavel':
        return '上海市高级人民法院 · ${item.subtitle}';
      case 'description':
        return '知识产权法院 · ${item.subtitle}';
      case 'balance':
        return '内部法务部 · ${item.subtitle}';
      default:
        return item.subtitle;
    }
  }
}

class _CaseVisuals {
  const _CaseVisuals._();

  static IconData iconFrom(String icon) {
    switch (icon) {
      case 'gavel':
        return Icons.gavel_outlined;
      case 'description':
        return Icons.description_outlined;
      case 'balance':
        return Icons.balance_outlined;
      default:
        return Icons.folder_outlined;
    }
  }
}

class _WeekdayLabel extends StatelessWidget {
  const _WeekdayLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        fontSize: 11,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _TrendPainter extends CustomPainter {
  const _TrendPainter({required this.points, required this.lineColor});

  final List<double> points;
  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    final normalized = points.isEmpty
        ? const [0.8, 0.72, 0.74, 0.58, 0.5, 0.42, 0.47]
        : points;

    final path = Path();
    final fillPath = Path();

    for (var i = 0; i < normalized.length; i++) {
      final x = normalized.length == 1
          ? size.width / 2
          : size.width * i / (normalized.length - 1);
      final clamped = normalized[i].clamp(0.18, 0.9);
      final y = size.height * clamped;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, y);
      } else {
        final previousX = normalized.length == 1
            ? 0.0
            : size.width * (i - 1) / (normalized.length - 1);
        final previousY = size.height * normalized[i - 1].clamp(0.18, 0.9);
        final controlX = (previousX + x) / 2;
        path.cubicTo(controlX, previousY, controlX, y, x, y);
        fillPath.cubicTo(controlX, previousY, controlX, y, x, y);
      }
    }

    fillPath
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          lineColor.withValues(alpha: 0.2),
          lineColor.withValues(alpha: 0.02),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 3;

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _TrendPainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.lineColor != lineColor;
  }
}
