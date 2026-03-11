import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:lexcore/app/theme/app_colors.dart';
import 'package:lexcore/app/theme/app_spacing.dart';
import 'package:lexcore/features/legal/presentation/widgets/legal_markdown_view.dart';
import 'package:lexcore/shared/components/app_surface_card.dart';
import 'package:lexcore/shared/widgets/app_page_scaffold.dart';

class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({super.key});

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
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
      title: '隐私政策',
      actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.share))],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ReadingProgressBar(progress: _progress),
          const SizedBox(height: AppSpacing.sm),
          const _PolicyMetaStrip(),
          const SizedBox(height: AppSpacing.sm),
          const _PrivacyHeroCard(),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: AppSurfaceCard(
              padding: EdgeInsets.zero,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: LegalMarkdownView(
                  assetPath: 'doc/privacy_policy.md',
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

class _PolicyMetaStrip extends StatelessWidget {
  const _PolicyMetaStrip();

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          const Icon(Icons.shield_outlined, color: AppColors.primary, size: 20),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              '隐私政策文档',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            '更新日期见正文',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _PrivacyHeroCard extends StatelessWidget {
  const _PrivacyHeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0x140B50DA), Color(0x05FFFFFF)],
        ),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '数据与隐私说明',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '我们以透明、可追溯的方式处理个人信息。以下条款来自最新政策文档，并随版本更新。',
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
