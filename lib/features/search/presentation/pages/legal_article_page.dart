import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:lexcore/app/router/route_names.dart';
import 'package:lexcore/app/adaptive/app_adaptive_split_view.dart';
import 'package:lexcore/app/adaptive/app_breakpoints.dart';
import 'package:lexcore/core/utils/app_share.dart';
import 'package:lexcore/core/utils/feature_notice.dart';
import 'package:lexcore/features/search/application/search_controller.dart';
import 'package:lexcore/features/search/domain/entities/search_state.dart';
import 'package:lexcore/shared/components/app_list_tile_item.dart';
import 'package:lexcore/shared/components/app_surface_card.dart';
import 'package:lexcore/shared/models/legal_models.dart';
import 'package:lexcore/shared/widgets/app_page_scaffold.dart';
import 'package:lexcore/shared/widgets/in_app_webview_page.dart';

class LegalArticlePage extends ConsumerWidget {
  const LegalArticlePage({super.key, this.searchItem});

  final LawSearchItem? searchItem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(articleDetailByItemProvider(searchItem));
    final messenger = ScaffoldMessenger.of(context);

    Future<void> openLink(
      String url,
      String label,
      InAppWebViewKind? kind,
    ) async {
      final uri = Uri.tryParse(url);
      if (uri == null) {
        messenger.showSnackBar(SnackBar(content: Text('$label链接无效，请稍后重试')));
        return;
      }
      if (kind != null &&
          uri.hasScheme &&
          (uri.scheme == 'http' || uri.scheme == 'https')) {
        context.pushNamed(
          RouteNames.inAppWebView,
          extra: InAppWebViewRouteArgs(title: label, url: url, kind: kind),
        );
        return;
      }
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened && context.mounted) {
        messenger.showSnackBar(SnackBar(content: Text('$label打开失败，请稍后重试')));
      }
    }

    Future<void> shareArticle(BuildContext anchorContext) async {
      final detail = detailAsync.valueOrNull;
      if (detail == null) {
        return;
      }
      final shareText = _buildArticleShareText(detail);
      try {
        await AppShare.shareText(
          pageContext: context,
          anchorContext: anchorContext,
          text: shareText,
          subject: detail.title,
        );
      } catch (_) {
        messenger.showSnackBar(const SnackBar(content: Text('分享失败，请稍后重试')));
      }
    }

    final pageTitle = detailAsync.maybeWhen(
      data: (detail) => detail.title,
      orElse: () => searchItem?.title ?? '文章详情',
    );

    return AppPageScaffold(
      title: pageTitle,
      actions: [
        IconButton(
          onPressed: () =>
              showFeatureInProgressSnackBar(context, featureLabel: '收藏'),
          icon: const Icon(Icons.bookmark_border),
        ),
        Builder(
          builder: (buttonContext) => IconButton(
            onPressed: () => shareArticle(buttonContext),
            tooltip: '分享',
            icon: const Icon(Icons.share_outlined),
          ),
        ),
        IconButton(
          onPressed: () =>
              showFeatureInProgressSnackBar(context, featureLabel: '更多操作'),
          icon: const Icon(Icons.more_vert_rounded),
        ),
      ],
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => const Center(child: Text('法规详情加载失败')),
        data: (detail) => LayoutBuilder(
          builder: (context, constraints) {
            final viewport = AppBreakpoints.fromWidth(constraints.maxWidth);
            final splitLayout =
                viewport == AppViewportSize.expanded ||
                viewport == AppViewportSize.ultra;

            if (!splitLayout) {
              return _ArticleMain(
                detail: detail,
                compact: true,
                onOpenLink: openLink,
              );
            }

            return AppAdaptiveSplitView(
              splitMinWidth: 980,
              secondaryMaxWidth: 360,
              primary: _ArticleMain(
                detail: detail,
                compact: false,
                onOpenLink: openLink,
              ),
              secondary: _ArticleSide(detail: detail, onOpenLink: openLink),
            );
          },
        ),
      ),
    );
  }
}

class _ArticleMain extends StatelessWidget {
  const _ArticleMain({
    required this.detail,
    required this.compact,
    required this.onOpenLink,
  });

