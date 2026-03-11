import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:lexcore/app/theme/app_colors.dart';
import 'package:lexcore/app/theme/app_spacing.dart';
import 'package:lexcore/features/legal/presentation/widgets/legal_markdown_view.dart';
import 'package:lexcore/shared/components/app_surface_card.dart';
import 'package:lexcore/shared/widgets/app_page_scaffold.dart';

class TermsOfServicePage extends StatefulWidget {
  const TermsOfServicePage({super.key});

  @override
  State<TermsOfServicePage> createState() => _TermsOfServicePageState();
}

class _TermsOfServicePageState extends State<TermsOfServicePage> {
  final ScrollController _scrollController = ScrollController();
  double _progress = 0;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _handleProgressChanged(double progress) {
    if ((_progress - progress).abs() <= 0.001) return;
    setState(() => _progress = progress);
  }

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      title: '服务条款',
      actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.share))],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ReadingProgressBar(progress: _progress),
          const SizedBox(height: AppSpacing.sm),
          const _TermsHeroCard(),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: AppSurfaceCard(
              padding: EdgeInsets.zero,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: LegalMarkdownView(
                  assetPath: 'doc/user_service.md',
                  controller: _scrollController,
                  onProgressChanged: _handleProgressChanged,
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.xl,
                  ),
                  styleSheet: _markdownStyle(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  MarkdownStyleSheet _markdownStyle(BuildContext context) {
    final theme = Theme.of(context);
    return MarkdownStyleSheet.fromTheme(theme).copyWith(
      h1: theme.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w800,
        color: AppColors.onSurface,
        letterSpacing: -0.2,
      ),
      h2: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w800,
        color: AppColors.onSurface,
      ),
      p: theme.textTheme.bodyMedium?.copyWith(
        color: AppColors.onSurfaceVariant,
        height: 1.65,
      ),
      listBullet: theme.textTheme.bodyMedium?.copyWith(
        color: AppColors.onSurface,
        height: 1.65,
      ),
      strong: theme.textTheme.bodyMedium?.copyWith(
        color: AppColors.onSurface,
        fontWeight: FontWeight.w700,
      ),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.outline.withValues(alpha: 0.25),
            width: 1,
          ),
        ),
      ),
    );
  }
}

class _ReadingProgressBar extends StatelessWidget {
  const _ReadingProgressBar({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: LinearProgressIndicator(
        value: progress,
        minHeight: 6,
        color: AppColors.primary,
        backgroundColor: AppColors.primary.withValues(alpha: 0.14),
      ),
    );
  }
}

class _TermsHeroCard extends StatelessWidget {
  const _TermsHeroCard();

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xxs,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '平台协议',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '用户服务协议',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '本协议内容由文档实时加载，阅读进度会随滚动同步更新。',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
