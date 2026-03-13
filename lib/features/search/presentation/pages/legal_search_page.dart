import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lexcore/app/motion/app_motion_widgets.dart';
import 'package:lexcore/app/router/route_names.dart';
import 'package:lexcore/features/search/application/search_controller.dart';
import 'package:lexcore/shared/components/app_list_tile_item.dart';
import 'package:lexcore/shared/components/app_surface_card.dart';
import 'package:lexcore/shared/models/legal_models.dart';
import 'package:lexcore/shared/widgets/app_mobile_canvas.dart';
import 'package:lexcore/shared/widgets/app_shell_top_bar.dart';

class LegalSearchPage extends ConsumerStatefulWidget {
  const LegalSearchPage({super.key});

  @override
  ConsumerState<LegalSearchPage> createState() => _LegalSearchPageState();
}

class _LegalSearchPageState extends ConsumerState<LegalSearchPage> {
  int _selectedFilter = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.text = ref.read(searchControllerProvider);
    _searchController.addListener(_onQueryChanged);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onQueryChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyword = ref.watch(searchControllerProvider);
    final hotArticles = ref.watch(filteredHotSearchArticlesProvider);
    final scenarioGroups = ref.watch(searchScenarioGroupsProvider);

    const filters = ['全部', '法律法规', '裁判文书', '行政执法'];

    return Scaffold(
      key: _scaffoldKey,
      endDrawer: _SearchScenarioDrawer(
        groups: scenarioGroups,
        onScenarioSelected: _applyScenarioKeyword,
      ),
      body: AppMobileCanvas(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              AppFadeSlideIn(
                delay: const Duration(milliseconds: 20),
                beginOffset: const Offset(0, -0.02),
                child: _SearchTopBar(onScenarioTap: _openScenarioDrawer),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _SearchInputAndFilter(
                        controller: _searchController,
                        filters: filters,
                        selectedFilter: _selectedFilter,
                        onFilterChanged: (index) {
                          setState(() => _selectedFilter = index);
                        },
                      ),
                      const SizedBox(height: 20),
                      _ResultsSection(results: hotArticles, keyword: keyword),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onQueryChanged() {
    ref
        .read(searchControllerProvider.notifier)
        .updateKeyword(_searchController.text);
  }

  void _openScenarioDrawer() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  void _applyScenarioKeyword(String keyword) {
    _searchController.value = TextEditingValue(
      text: keyword,
      selection: TextSelection.collapsed(offset: keyword.length),
    );
    ref.read(searchControllerProvider.notifier).updateKeyword(keyword);
  }
}

class _SearchInputAndFilter extends StatelessWidget {
  const _SearchInputAndFilter({
    required this.controller,
    required this.filters,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  final TextEditingController controller;
  final List<String> filters;
  final int selectedFilter;
  final ValueChanged<int> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return AppFadeSlideIn(
      delay: const Duration(milliseconds: 40),
      child: Column(
        children: [
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: '搜索法律、案例、法规...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.mic_none),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(999),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: filters.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final selected = selectedFilter == index;
                return ChoiceChip(
                  label: Text(filters[index]),
                  selected: selected,
                  onSelected: (_) => onFilterChanged(index),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  selectedColor: Theme.of(context).colorScheme.primary,
                  labelStyle: TextStyle(
                    color: selected
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchScenarioDrawer extends StatelessWidget {
  const _SearchScenarioDrawer({
    required this.groups,
    required this.onScenarioSelected,
  });

  final List<SearchScenarioGroup> groups;
  final ValueChanged<String> onScenarioSelected;

  IconData _scenarioIconFor(String text) {
    if (text.contains('劳动') || text.contains('仲裁')) {
      return Icons.balance_rounded;
    }
    if (text.contains('合同') || text.contains('违约')) {
      return Icons.description_outlined;
    }
    if (text.contains('借款')) {
      return Icons.account_balance_wallet_outlined;
    }
    if (text.contains('婚姻') || text.contains('离婚') || text.contains('抚养')) {
      return Icons.family_restroom_outlined;
    }
    if (text.contains('交通')) {
      return Icons.directions_car_outlined;
    }
    if (text.contains('损害')) {
      return Icons.healing_outlined;
    }
    if (text.contains('股权') || text.contains('公司')) {
      return Icons.business_center_outlined;
    }
    if (text.contains('房屋') || text.contains('租赁') || text.contains('物业')) {
      return Icons.home_work_outlined;
    }
    return Icons.rule_folder_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      key: const ValueKey<String>('legal_search_scenario_drawer'),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '预设场景',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.close_rounded),
                    tooltip: '关闭',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(
                '选择高频法律场景，自动触发热门法条筛选。',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
                itemCount: groups.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final group = groups[index];
                  return AppSurfaceCard(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerLowest,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group.title,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: group.items
                              .map(
                                (item) => ActionChip(
                                  key: ValueKey<String>(
                                    'search_scenario_${item.id}',
                                  ),
                                  avatar: Icon(
                                    _scenarioIconFor(item.label),
                                    size: 18,
                                  ),
                                  label: Text(item.label),
                                  onPressed: () {
                                    onScenarioSelected(item.keyword);
                                    Navigator.of(context).maybePop();
                                  },
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultsSection extends StatelessWidget {
  const _ResultsSection({required this.results, required this.keyword});

  final List<LawSearchItem> results;
  final String keyword;

  @override
  Widget build(BuildContext context) {
    return AppFadeSlideIn(
      delay: const Duration(milliseconds: 140),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('热门搜索', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 10),
          if (results.isEmpty) _EmptyResultState(keyword: keyword),
          ...results.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return AppFadeSlideIn(
              delay: Duration(milliseconds: 20 + (index * 35)),
              beginOffset: const Offset(0, 0.02),
              child: AppListTileItem(
                title: item.title,
                subtitle: item.snippet,
                leadingIcon: Icons.gavel_outlined,
                subtitleMaxLines: 2,
                showBottomDivider: index != results.length - 1,
                onTap: () =>
                    context.pushNamed(RouteNames.legalArticle, extra: item),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _EmptyResultState extends StatelessWidget {
  const _EmptyResultState({required this.keyword});

  final String keyword;

  @override
  Widget build(BuildContext context) {
    final trimmedKeyword = keyword.trim();
    final message = trimmedKeyword.isEmpty
        ? '请选择场景或输入关键词开始查询。'
        : '未找到与“$trimmedKeyword”相关的法条，请更换场景。';

    return AppSurfaceCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 30,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 8),
          Text('暂无匹配法条', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchTopBar extends StatelessWidget {
  const _SearchTopBar({required this.onScenarioTap});

  final VoidCallback onScenarioTap;

  @override
  Widget build(BuildContext context) {
    return AppShellTopBar(
      title: 'LexCore 法条检索',
      actions: [
        IconButton(
          key: const ValueKey<String>('legal_search_scenario_button'),
          onPressed: onScenarioTap,
          icon: const Icon(Icons.tune_rounded),
          tooltip: '预设场景',
        ),
      ],
    );
  }
}
