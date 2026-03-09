import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lexcore/app/adaptive/app_breakpoints.dart';
import 'package:lexcore/app/motion/app_motion_widgets.dart';
import 'package:lexcore/app/router/route_names.dart';
import 'package:lexcore/app/theme/app_colors.dart';
import 'package:lexcore/features/search/application/search_controller.dart';
import 'package:lexcore/shared/components/app_list_tile_item.dart';
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
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : AppColors.onSurfaceVariant,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '推荐话题',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: hotKeywords
                .map(
                  (word) => ActionChip(
                    label: Text(word),
                    backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                    side: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.18),
                    ),
                    labelStyle: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                    onPressed: () => onKeywordPressed(word),
                  ),
                )
                .toList(),
          ),
        ],
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
    return AppFadeSlideIn(
      delay: const Duration(milliseconds: 140),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                '搜索结果 ${keyword.isEmpty ? '(默认推荐)' : '(关键词: $keyword)'}',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const Spacer(),
              TextButton(onPressed: () {}, child: const Text('清除记录')),
            ],
          ),
          const SizedBox(height: 4),
          ...results.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return AppFadeSlideIn(
              delay: Duration(milliseconds: 20 + (index * 35)),
              beginOffset: const Offset(0, 0.02),
              child: AppListTileItem(
                title: item.title,
                subtitle: item.snippet,
                leading: const Icon(Icons.gavel_outlined),
                onTap: () => context.push(RouteNames.legalArticlePath),
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
          gradient: const LinearGradient(
            colors: [Color(0xFF0B50DA), Color(0xFF1D3DBA)],
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
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 6),
            Text(
              '通过自然语言对话，获取精准法律建议与文书模板。',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 10),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
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
