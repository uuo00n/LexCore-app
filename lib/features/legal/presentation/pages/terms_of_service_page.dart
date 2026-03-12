import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:share_plus/share_plus.dart';

import 'package:lexcore/app/theme/app_colors.dart';
import 'package:lexcore/app/theme/app_spacing.dart';
import 'package:lexcore/core/constants/app_constants.dart';
import 'package:lexcore/features/legal/presentation/widgets/legal_markdown_view.dart';
import 'package:lexcore/shared/widgets/app_page_scaffold.dart';

class TermsOfServicePage extends StatefulWidget {
  const TermsOfServicePage({super.key, this.markdownData});

  final String? markdownData;

  @override
  State<TermsOfServicePage> createState() => _TermsOfServicePageState();
}

class _TermsOfServicePageState extends State<TermsOfServicePage> {
  static const _assetPath = 'doc/user_service.md';

  Future<void> _shareTerms() async {
    try {
      final text = await rootBundle.loadString(_assetPath);
      await SharePlus.instance.share(
        ShareParams(text: text, subject: '${AppConstants.appName} 服务条款'),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('分享失败，请稍后重试')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      title: '服务条款',
      actions: [
        IconButton(
          onPressed: _shareTerms,
          tooltip: '分享',
          icon: const Icon(Icons.share),
        ),
      ],
      body: LegalMarkdownView(
        assetPath: _assetPath,
        markdownData: widget.markdownData,
        selectable: false,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.xl,
        ),
        styleSheet: _markdownStyle(context),
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
