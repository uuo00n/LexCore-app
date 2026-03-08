import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lexcore/app/theme/app_colors.dart';
import 'package:lexcore/core/utils/date_time_utils.dart';
import 'package:lexcore/features/document/application/document_providers.dart';
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
      body: ListView(
        children: [
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                const labels = ['全部', '草稿', '已完成', '已归档'];
                final selected = _tab == index;
                return ChoiceChip(
                  label: Text(labels[index]),
                  selected: selected,
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : AppColors.onSurfaceVariant,
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
          ...List.generate(docs.length, (index) {
            final item = docs[index];
            final status = switch (index % 3) {
              0 => ('已完成', AppColors.primary),
              1 => ('草稿', Colors.orange),
              _ => ('已归档', AppColors.onSurfaceVariant),
            };
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).dividerColor.withValues(alpha: 0.7),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withValues(alpha: 0.1),
                              AppColors.primary.withValues(alpha: 0.2),
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
                                style: Theme.of(context).textTheme.labelMedium
                                    ?.copyWith(
                                      color: Colors.white,
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
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${item.type} · 更新于 ${DateTimeUtils.relativeFromNow(item.updatedAt)}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.onSurfaceVariant),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                OutlinedButton(
                                  onPressed: () {},
                                  child: const Text('查看'),
                                ),
                                const SizedBox(width: 8),
                                FilledButton(
                                  onPressed: () {},
                                  child: const Text('编辑'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
