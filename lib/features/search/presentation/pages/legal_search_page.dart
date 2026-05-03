import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import 'package:lexcore/app/motion/app_motion_widgets.dart';
import 'package:lexcore/app/router/route_names.dart';
import 'package:lexcore/core/utils/feature_notice.dart';
import 'package:lexcore/features/cases/presentation/pages/case_detail_page.dart';
import 'package:lexcore/features/search/application/search_controller.dart';
import 'package:lexcore/shared/components/app_list_tile_item.dart';
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
  final ScrollController _resultsScrollController = ScrollController();
  String? _selectedScenarioId;
  bool _isApplyingScenarioSelection = false;
  bool _showBackToTopButton = false;

  @override
  void initState() {
    super.initState();
    _searchController.text = ref.read(searchControllerProvider);
    ref.read(searchFilterProvider.notifier).state = _selectedFilter;
    _searchController.addListener(_onQueryChanged);
    _resultsScrollController.addListener(_handleResultsScroll);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onQueryChanged)
      ..dispose();
    _resultsScrollController
      ..removeListener(_handleResultsScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyword = ref.watch(searchControllerProvider);
    final hotArticles = ref.watch(filteredHotSearchArticlesProvider);
    final searchNoticeAsync = ref.watch(searchNoticeProvider);
    final scenarioGroups = ref.watch(searchScenarioGroupsProvider);
    final filters = ref.watch(searchFilterLabelsProvider);
    final searchNotice = searchNoticeAsync.asData?.value;

    return Scaffold(
      key: _scaffoldKey,
      endDrawer: _SearchScenarioDrawer(
        groups: scenarioGroups,
        selectedScenarioId: _selectedScenarioId,
        onScenarioSelected: _applyScenarioKeyword,
        onResetSelection: _resetScenarioSelection,
      ),
      floatingActionButton: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: _showBackToTopButton
            ? FloatingActionButton(
                key: const ValueKey<String>('legal_search_back_to_top_button'),
                onPressed: _scrollToTop,
                tooltip: '返回顶部',
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.keyboard_arrow_up_rounded),
              )
            : const SizedBox.shrink(
                key: ValueKey<String>('legal_search_back_to_top_button_hidden'),
              ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: _SearchInputAndFilter(
                  controller: _searchController,
                  filters: filters,
                  selectedFilter: _selectedFilter,
                  onFilterChanged: (index) {
                    setState(() => _selectedFilter = index);
                    ref.read(searchFilterProvider.notifier).state = index;
                  },
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  key: const ValueKey<String>(
                    'legal_search_results_scroll_view',
                  ),
                  controller: _resultsScrollController,
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (searchNotice != null &&
                          searchNotice.trim().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _SearchNoticeBanner(message: searchNotice),
                        ),
                      hotArticles.when(
                        loading: () => const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (error, stackTrace) =>
                            _EmptyResultState(keyword: keyword),
                        data: (results) => _ResultsSection(
                          results: results,
                          keyword: keyword,
                          hasScenarioSelected: _selectedScenarioId != null,
                        ),
                      ),
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
    if (_isApplyingScenarioSelection) {
      _isApplyingScenarioSelection = false;
    } else if (_selectedScenarioId != null) {
      setState(() {
        _selectedScenarioId = null;
      });
    }
    ref
        .read(searchControllerProvider.notifier)
        .updateKeyword(_searchController.text);
  }

  void _openScenarioDrawer() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  void _applyScenarioKeyword({
    required String scenarioId,
    required String keyword,
  }) {
    setState(() {
      _selectedScenarioId = scenarioId;
    });
    _isApplyingScenarioSelection = true;
    _searchController.value = TextEditingValue(
      text: keyword,
      selection: TextSelection.collapsed(offset: keyword.length),
    );
    ref.read(searchControllerProvider.notifier).updateKeyword(keyword);
  }

  void _resetScenarioSelection() {
    setState(() {
      _selectedScenarioId = null;
    });
    _isApplyingScenarioSelection = true;
    _searchController.clear();
    ref.read(searchControllerProvider.notifier).updateKeyword('');
  }

  void _handleResultsScroll() {
    if (!_resultsScrollController.hasClients || !mounted) {
      return;
    }
    final viewportHeight = _resultsScrollController.position.viewportDimension;
    final shouldShow = _resultsScrollController.offset >= viewportHeight;
    if (shouldShow == _showBackToTopButton) {
      return;
    }
    setState(() {
      _showBackToTopButton = shouldShow;
    });
  }

  Future<void> _scrollToTop() async {
    if (!_resultsScrollController.hasClients) {
      return;
    }
    await _resultsScrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
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
                onPressed: () => showFeatureInProgressSnackBar(
                  context,
                  featureLabel: '语音检索',
                ),
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

class _SearchScenarioDrawer extends StatefulWidget {
  const _SearchScenarioDrawer({
    required this.groups,
    required this.selectedScenarioId,
    required this.onScenarioSelected,
    required this.onResetSelection,
  });

  final List<SearchScenarioGroup> groups;
  final String? selectedScenarioId;
  final void Function({required String scenarioId, required String keyword})
  onScenarioSelected;
  final VoidCallback onResetSelection;

  @override
  State<_SearchScenarioDrawer> createState() => _SearchScenarioDrawerState();
}

class _SearchScenarioDrawerState extends State<_SearchScenarioDrawer> {
  int _selectedGroupIndex = 0;

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
    if (widget.groups.isEmpty) {
      return Drawer(
        key: const ValueKey<String>('legal_search_scenario_drawer'),
        child: SafeArea(
          child: Center(
            child: Text(
              '暂无场景配置',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      );
    }

    final maxIndex = widget.groups.length - 1;
    final currentIndex = _selectedGroupIndex > maxIndex
        ? maxIndex
        : _selectedGroupIndex;
    final activeGroup = widget.groups[currentIndex];
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final selectedPaneBackgroundColor = colorScheme.surfaceContainerLowest;

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
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '选择高频法律场景，自动触发热门法条筛选。',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    key: const ValueKey<String>('search_scenario_reset_button'),
                    onPressed: () {
                      widget.onResetSelection();
                      setState(() {
                        _selectedGroupIndex = 0;
                      });
                    },
                    icon: const Icon(Icons.restart_alt_rounded, size: 16),
                    label: const Text('重置'),
                    style: TextButton.styleFrom(
                      foregroundColor: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: Row(
                children: [
                  SizedBox(
                    width: 112,
                    child: TDSideBar(
                      value: currentIndex,
                      height: MediaQuery.of(context).size.height,
                      style: TDSideBarStyle.normal,
                      selectedColor: colorScheme.primary,
                      unSelectedColor: colorScheme.onSurfaceVariant,
                      selectedBgColor: selectedPaneBackgroundColor,
                      unSelectedBgColor: colorScheme.surfaceContainerLow,
                      selectedTextStyle: textTheme.labelLarge?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                      onChanged: _handleGroupChanged,
                      onSelected: _handleGroupChanged,
                      children: List<TDSideBarItem>.generate(
                        widget.groups.length,
                        (index) => TDSideBarItem(
                          value: index,
                          label: widget.groups[index].title,
                        ),
                      ),
                    ),
                  ),
                  VerticalDivider(width: 1, color: colorScheme.outlineVariant),
                  Expanded(
                    child: ColoredBox(
                      key: const ValueKey<String>('search_scenario_chip_pane'),
                      color: selectedPaneBackgroundColor,
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
                        itemCount: activeGroup.items.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final item = activeGroup.items[index];
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: FilterChip(
                              key: ValueKey<String>(
                                'search_scenario_${item.id}',
                              ),
                              selected: widget.selectedScenarioId == item.id,
                              showCheckmark: true,
                              checkmarkColor: colorScheme.primary,
                              avatar: Icon(
                                _scenarioIconFor(item.label),
                                size: 18,
                                color: widget.selectedScenarioId == item.id
                                    ? colorScheme.primary
                                    : colorScheme.onSurfaceVariant,
                              ),
                              label: Text(item.label),
                              labelStyle: textTheme.labelLarge?.copyWith(
                                color: widget.selectedScenarioId == item.id
                                    ? colorScheme.primary
                                    : colorScheme.onSurface,
                                fontWeight: widget.selectedScenarioId == item.id
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                              ),
                              backgroundColor: colorScheme.surfaceContainerHigh,
                              selectedColor: colorScheme.primaryContainer
                                  .withValues(alpha: 0.48),
                              side: BorderSide(
                                color: colorScheme.outline.withValues(
                                  alpha: 0.26,
                                ),
                              ),
                              onSelected: (_) {
                                widget.onScenarioSelected(
                                  scenarioId: item.id,
                                  keyword: item.keyword,
                                );
                                Navigator.of(context).maybePop();
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleGroupChanged(int index) {
    if (index < 0 || index >= widget.groups.length) {
      return;
    }
    setState(() {
      _selectedGroupIndex = index;
    });
  }
}

class _SearchNoticeBanner extends StatelessWidget {
  const _SearchNoticeBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.tertiaryContainer.withValues(alpha: 0.56),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: colorScheme.onTertiaryContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onTertiaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultsSection extends StatelessWidget {
  const _ResultsSection({
    required this.results,
    required this.keyword,
    required this.hasScenarioSelected,
  });

  final List<LawSearchItem> results;
  final String keyword;
  final bool hasScenarioSelected;

  @override
  Widget build(BuildContext context) {
    final isSearchMode = keyword.trim().isNotEmpty || hasScenarioSelected;

    return AppFadeSlideIn(
      delay: const Duration(milliseconds: 140),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isSearchMode ? '搜索结果' : '热门搜索',
            style: Theme.of(context).textTheme.titleSmall,
          ),
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
                onTap: () => _openResultDetail(context, item),
              ),
            );
          }),
        ],
      ),
    );
  }

  void _openResultDetail(BuildContext context, LawSearchItem item) {
    if (item.resultType == SearchResultType.caseDoc) {
      context.pushNamed(
        RouteNames.caseDetail,
        extra: _buildCaseDetailData(item),
      );
      return;
    }
    context.pushNamed(RouteNames.legalArticle, extra: item);
  }

  CaseDetailData _buildCaseDetailData(LawSearchItem item) {
    final resolvedCaseNumber = item.articleCode.trim().isNotEmpty
        ? item.articleCode.trim()
        : '待补充';
    final resolvedDate = item.judgementDate?.trim();
    final resolvedCourt = item.courtName?.trim();
    final resolvedCaseType = item.caseType?.trim();
    final summarySegments = [
      if (resolvedCourt != null && resolvedCourt.isNotEmpty)
        '法院：$resolvedCourt',
      if (resolvedDate != null && resolvedDate.isNotEmpty) '裁判日期：$resolvedDate',
      if (resolvedCaseType != null && resolvedCaseType.isNotEmpty)
        '案件类型：$resolvedCaseType',
      if (item.snippet.trim().isNotEmpty) item.snippet.trim(),
      '来自裁判文书检索（列表详情）',
    ];

    return CaseDetailData(
      status: CaseDetailStatus.waiting,
      statusLabel: '检索结果',
      lastUpdatedLabel: '来自裁判文书检索',
      title: item.title,
      caseNumber: resolvedCaseNumber,
      dateLabel: '裁判日期',
      dateValue: resolvedDate == null || resolvedDate.isEmpty
          ? '待补充'
          : resolvedDate,
      progress: 0,
      progressLabel: '详情待补充',
      activeStepIndex: 0,
      progressSteps: const ['检索结果', '详情待补充'],
      summary: summarySegments.join('\n'),
      plaintiffName: '待补充',
      plaintiffCounsel: '待补充',
      defendantName: '待补充',
      defendantCounsel: '待补充',
      documents: const [],
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 220),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 30,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text('暂无匹配法条', style: textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
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
