import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lexcore/app/adaptive/app_adaptive_split_view.dart';
import 'package:lexcore/app/adaptive/app_breakpoints.dart';
import 'package:lexcore/app/motion/app_motion_widgets.dart';
import 'package:lexcore/app/theme/app_colors.dart';
import 'package:lexcore/features/analysis/application/analysis_providers.dart';
import 'package:lexcore/features/analysis/domain/entities/analysis_summary.dart';
import 'package:lexcore/shared/components/app_surface_card.dart';
import 'package:lexcore/shared/widgets/app_mobile_canvas.dart';

class AnalysisResultPage extends ConsumerWidget {
  const AnalysisResultPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final report = ref.watch(analysisReportProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final viewport = AppBreakpoints.fromWidth(constraints.maxWidth);
        final splitLayout =
            viewport == AppViewportSize.expanded ||
            viewport == AppViewportSize.ultra;
        final showMobileBottomBar = viewport == AppViewportSize.compact;

        return Scaffold(
          body: AppMobileCanvas(
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  AppFadeSlideIn(
                    delay: const Duration(milliseconds: 20),
                    beginOffset: const Offset(0, -0.02),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 4, 8, 2),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.of(context).maybePop(),
                            icon: const Icon(Icons.arrow_back),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '案件分析结果',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.share),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.more_vert),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: splitLayout
                        ? Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                            child: AppAdaptiveSplitView(
                              splitMinWidth: 980,
                              secondaryMaxWidth: 360,
                              primary: _MainContent(
                                report: report,
                                includeRiskSection: false,
                                summaryGridColumns: 2,
                              ),
                              secondary: _SidePanel(report: report),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                            child: _MainContent(
                              report: report,
                              includeRiskSection: true,
                              summaryGridColumns: 1,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: showMobileBottomBar
              ? Container(
                  height: 74,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    border: Border(
                      top: BorderSide(color: Theme.of(context).dividerColor),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const [
                      _BottomMini(
                        label: '报告',
                        icon: Icons.description,
                        active: true,
                      ),
                      _BottomMini(
                        label: '证据',
                        icon: Icons.folder_open_outlined,
                      ),
                      _BottomMini(label: '法规', icon: Icons.gavel_outlined),
                      _BottomMini(label: '我的', icon: Icons.person_outline),
                    ],
                  ),
                )
              : null,
        );
      },
    );
  }
}

class _MainContent extends StatelessWidget {
  const _MainContent({
    required this.report,
    required this.includeRiskSection,
    required this.summaryGridColumns,
  });

