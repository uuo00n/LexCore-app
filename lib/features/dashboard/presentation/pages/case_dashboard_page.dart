import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lexcore/app/motion/app_motion_widgets.dart';
import 'package:lexcore/app/theme/app_colors.dart';
import 'package:lexcore/features/dashboard/application/dashboard_provider.dart';
import 'package:lexcore/features/dashboard/domain/entities/dashboard_entity.dart';
import 'package:lexcore/shared/components/app_surface_card.dart';
import 'package:lexcore/shared/widgets/app_mobile_canvas.dart';

class CaseDashboardPage extends ConsumerWidget {
  const CaseDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(dashboardProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppMobileCanvas(
        maxContentWidth: 430,
        child: SafeArea(
          bottom: false,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                elevation: 0,
                scrolledUnderElevation: 0,
                backgroundColor: AppColors.background.withValues(alpha: 0.92),
                surfaceTintColor: Colors.transparent,
                toolbarHeight: 64,
                titleSpacing: 0,
                leadingWidth: 56,
                leading: IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.menu, color: AppColors.onSurface),
                ),
                title: Text(
                  'LexiAI 案件分析',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                actions: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.search, color: AppColors.onSurface),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.16),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.1),
                        ),
                      ),
                      child: const Icon(
                        Icons.account_circle,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate.fixed([
                    _StatsGrid(data: data),
                    const SizedBox(height: 24),
                    _TrendSection(points: data.trendPoints),
                    const SizedBox(height: 24),
                    _SectionHeader(title: '进行中的案件分析', actionLabel: '查看全部'),
                    const SizedBox(height: 12),
                    ...data.cases.asMap().entries.map((entry) {
                      final item = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: AppFadeSlideIn(
                          delay: Duration(milliseconds: 80 + (entry.key * 35)),
                          beginOffset: const Offset(0, 0.02),
                          child: _ProgressListItem(item: item),
                        ),
                      );
                    }),
                    const SizedBox(height: 18),
                    const _SectionHeader(title: '快速操作'),
                    const SizedBox(height: 12),
                    const _QuickActionsRow(),
                    const SizedBox(height: 112),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const _DashboardBottomBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          SizedBox(
            width: 168,
            child: AppSurfaceCard(
              backgroundColor: AppColors.primaryContainer,
              padding: const EdgeInsets.all(18),
              child: _MetricBlock(
                label: '总案件量',
                value: _formatCount(data.totalCases),
                icon: Icons.folder_open,
                caption: '本月 +12%',
                captionIcon: Icons.trending_up,
                valueColor: AppColors.onPrimaryContainer,
                iconColor: AppColors.onPrimaryContainer,
                captionColor: AppColors.onPrimaryContainer.withValues(
                  alpha: 0.82,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 168,
            child: AppSurfaceCard(
              backgroundColor: const Color(0xFFE7E8F2),
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
                captionColor: const Color(0xFF1F8B4C),
                iconColor: const Color(0xFF1F8B4C),
                valueColor: AppColors.onSurface,
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
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.onSurfaceVariant,
                    side: const BorderSide(color: AppColors.outline),
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
              child: CustomPaint(painter: _TrendPainter(points: points)),
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
              foregroundColor: AppColors.primary,
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
        children: const [
          _QuickActionCard(icon: Icons.add, label: '新建案件'),
          SizedBox(width: 12),
          _QuickActionCard(icon: Icons.upload_file, label: '批量上传'),
          SizedBox(width: 12),
          _QuickActionCard(icon: Icons.auto_stories, label: '法典查询'),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: SizedBox(
        width: 88,
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: AppColors.primary),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardBottomBar extends StatelessWidget {
  const _DashboardBottomBar();

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      height: 80,
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          _BottomNavItem(icon: Icons.dashboard, label: '概览', selected: true),
          _BottomNavItem(icon: Icons.folder_open, label: '案件'),
          _BottomNavItem(icon: Icons.summarize, label: '报告'),
          _BottomNavItem(icon: Icons.settings, label: '设置'),
        ],
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.icon,
    required this.label,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final foreground = selected
        ? AppColors.primary
        : AppColors.onSurfaceVariant;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 32,
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primary.withValues(alpha: 0.16)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 20, color: foreground),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: foreground,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
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
    final resolvedCaptionColor = captionColor ?? AppColors.onSurfaceVariant;

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
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
            Icon(
              icon,
              size: 20,
              color: iconColor ?? AppColors.onSurfaceVariant,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: valueColor ?? AppColors.onSurface,
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
  const _ProgressListItem({required this.item});

  final DashboardCaseItem item;

  @override
  Widget build(BuildContext context) {
    final config = _CaseVisuals.fromIcon(item.icon);

    return AppSurfaceCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: config.background,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(config.icon, color: config.foreground, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  _caseSubtitle(item),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 56,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${(item.progress * 100).toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    minHeight: 6,
                    value: item.progress,
                    backgroundColor: AppColors.surfaceVariant,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
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
  const _CaseVisuals({
    required this.icon,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final Color background;
  final Color foreground;

  factory _CaseVisuals.fromIcon(String icon) {
    switch (icon) {
      case 'gavel':
        return const _CaseVisuals(
          icon: Icons.gavel_outlined,
          background: Color(0xFFEAF0FF),
          foreground: Color(0xFF356AE6),
        );
      case 'description':
        return const _CaseVisuals(
          icon: Icons.description_outlined,
          background: Color(0xFFFFF0E6),
          foreground: Color(0xFFE56A1F),
        );
      case 'balance':
        return const _CaseVisuals(
          icon: Icons.balance_outlined,
          background: Color(0xFFF2EAFF),
          foreground: Color(0xFF8A56E8),
        );
      default:
        return const _CaseVisuals(
          icon: Icons.folder_outlined,
          background: Color(0xFFEAF0FF),
          foreground: AppColors.primary,
        );
    }
  }
}

class _WeekdayLabel extends StatelessWidget {
  const _WeekdayLabel(this.text);

  final String text;

  static final TextStyle _style = TextStyle(
    fontSize: 11,
    color: AppColors.onSurfaceVariant,
    fontWeight: FontWeight.w500,
  );

  @override
  Widget build(BuildContext context) {
    return Text(text, style: _style);
  }
}

class _TrendPainter extends CustomPainter {
  const _TrendPainter({required this.points});

  final List<double> points;

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
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0x330B50DA), Color(0x050B50DA)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final linePaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 3;

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _TrendPainter oldDelegate) {
    return oldDelegate.points != points;
  }
}
