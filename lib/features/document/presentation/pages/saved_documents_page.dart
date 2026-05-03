import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lexcore/app/adaptive/app_breakpoints.dart';
import 'package:lexcore/app/router/route_names.dart';
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
  bool _searchExpanded = false;
  final TextEditingController _searchController = TextEditingController();
  String _keyword = '';
  _SortMode _sortMode = _SortMode.updatedAtDesc;

  static const List<String> _tabLabels = ['全部', '已完成'];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_handleSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_handleSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearchChanged() {
    final next = _searchController.text.trim();
    if (next == _keyword) {
      return;
    }
    setState(() {
      _keyword = next;
    });
  }

  void _toggleSearch() {
    setState(() {
      _searchExpanded = !_searchExpanded;
      if (!_searchExpanded) {
        _searchController.clear();
        _keyword = '';
      }
    });
  }

  void _resetFilters() {
    setState(() {
      _tab = 0;
      _searchController.clear();
      _keyword = '';
      _searchExpanded = false;
    });
  }

  List<DocumentItem> _filterByTab(List<DocumentItem> docs) {
    if (_tab == 0) {
      return docs;
    }
    return docs.where((item) => item.status == 'completed').toList();
  }

  List<DocumentItem> _filterByKeyword(List<DocumentItem> docs) {
    if (_keyword.isEmpty) {
      return docs;
    }
    final keyword = _keyword.toLowerCase();
    return docs.where((item) {
      final name = item.name.toLowerCase();
      final type = item.type.toLowerCase();
      return name.contains(keyword) || type.contains(keyword);
    }).toList();
  }

  List<DocumentItem> _applySort(List<DocumentItem> docs) {
    final sorted = [...docs];
    switch (_sortMode) {
      case _SortMode.updatedAtDesc:
        sorted.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
      case _SortMode.updatedAtAsc:
        sorted.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
        break;
      case _SortMode.nameAsc:
        sorted.sort((a, b) => a.name.compareTo(b.name));
        break;
      case _SortMode.nameDesc:
        sorted.sort((a, b) => b.name.compareTo(a.name));
        break;
    }
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final documentState = ref.watch(documentControllerProvider);
    final docs = ref.watch(savedDocumentsProvider);
    final onRefresh = ref.read(documentControllerProvider.notifier).refresh;

    return AppPageScaffold(
      title: '已保存的文档',
      actions: [
        IconButton(
          onPressed: _toggleSearch,
          tooltip: _searchExpanded ? '收起搜索' : '搜索文档',
          icon: Icon(_searchExpanded ? Icons.search_off : Icons.search),
        ),
        PopupMenuButton<_MoreAction>(
          tooltip: '更多操作',
          icon: const Icon(Icons.more_vert_rounded),
          onSelected: (action) => _handleMoreAction(action, onRefresh),
          itemBuilder: (context) => [
            const PopupMenuItem<_MoreAction>(
              value: _MoreAction.refresh,
              child: ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.refresh),
                title: Text('刷新列表'),
              ),
            ),
            const PopupMenuDivider(),
            _buildSortMenuItem(
              context,
              action: _MoreAction.sortUpdatedDesc,
              label: '按更新时间（最新优先）',
              isSelected: _sortMode == _SortMode.updatedAtDesc,
            ),
            _buildSortMenuItem(
              context,
              action: _MoreAction.sortUpdatedAsc,
              label: '按更新时间（最早优先）',
              isSelected: _sortMode == _SortMode.updatedAtAsc,
            ),
            _buildSortMenuItem(
              context,
              action: _MoreAction.sortNameAsc,
              label: '按名称（A → Z）',
              isSelected: _sortMode == _SortMode.nameAsc,
            ),
            _buildSortMenuItem(
              context,
              action: _MoreAction.sortNameDesc,
              label: '按名称（Z → A）',
              isSelected: _sortMode == _SortMode.nameDesc,
            ),
          ],
        ),
      ],
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (documentState.loading && docs.isEmpty) {
            return RefreshIndicator(
              onRefresh: onRefresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 240),
                  Center(child: CircularProgressIndicator()),
                ],
              ),
            );
          }

          if (documentState.errorMessage != null && docs.isEmpty) {
            return RefreshIndicator(
              onRefresh: onRefresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 80),
                  _DocumentStatePlaceholder(
                    title: '文档加载失败',
                    subtitle: documentState.errorMessage!,
                    actionLabel: '重新加载',
                    onPressed: onRefresh,
                  ),
                ],
              ),
            );
          }

          if (docs.isEmpty) {
            return RefreshIndicator(
              onRefresh: onRefresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 80),
                  _DocumentStatePlaceholder(
                    title: '还没有已保存的文档',
                    subtitle: '前往文书生成页生成你的第一份法律文书。',
                    actionLabel: '去生成文书',
                    onPressed: () =>
                        context.pushNamed(RouteNames.documentGenerate),
                  ),
                ],
              ),
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

          final displayDocs = _applySort(_filterByKeyword(_filterByTab(docs)));

          return RefreshIndicator(
            onRefresh: onRefresh,
            child: ListView(
              children: [
                if (_searchExpanded)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: SearchBar(
                      controller: _searchController,
                      hintText: '搜索文档标题或类型',
                      leading: const Padding(
                        padding: EdgeInsets.only(left: 4),
                        child: Icon(Icons.search),
                      ),
                      trailing: [
                        if (_keyword.isNotEmpty)
                          IconButton(
                            tooltip: '清空',
                            icon: const Icon(Icons.close),
                            onPressed: () => _searchController.clear(),
                          ),
                      ],
                    ),
                  ),
                SizedBox(
                  height: 42,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _tabLabels.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final selected = _tab == index;
                      return ChoiceChip(
                        label: Text(_tabLabels[index]),
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
                if (displayDocs.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: _DocumentStatePlaceholder(
                      title: '未找到匹配的文档',
                      subtitle: '尝试调整筛选条件或清除关键字。',
                      actionLabel: '清除筛选',
                      onPressed: _resetFilters,
                    ),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: gridColumns,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      mainAxisExtent: mainAxisExtent,
                    ),
                    itemCount: displayDocs.length,
                    itemBuilder: (context, index) {
                      final item = displayDocs[index];
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
            ),
          );
        },
      ),
    );
  }

  PopupMenuItem<_MoreAction> _buildSortMenuItem(
    BuildContext context, {
    required _MoreAction action,
    required String label,
    required bool isSelected,
  }) {
    return PopupMenuItem<_MoreAction>(
      value: action,
      child: ListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        leading: Icon(
          isSelected ? Icons.check : Icons.sort,
          color: isSelected ? Theme.of(context).colorScheme.primary : null,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isSelected ? Theme.of(context).colorScheme.primary : null,
            fontWeight: isSelected ? FontWeight.w600 : null,
          ),
        ),
      ),
    );
  }

  Future<void> _handleMoreAction(
    _MoreAction action,
    Future<void> Function() onRefresh,
  ) async {
    switch (action) {
      case _MoreAction.refresh:
        await onRefresh();
        break;
      case _MoreAction.sortUpdatedDesc:
        setState(() => _sortMode = _SortMode.updatedAtDesc);
        break;
      case _MoreAction.sortUpdatedAsc:
        setState(() => _sortMode = _SortMode.updatedAtAsc);
        break;
      case _MoreAction.sortNameAsc:
        setState(() => _sortMode = _SortMode.nameAsc);
        break;
      case _MoreAction.sortNameDesc:
        setState(() => _sortMode = _SortMode.nameDesc);
        break;
    }
  }
}

enum _SortMode { updatedAtDesc, updatedAtAsc, nameAsc, nameDesc }

enum _MoreAction {
  refresh,
  sortUpdatedDesc,
  sortUpdatedAsc,
  sortNameAsc,
  sortNameDesc,
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
