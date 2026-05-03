import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:lexcore/app/router/route_names.dart';
import 'package:lexcore/app/theme/app_spacing.dart';
import 'package:lexcore/core/utils/app_share.dart';
import 'package:lexcore/shared/components/app_surface_card.dart';
import 'package:lexcore/shared/widgets/app_page_scaffold.dart';

class ConsultationStitchDetailPage extends StatelessWidget {
  const ConsultationStitchDetailPage({super.key, this.summary});

  final String? summary;

  @override
  Widget build(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);
    final resolvedSummary = summary?.trim() ?? '';
    final hasSummary = resolvedSummary.isNotEmpty;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Future<void> shareDetail(BuildContext anchorContext) async {
      try {
        await AppShare.shareText(
          pageContext: context,
          anchorContext: anchorContext,
          text: resolvedSummary,
          subject: 'LexCore 解答详情',
        );
      } catch (_) {
        messenger.showSnackBar(const SnackBar(content: Text('分享失败，请稍后重试')));
      }
    }

    return AppPageScaffold(
      title: 'LexCore 解答详情',
      maxContentWidth: 560,
      actions: [
        if (hasSummary)
          Builder(
            builder: (buttonContext) => IconButton(
              onPressed: () => shareDetail(buttonContext),
              icon: const Icon(Icons.share_outlined),
              tooltip: '分享',
            ),
          ),
      ],
      body: ListView(
        children: [
          AppSurfaceCard(
            backgroundColor: colorScheme.primary.withValues(alpha: 0.08),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    hasSummary
                        ? Icons.auto_awesome_outlined
                        : Icons.description_outlined,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasSummary ? '智能解答摘要' : '暂无解答详情',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        hasSummary
                            ? '已整理 AI 对话中的核心结论与建议重点，支持继续生成法律意见书。'
                            : '请先在咨询会话中发送问题并等待回复。',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.55,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppSurfaceCard(
            child: hasSummary
                ? _SummaryDetailContent(summary: resolvedSummary)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '回复内容',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        '当前还没有可展示的解答内容，完成一次咨询后，这里会展示结构化摘要。',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.65,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
      bottomNavigationBar: hasSummary
          ? SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.xs,
                  AppSpacing.md,
                  AppSpacing.md,
                ),
                child: FilledButton.icon(
                  onPressed: () => context.pushNamed(
                    RouteNames.consultationOpinionDetail,
                    extra: resolvedSummary,
                  ),
                  icon: const Icon(Icons.gavel_outlined),
                  label: const Text('生成法律意见书'),
                ),
              ),
            )
          : null,
    );
  }
}

class _SummaryDetailContent extends StatelessWidget {
  const _SummaryDetailContent({required this.summary});

  final String summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final sections = _splitSummarySections(summary);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '回复内容',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '以下内容按段落整理展示，便于快速浏览与后续生成文书。',
          style: theme.textTheme.bodySmall?.copyWith(
            height: 1.5,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        for (var index = 0; index < sections.length; index++) ...[
          _SummarySection(text: sections[index]),
          if (index != sections.length - 1)
            const SizedBox(height: AppSpacing.lg),
        ],
      ],
    );
  }
}

class _SummarySection extends StatelessWidget {
  const _SummarySection({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isHeading = _isHeadingBlock(text);

    if (isHeading) {
      return Text(
        _normalizeHeading(text),
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
          height: 1.4,
        ),
      );
    }

    return Text(
      text,
      style: theme.textTheme.bodyMedium?.copyWith(
        height: 1.75,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }
}

List<String> _splitSummarySections(String summary) {
  return summary
      .split(RegExp(r'\n\s*\n'))
      .map((section) => section.trim())
      .where((section) => section.isNotEmpty)
      .toList();
}

bool _isHeadingBlock(String text) {
  final normalized = text.trim();
  if (normalized.isEmpty || normalized.contains('\n')) {
    return false;
  }
  return normalized.startsWith('#') ||
      (normalized.startsWith('**') && normalized.endsWith('**'));
}

String _normalizeHeading(String text) {
  return text.trim().replaceAll(RegExp(r'^#+\s*'), '').replaceAll('**', '');
}
