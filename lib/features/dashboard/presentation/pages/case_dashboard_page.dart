import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lexcore/app/motion/app_motion_widgets.dart';
import 'package:lexcore/app/theme/app_colors.dart';
import 'package:lexcore/features/dashboard/application/dashboard_provider.dart';
import 'package:lexcore/shared/components/app_surface_card.dart';
import 'package:lexcore/shared/widgets/app_mobile_canvas.dart';

class CaseDashboardPage extends ConsumerWidget {
  const CaseDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(dashboardProvider);

    return Scaffold(
      body: AppMobileCanvas(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            children: [
              AppFadeSlideIn(
                delay: const Duration(milliseconds: 20),
                beginOffset: const Offset(0, -0.02),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.menu),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'LexiAI 案件分析',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.search),
                    ),
                    const CircleAvatar(
                      radius: 16,
                      backgroundColor: Color(0x220B50DA),
                      child: Icon(
                        Icons.account_circle_outlined,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              AppFadeSlideIn(
                delay: const Duration(milliseconds: 70),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    AppSurfaceCard(
                      backgroundColor: AppColors.primaryContainer,
                      child: _MetricBlock(
                        label: '总案件量',
                        value: '${data.totalCases}',
                        trailing: const Icon(Icons.folder_open),
                        caption: '本月 +12%',
                        valueColor: AppColors.onPrimaryContainer,
                      ),
                    ),
                    AppSurfaceCard(
                      backgroundColor: AppColors.surfaceVariant,
                      child: _MetricBlock(
                        label: '分析中',
                        value: '${data.inProgress}',
                        trailing: const Icon(Icons.insights_outlined),
                        caption: '平均用时 4h',
                      ),
                    ),
                    AppSurfaceCard(
                      child: _MetricBlock(
                        label: '准确率',
                        value: '${data.accuracy.toStringAsFixed(1)}%',
                        trailing: const Icon(
                          Icons.verified_outlined,
                          color: Colors.green,
                        ),
                        caption: '符合司法标准',
                        valueColor: AppColors.onSurface,
                      ),
                    ),
                    AppSurfaceCard(
                      child: _MetricBlock(
                        label: '已完成',
                        value: '${data.completed}',
                        trailing: const Icon(Icons.check_circle_outline),
                        caption: '质量稳定',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              AppFadeSlideIn(
                delay: const Duration(milliseconds: 120),
                child: AppSurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '分析趋势',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '过去7天的案件处理效率',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 120,
                        child: CustomPaint(
                          size: const Size(double.infinity, 120),
                          painter: _TrendPainter(points: data.trendPoints),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              AppFadeSlideIn(
                delay: const Duration(milliseconds: 160),
                child: Row(
                  children: [
                    Text(
                      '进行中的案件分析',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const Spacer(),
                    TextButton(onPressed: () {}, child: const Text('查看全部')),
                  ],
                ),
              ),
              ...data.cases.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return AppFadeSlideIn(
                  delay: Duration(milliseconds: 30 + (index * 35)),
                  beginOffset: const Offset(0, 0.02),
                  child: _ProgressListItem(
                    title: item.title,
                    subtitle: item.subtitle,
                    progress: item.progress,
                    icon: _iconFrom(item.icon),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }

  IconData _iconFrom(String icon) {
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

class _MetricBlock extends StatelessWidget {
  const _MetricBlock({
    required this.label,
    required this.value,
    required this.trailing,
    required this.caption,
    this.valueColor,
  });

  final String label;
  final String value;
  final Widget trailing;
  final String caption;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            trailing,
          ],
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: valueColor),
        ),
        const SizedBox(height: 4),
        Text(
          caption,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(color: AppColors.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _ProgressListItem extends StatelessWidget {
  const _ProgressListItem({
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final double progress;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppSurfaceCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.11),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 60,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
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
                      value: progress,
                      backgroundColor: AppColors.surfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendPainter extends CustomPainter {
  const _TrendPainter({required this.points});

  final List<double> points;

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0x330B50DA), Color(0x000B50DA)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final safePoints = points.isEmpty ? const [0.8, 0.7, 0.6, 0.5] : points;

    final path = Path();
    for (var i = 0; i < safePoints.length; i++) {
      final x = (size.width / (safePoints.length - 1)) * i;
      final y = size.height * safePoints[i].clamp(0.1, 0.95);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _TrendPainter oldDelegate) {
    return oldDelegate.points != points;
  }
}
