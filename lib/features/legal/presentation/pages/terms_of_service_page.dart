import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:lexcore/app/theme/app_spacing.dart';
import 'package:lexcore/core/constants/app_constants.dart';
import 'package:lexcore/core/utils/app_share.dart';
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

  Future<void> _shareTerms(BuildContext anchorContext) async {
    try {
      final text =
          widget.markdownData ?? await rootBundle.loadString(_assetPath);
      if (!mounted || !anchorContext.mounted) return;
      await AppShare.shareText(
        pageContext: context,
        anchorContext: anchorContext,
        text: text,
        subject: '${AppConstants.appName} 服务条款',
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
        Builder(
          builder: (buttonContext) => IconButton(
            onPressed: () => _shareTerms(buttonContext),
            tooltip: '分享',
            icon: const Icon(Icons.share_outlined),
          ),
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
        color: Theme.of(context).colorScheme.onSurface,
        letterSpacing: -0.2,
      ),
      h2: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w800,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      p: theme.textTheme.bodyMedium?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        height: 1.65,
      ),
      listBullet: theme.textTheme.bodyMedium?.copyWith(
        color: Theme.of(context).colorScheme.onSurface,
        height: 1.65,
      ),
      strong: theme.textTheme.bodyMedium?.copyWith(
        color: Theme.of(context).colorScheme.onSurface,
        fontWeight: FontWeight.w700,
      ),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(
              context,
            ).colorScheme.outline.withValues(alpha: 0.25),
            width: 1,
          ),
        ),
      ),
    );
  }
}
