import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lexcore/app/adaptive/app_breakpoints.dart';
import 'package:lexcore/core/utils/date_time_utils.dart';
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
    final docs = ref.watch(savedDocumentsProvider);

    return AppPageScaffold(
      title: '已保存的文档',
      actions: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
        IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
      ],
      body: LayoutBuilder(
        builder: (context, constraints) {
          final viewport = AppBreakpoints.fromWidth(constraints.maxWidth);
          final gridColumns = switch (viewport) {
            AppViewportSize.compact => 1,
            AppViewportSize.medium => 2,
            AppViewportSize.expanded => 2,
            AppViewportSize.ultra => 3,
          };

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
                  childAspectRatio: gridColumns == 1 ? 1.45 : 1.25,
                ),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final item = docs[index];
                  final status = switch (index % 3) {
                    0 => (
                      '已完成',
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.onPrimary,
                    ),
                    1 => (
                      '草稿',
                      Theme.of(context).colorScheme.tertiary,
                      Theme.of(context).colorScheme.onTertiary,
                    ),
                    _ => (
                      '已归档',
                      Theme.of(context).colorScheme.onSurfaceVariant,
                      Theme.of(context).colorScheme.surface,
                    ),
                  };
                  return _DocumentCard(item: item, status: status);
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

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({required this.item, required this.status});

  final DocumentItem item;
  final (String, Color, Color) status;

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
                Text(item.name, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(
                  '${item.type} · 更新于 ${DateTimeUtils.relativeFromNow(item.updatedAt)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    OutlinedButton(onPressed: () {}, child: const Text('查看')),
                    const SizedBox(width: 8),
                    FilledButton(onPressed: () {}, child: const Text('编辑')),
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
