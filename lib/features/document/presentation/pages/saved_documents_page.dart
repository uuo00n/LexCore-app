import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lexcore/app/adaptive/app_breakpoints.dart';
import 'package:lexcore/app/router/route_names.dart';
import 'package:lexcore/core/utils/date_time_utils.dart';
import 'package:lexcore/core/utils/feature_notice.dart';
import 'package:lexcore/features/document/application/document_providers.dart';
import 'package:lexcore/shared/components/app_surface_card.dart';
import 'package:lexcore/shared/models/legal_models.dart';
import 'package:lexcore/shared/widgets/app_page_scaffold.dart';

class SavedDocumentsPage extends ConsumerStatefulWidget {
  const SavedDocumentsPage({super.key});

  @override
  ConsumerState<SavedDocumentsPage> createState() => _SavedDocumentsPageState();
}

class _SavedDocumentsPageState extends ConsumerState<SavedDocumentsPage> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final documentState = ref.watch(documentControllerProvider);
    final docs = ref.watch(savedDocumentsProvider);

    return AppPageScaffold(
      title: '已保存的文档',
      actions: [
        IconButton(
          onPressed: () =>
              showFeatureInProgressSnackBar(context, featureLabel: '文档搜索'),
          icon: const Icon(Icons.search),
        ),
        IconButton(
          onPressed: () =>
              showFeatureInProgressSnackBar(context, featureLabel: '更多操作'),
          icon: const Icon(Icons.more_vert_rounded),
        ),
      ],
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (documentState.loading && docs.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (documentState.errorMessage != null && docs.isEmpty) {
            return _DocumentStatePlaceholder(
              title: '文档加载失败',
              subtitle: documentState.errorMessage!,
              actionLabel: '重新加载',
              onPressed: () =>
                  ref.read(documentControllerProvider.notifier).refresh(),
            );
          }

          if (docs.isEmpty) {
            return const _DocumentStatePlaceholder(
              title: '还没有已保存的文档',
              subtitle: '在文档预览页保存后，会显示在这里。',
            );
          }

          final viewport = AppBreakpoints.fromWidth(constraints.maxWidth);
          final gridColumns = switch (viewport) {
            AppViewportSize.compact => 1,
            AppViewportSize.medium => 2,
            AppViewportSize.expanded => 2,
            AppViewportSize.ultra => 3,
          };
          final textScale = MediaQuery.textScalerOf(context).scale(1.0);
          final mainAxisExtentBase = viewport == AppViewportSize.compact
              ? 256.0
              : 242.0;
          final scaleDelta = (textScale - 1).clamp(0.0, 0.6).toDouble();
          final mainAxisExtent = mainAxisExtentBase + (scaleDelta * 90.0);

          return ListView(
            children: [
              SizedBox(
                height: 42,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 4,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    const labels = ['全部', '草稿', '已完成', '已归档'];
                    final selected = _tab == index;
                    return ChoiceChip(
                      label: Text(labels[index]),
                      selected: selected,
                      selectedColor: Theme.of(context).colorScheme.primary,
                      labelStyle: TextStyle(
                        color: selected
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (_) => setState(() => _tab = index),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: gridColumns,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  mainAxisExtent: mainAxisExtent,
                ),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final item = docs[index];
                  final status = switch (item.status) {
                    'completed' => (
                      '已完成',
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.onPrimary,
                    ),
                    'failed' => (
                      '失败',
                      Theme.of(context).colorScheme.error,
                      Theme.of(context).colorScheme.onError,
                    ),
                    'processing' => (
                      '处理中',
                      Theme.of(context).colorScheme.tertiary,
                      Theme.of(context).colorScheme.onTertiary,
                    ),
                    _ => (
                      '排队中',
                      Theme.of(context).colorScheme.onSurfaceVariant,
                      Theme.of(context).colorScheme.surface,
                    ),
                  };
                  return _DocumentCard(
                    item: item,
                    status: status,
                    onView: () => context.pushNamed(
                      RouteNames.savedDocumentDetail,
                      pathParameters: {
                        RouteNames.savedDocumentIdParam: item.id,
                      },
                      queryParameters: const {'mode': 'view'},
                    ),
                    onEdit: () => context.pushNamed(
                      RouteNames.savedDocumentDetail,
                      pathParameters: {
                        RouteNames.savedDocumentIdParam: item.id,
                      },
                      queryParameters: const {'mode': 'edit'},
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
            ],
          );
        },
      ),
    );
  }
}

class _DocumentStatePlaceholder extends StatelessWidget {
  const _DocumentStatePlaceholder({
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onPressed,
  });

  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: AppSurfaceCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.description_outlined,
                size: 36,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              if (actionLabel != null && onPressed != null) ...[
                const SizedBox(height: 14),
                FilledButton(onPressed: onPressed, child: Text(actionLabel!)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({
    required this.item,
    required this.status,
    this.onView,
    this.onEdit,
  });

  final DocumentItem item;
  final (String, Color, Color) status;
  final VoidCallback? onView;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: status.$2,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    status.$1,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: status.$3,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: Theme.of(context).textTheme.titleSmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.type} · 更新于 ${DateTimeUtils.relativeFromNow(item.updatedAt)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onView,
                        child: const Text('查看'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton(
                        onPressed: onEdit,
                        child: const Text('编辑'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