  final LawArticleDetail detail;
  final bool compact;
  final Future<void> Function(String url, String label, InAppWebViewKind? kind)
  onOpenLink;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: detail.tags
              .asMap()
              .entries
              .map((entry) => _TagChip(entry.value, entry.key == 0))
              .toList(),
        ),
        const SizedBox(height: 10),
        Text(detail.title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        AppSurfaceCard(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              const CircleAvatar(radius: 22, child: Icon(Icons.person_outline)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      detail.author,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(
                      detail.publishInfo,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 72,
                child: FilledButton(
                  onPressed: () => showFeatureInProgressSnackBar(
                    context,
                    featureLabel: '关注',
                  ),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('关注'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        AppSurfaceCard(
          backgroundColor: Theme.of(
            context,
          ).colorScheme.primary.withValues(alpha: 0.06),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.smart_toy_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '智能摘要',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                detail.summary,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text('法规正文', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        _ArticleLinkActions(detail: detail, onOpenLink: onOpenLink),
        if (detail.fallbackMessage != null) ...[
          const SizedBox(height: 10),
          AppSurfaceCard(
            backgroundColor: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest,
            child: Text(
              detail.fallbackMessage!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
        const SizedBox(height: 10),
        ..._buildBodyContent(context),
        if (detail.quote.trim().isNotEmpty) ...[
          const SizedBox(height: 12),
          AppSurfaceCard(
            backgroundColor: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.05),
            child: Text(
              '“${detail.quote}”',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
            ),
          ),
        ],
        if (compact) ...[
          const SizedBox(height: 14),
          _ArticleSideSection(
            detail: detail,
            onOpenLink: onOpenLink,
            showEntryActions: false,
          ),
        ],
      ],
    );
  }

  List<Widget> _buildBodyContent(BuildContext context) {
    final sections = detail.bodySections.isNotEmpty
        ? detail.bodySections
        : [detail.content];
    return sections
        .where((section) => section.trim().isNotEmpty)
        .map(
          (section) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              section,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(height: 1.8),
            ),
          ),
        )
        .toList();
  }
}

class _ArticleSide extends StatelessWidget {
  const _ArticleSide({required this.detail, required this.onOpenLink});

  final LawArticleDetail detail;
  final Future<void> Function(String url, String label, InAppWebViewKind? kind)
  onOpenLink;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [_ArticleSideSection(detail: detail, onOpenLink: onOpenLink)],
    );
  }
}

class _ArticleSideSection extends StatelessWidget {
  const _ArticleSideSection({
    required this.detail,
    required this.onOpenLink,
    this.showEntryActions = true,
  });

  final LawArticleDetail detail;
  final Future<void> Function(String url, String label, InAppWebViewKind? kind)
  onOpenLink;
  final bool showEntryActions;

  @override
  Widget build(BuildContext context) {
    final secondaryActions = _secondaryLinkActions();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showEntryActions && secondaryActions.isNotEmpty) ...[
          Text('原文入口', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          ...secondaryActions,
          const SizedBox(height: 14),
        ],
        Text('法律引用与关联', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        ...detail.citations.asMap().entries.map(
          (entry) => _CitationTile(
            title: entry.value.title,
            subtitle: entry.value.subtitle,
            showBottomDivider: entry.key != detail.citations.length - 1,
          ),
        ),
      ],
    );
  }

  List<Widget> _secondaryLinkActions() {
    final actions = <Widget>[];
    void addAction(String label, String? url, InAppWebViewKind? kind) {
      if (url == null) {
        return;
      }
      actions.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: OutlinedButton.icon(
            onPressed: () => onOpenLink(url, label, kind),
            icon: const Icon(Icons.open_in_new_rounded),
            label: Text(label),
          ),
        ),
      );
    }

    addAction(
      '查看原文',
      detail.sourceUrl ?? detail.htmlUrl,
      InAppWebViewKind.html,
    );
    addAction('打开 HTML', detail.htmlUrl, InAppWebViewKind.html);
    addAction('下载 PDF', detail.pdfUrl, InAppWebViewKind.pdf);
    addAction('下载 DOCX', detail.docxUrl, null);
    return actions;
  }
}

class _ArticleLinkActions extends StatelessWidget {
  const _ArticleLinkActions({required this.detail, required this.onOpenLink});

  final LawArticleDetail detail;
  final Future<void> Function(String url, String label, InAppWebViewKind? kind)
  onOpenLink;

  @override
  Widget build(BuildContext context) {
    final actions = <Widget>[];

    void addAction(
      String label,
      String? url,
      IconData icon,
      InAppWebViewKind? kind,
    ) {
      if (url == null) {
        return;
      }
      actions.add(
        OutlinedButton.icon(
          onPressed: () => onOpenLink(url, label, kind),
          icon: Icon(icon),
          label: Text(label),
        ),
      );
    }

    addAction(
      '查看原文',
      detail.sourceUrl ?? detail.htmlUrl,
      Icons.menu_book,
      InAppWebViewKind.html,
    );
    addAction(
      '打开 HTML',
      detail.htmlUrl,
      Icons.language_rounded,
      InAppWebViewKind.html,
    );
    addAction(
      '下载 PDF',
      detail.pdfUrl,
      Icons.picture_as_pdf_rounded,
      InAppWebViewKind.pdf,
    );
    addAction('下载 DOCX', detail.docxUrl, Icons.download_rounded, null);

    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(spacing: 10, runSpacing: 10, children: actions);
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip(this.label, this.primary);

  final String label;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: primary
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.12)
            : Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: primary
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _CitationTile extends StatelessWidget {
  const _CitationTile({
    required this.title,
    required this.subtitle,
    required this.showBottomDivider,
  });

  final String title;
  final String subtitle;
  final bool showBottomDivider;

  @override
  Widget build(BuildContext context) {
    return AppListTileItem(
      title: title,
      subtitle: subtitle,
      leadingIcon: Icons.gavel_outlined,
      trailing: const SizedBox.shrink(),
      showBottomDivider: showBottomDivider,
      onTap: null,
    );
  }
}

String _buildArticleShareText(LawArticleDetail detail) {
  final bodyPreview = detail.bodySections.isNotEmpty
      ? detail.bodySections.first
      : detail.content;
  return [
    'LexCore 法律文章',
    '标题：${detail.title}',
    '作者：${detail.author}',
    '发布时间：${detail.publishInfo}',
    '',
    '智能摘要',
    detail.summary,
    '',
    '关键引用',
    detail.quote,
    '',
    '正文摘录',
    bodyPreview,
    '',
    '法律引用与关联',
    ...detail.citations.map((item) => '• ${item.title}：${item.subtitle}'),
    if (detail.sourceUrl != null ||
        detail.htmlUrl != null ||
        detail.pdfUrl != null ||
        detail.docxUrl != null) ...[
      '',
      '原文入口',
      if (detail.sourceUrl != null) '• 查看原文：${detail.sourceUrl}',
      if (detail.htmlUrl != null) '• HTML：${detail.htmlUrl}',
      if (detail.pdfUrl != null) '• PDF：${detail.pdfUrl}',
      if (detail.docxUrl != null) '• DOCX：${detail.docxUrl}',
    ],
  ].join('\n');
}
