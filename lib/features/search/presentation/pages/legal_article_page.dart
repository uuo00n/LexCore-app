import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lexcore/app/adaptive/app_adaptive_split_view.dart';
import 'package:lexcore/app/adaptive/app_breakpoints.dart';
import 'package:lexcore/features/search/application/search_controller.dart';
import 'package:lexcore/features/search/domain/entities/search_state.dart';
import 'package:lexcore/shared/components/app_list_tile_item.dart';
import 'package:lexcore/shared/components/app_surface_card.dart';
import 'package:lexcore/shared/models/legal_models.dart';
import 'package:lexcore/shared/widgets/app_page_scaffold.dart';

class LegalArticlePage extends ConsumerWidget {
  const LegalArticlePage({super.key, this.searchItem});

  final LawSearchItem? searchItem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(articleDetailByItemProvider(searchItem));

    return AppPageScaffold(
      title: searchItem?.articleCode ?? '文章详情',
      actions: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.bookmark_border)),
        IconButton(onPressed: () {}, icon: const Icon(Icons.share_outlined)),
        IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert_rounded)),
      ],
      body: LayoutBuilder(
        builder: (context, constraints) {
          final viewport = AppBreakpoints.fromWidth(constraints.maxWidth);
          final splitLayout =
              viewport == AppViewportSize.expanded ||
              viewport == AppViewportSize.ultra;

          if (!splitLayout) {
            return _ArticleMain(detail: detail, compact: true);
          }

          return AppAdaptiveSplitView(
            splitMinWidth: 980,
            secondaryMaxWidth: 360,
            primary: _ArticleMain(detail: detail, compact: false),
            secondary: _ArticleSide(detail: detail),
          );
        },
      ),
    );
  }
}

class _ArticleMain extends StatelessWidget {
  const _ArticleMain({required this.detail, required this.compact});

  final LawArticleDetail detail;
  final bool compact;

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
                  onPressed: () {},
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
        Text(
          detail.content,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.8),
        ),
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
        if (compact) ...[
          const SizedBox(height: 14),
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
      ],
    );
  }
}

class _ArticleSide extends StatelessWidget {
  const _ArticleSide({required this.detail});

  final LawArticleDetail detail;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
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
      showBottomDivider: showBottomDivider,
      onTap: () {},
    );
  }
}