  final AnalysisSummary report;
  final bool includeRiskSection;
  final int summaryGridColumns;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        AppFadeSlideIn(
          delay: const Duration(milliseconds: 55),
          child: Row(
            children: [
              const Icon(
                Icons.auto_awesome,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: 6),
              Text(
                'LexiAI 智能分析报告',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        AppFadeSlideIn(
          delay: const Duration(milliseconds: 75),
          child: Text(
            '报告编号: ${report.reportId} • 生成于 ${report.generatedAt}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant),
          ),
        ),
        const SizedBox(height: 14),
        AppFadeSlideIn(
          delay: const Duration(milliseconds: 110),
          child: _OverviewCard(report: report),
        ),
        if (includeRiskSection) ...[
          const SizedBox(height: 14),
          AppFadeSlideIn(
            delay: const Duration(milliseconds: 150),
            child: _RiskSection(report: report),
          ),
        ],
        const SizedBox(height: 14),
        AppFadeSlideIn(
          delay: const Duration(milliseconds: 190),
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: summaryGridColumns,
            childAspectRatio: summaryGridColumns == 1 ? 1.9 : 1.45,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            children: [
              _SummaryCard(
                title: '争议焦点',
                icon: Icons.center_focus_strong,
                lines: report.disputeFocus,
              ),
              _SummaryCard(
                title: '法律关系',
                icon: Icons.account_tree_outlined,
                lines: report.legalRelations,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        AppFadeSlideIn(
          delay: const Duration(milliseconds: 220),
          child: Text('关键证据效力', style: Theme.of(context).textTheme.titleSmall),
        ),
        const SizedBox(height: 8),
        ...report.evidences.asMap().entries.map((entry) {
          final index = entry.key;
          final evidence = entry.value;
          return AppFadeSlideIn(
            delay: Duration(milliseconds: 30 + (index * 35)),
            beginOffset: const Offset(0, 0.02),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _EvidenceTile(
                title: evidence.title,
                score: evidence.score,
                strong: evidence.strong,
              ),
            ),
          );
        }),
        const SizedBox(height: 10),
      ],
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.report});

  final AnalysisSummary report;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 192,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.12),
                  AppColors.primary.withValues(alpha: 0.3),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
            ),
            child: Stack(
              children: [
                const Center(
                  child: Icon(
                    Icons.gavel_outlined,
                    size: 58,
                    color: Color(0x420B50DA),
                  ),
                ),
                Positioned(
                  left: 14,
                  bottom: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '结构化分析已完成',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('案件概览', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 6),
                Text(
                  report.overview,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 10),
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.open_in_new, size: 18),
                  label: const Text('查看详细摘要'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(42),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidePanel extends StatelessWidget {
  const _SidePanel({required this.report});

  final AnalysisSummary report;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        AppFadeSlideIn(
          delay: const Duration(milliseconds: 120),
          child: _RiskSection(report: report),
        ),
        const SizedBox(height: 12),
        AppFadeSlideIn(
          delay: const Duration(milliseconds: 160),
          child: AppSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('快捷操作', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                FilledButton.tonalIcon(
                  onPressed: () {},
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  label: const Text('导出 PDF 报告'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.bookmark_border),
                  label: const Text('收藏到案件库'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.share_outlined),
                  label: const Text('分享报告链接'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _RiskSection extends StatelessWidget {
  const _RiskSection({required this.report});

  final AnalysisSummary report;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.amber),
              const SizedBox(width: 6),
              Text('风险指标评估', style: Theme.of(context).textTheme.titleSmall),
            ],
          ),
          const SizedBox(height: 12),
          ...report.riskIndicators.map(
            (risk) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _RiskBar(
                label: risk.label,
                value: risk.value,
                levelText: _riskLabel(risk.level),
                color: _riskColor(risk.level),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _riskColor(RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return Colors.green;
      case RiskLevel.medium:
        return Colors.orange;
      case RiskLevel.high:
        return Colors.red;
    }
  }

  String _riskLabel(RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return '低风险';
      case RiskLevel.medium:
        return '中等风险';
      case RiskLevel.high:
        return '高风险';
    }
  }
}

class _RiskBar extends StatelessWidget {
  const _RiskBar({
    required this.label,
    required this.value,
    required this.levelText,
    required this.color,
  });

  final String label;
  final double value;
  final String levelText;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(label, style: Theme.of(context).textTheme.bodySmall),
            ),
            Text(
              '$levelText (${(value * 100).toStringAsFixed(0)}%)',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 8,
            value: value,
            backgroundColor: const Color(0xFFEFF2F6),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.icon,
    required this.lines,
  });

  final String title;
  final IconData icon;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.primary.withValues(alpha: 0.12),
                ),
                child: Icon(icon, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 8),
              Text(title, style: Theme.of(context).textTheme.titleSmall),
            ],
          ),
          const SizedBox(height: 10),
          ...lines.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 3),
                    child: Icon(
                      Icons.circle,
                      size: 6,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      line,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EvidenceTile extends StatelessWidget {
  const _EvidenceTile({
    required this.title,
    required this.score,
    required this.strong,
  });

  final String title;
  final String score;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Icon(
            strong ? Icons.description_outlined : Icons.image_outlined,
            color: AppColors.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  '效力评分: $score',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            strong ? Icons.check_circle : Icons.info_outline,
            color: strong ? Colors.green : Colors.orange,
          ),
        ],
      ),
    );
  }
}

class _BottomMini extends StatelessWidget {
  const _BottomMini({
    required this.label,
    required this.icon,
    this.active = false,
  });

  final String label;
  final IconData icon;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 20,
          color: active ? AppColors.primary : AppColors.onSurfaceVariant,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: active ? AppColors.primary : AppColors.onSurfaceVariant,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
