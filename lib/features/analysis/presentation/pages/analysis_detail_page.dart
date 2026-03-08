import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lexcore/app/router/route_names.dart';
import 'package:lexcore/app/theme/app_colors.dart';
import 'package:lexcore/features/analysis/application/analysis_providers.dart';
import 'package:lexcore/shared/components/app_primary_button.dart';
import 'package:lexcore/shared/components/app_surface_card.dart';
import 'package:lexcore/shared/widgets/app_page_scaffold.dart';

class AnalysisDetailPage extends ConsumerWidget {
  const AnalysisDetailPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(analysisSummaryProvider);

    return AppPageScaffold(
      title: '分析详情',
      body: ListView(
        children: [
          Text('案件分析摘要', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            summary.overview,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 10),
          AppSurfaceCard(
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: summary.metrics
                  .map(
                    (metric) => SizedBox(
                      width: 130,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            metric.label,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            metric.value,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 14),
          Text('风险提示', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          ...summary.risks.map(
            (risk) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AppSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '[${risk.level}] ${risk.title}',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 6),
                    Text(risk.description),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text('关键法条匹配', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          ...summary.statuteMatches.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AppSurfaceCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.gavel_outlined, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            item.detail,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          AppPrimaryButton(
            label: '查看分析结果',
            onPressed: () => context.push(RouteNames.analysisResultPath),
            icon: Icons.summarize,
          ),
          const SizedBox(height: 10),
          AppPrimaryButton(
            label: '进入案件仪表盘',
            onPressed: () => context.push(RouteNames.dashboardPath),
            icon: Icons.dashboard_outlined,
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
