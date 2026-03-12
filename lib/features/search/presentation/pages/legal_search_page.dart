import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lexcore/app/adaptive/app_breakpoints.dart';
import 'package:lexcore/app/motion/app_motion_widgets.dart';
import 'package:lexcore/app/router/route_names.dart';
import 'package:lexcore/features/search/application/search_controller.dart';
import 'package:lexcore/shared/components/app_list_tile_item.dart';
import 'package:lexcore/shared/components/app_surface_card.dart';
import 'package:lexcore/shared/models/legal_models.dart';
import 'package:lexcore/shared/widgets/app_mobile_canvas.dart';

class LegalSearchPage extends ConsumerStatefulWidget {
  const LegalSearchPage({super.key});

  @override
  ConsumerState<LegalSearchPage> createState() => _LegalSearchPageState();
}

class _LegalSearchPageState extends ConsumerState<LegalSearchPage> {
  int _selectedFilter = 0;

  @override
  Widget build(BuildContext context) {
    final keyword = ref.watch(searchControllerProvider);
    final hotKeywords = ref.watch(hotKeywordsProvider);
    final results = ref.watch(searchResultsProvider);

    const filters = ['全部', '法律法规', '裁判文书', '行政执法'];

    return Scaffold(
      body: AppMobileCanvas(
        child: SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final viewport = AppBreakpoints.fromWidth(constraints.maxWidth);
              final useSplitLayout =
                  viewport == AppViewportSize.expanded ||
                  viewport == AppViewportSize.ultra;

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 4, 10, 6),
                    child: const AppFadeSlideIn(
                      delay: Duration(milliseconds: 20),
                      beginOffset: Offset(0, -0.02),
                      child: _SearchTopBar(),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                      child: useSplitLayout
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 7,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      _SearchInputAndFilter(
                                        filters: filters,
                                        selectedFilter: _selectedFilter,
                                        onFilterChanged: (index) {
                                          setState(
                                            () => _selectedFilter = index,
                                          );
                                        },
                                        onKeywordChanged: (value) => ref
                                            .read(
                                              searchControllerProvider.notifier,
                                            )
                                            .updateKeyword(value),
                                      ),
                                      const SizedBox(height: 18),
                                      _ResultsSection(
                                        keyword: keyword,
                                        results: results,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 4,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      _TopicsSection(
                                        hotKeywords: hotKeywords,
                                        onKeywordPressed: (word) => ref
                                            .read(
                                              searchControllerProvider.notifier,
                                            )
                                            .updateKeyword(word),
                                      ),
                                      const SizedBox(height: 16),
                                      const _AssistantCard(),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _SearchInputAndFilter(
                                  filters: filters,
                                  selectedFilter: _selectedFilter,
                                  onFilterChanged: (index) {
                                    setState(() => _selectedFilter = index);
                                  },
                                  onKeywordChanged: (value) => ref
                                      .read(searchControllerProvider.notifier)
                                      .updateKeyword(value),
                                ),
                                const SizedBox(height: 18),
                                _TopicsSection(
                                  hotKeywords: hotKeywords,
                                  onKeywordPressed: (word) => ref
                                      .read(searchControllerProvider.notifier)
                                      .updateKeyword(word),
                                ),
                                const SizedBox(height: 20),
                                _ResultsSection(
                                  keyword: keyword,
                                  results: results,
                                ),
                                const SizedBox(height: 16),
                                const _AssistantCard(),
                              ],
                            ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SearchInputAndFilter extends StatelessWidget {
  const _SearchInputAndFilter({
    required this.filters,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.onKeywordChanged,
  });

  final List<String> filters;
  final int selectedFilter;
  final ValueChanged<int> onFilterChanged;
  final ValueChanged<String> onKeywordChanged;

  @override
  Widget build(BuildContext context) {
    return AppFadeSlideIn(
      delay: const Duration(milliseconds: 40),
      child: Column(
        children: [
          TextField(
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
            onChanged: onKeywordChanged,
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

class _TopicsSection extends StatelessWidget {
  const _TopicsSection({
    required this.hotKeywords,
    required this.onKeywordPressed,
  });

  final List<String> hotKeywords;
  final ValueChanged<String> onKeywordPressed;

  @override
  Widget build(BuildContext context) {
    return AppFadeSlideIn(
      delay: const Duration(milliseconds: 90),
      child: SizedBox(
        width: double.infinity,
        child: AppSurfaceCard(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '推荐话题',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '从高频法律场景快速进入，避免空白搜索。',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                alignment: WrapAlignment.start,
                spacing: 10,
                runSpacing: 10,
                children: hotKeywords
                    .map(
                      (word) => _TopicPill(
                        label: word,
                        onPressed: () => onKeywordPressed(word),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopicPill extends StatelessWidget {
  const _TopicPill({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onPressed,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.primaryContainer.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.14),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultsSection extends StatelessWidget {
  const _ResultsSection({required this.keyword, required this.results});

  final String keyword;
  final List<LawSearchItem> results;

  @override
  Widget build(BuildContext context) {
    final isDefaultRecommendations = keyword.isEmpty;
    final itemSpacing = isDefaultRecommendations ? 12.0 : 8.0;

    return AppFadeSlideIn(
      delay: const Duration(milliseconds: 140),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '搜索结果 ${isDefaultRecommendations ? '(默认推荐)' : '(关键词: $keyword)'}',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const Spacer(),
              TextButton(onPressed: () {}, child: const Text('清除记录')),
            ],
          ),
          SizedBox(height: isDefaultRecommendations ? 10 : 6),
          ...results.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return AppFadeSlideIn(
              delay: Duration(milliseconds: 20 + (index * 35)),
              beginOffset: const Offset(0, 0.02),
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: index == results.length - 1 ? 0 : itemSpacing,
                ),
                child: AppListTileItem(
                  title: item.title,
                  subtitle: item.snippet,
                  leading: const Icon(Icons.gavel_outlined),
                  onTap: () =>
                      context.pushNamed(RouteNames.legalArticle, extra: item),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _AssistantCard extends StatelessWidget {
  const _AssistantCard();

  @override
  Widget build(BuildContext context) {
    return AppFadeSlideIn(
      delay: const Duration(milliseconds: 200),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'LexiAI 智能助理',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '通过自然语言对话，获取精准法律建议与文书模板。',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onPrimary.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 10),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerLowest,
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () => context.push(RouteNames.consultationPath),
              child: const Text('开始对话'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchTopBar extends StatelessWidget {
  const _SearchTopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.menu)),
        Expanded(
          child: Text(
            'LexiAI 法律搜索',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.account_circle_outlined),
        ),
      ],
    );
  }
}
