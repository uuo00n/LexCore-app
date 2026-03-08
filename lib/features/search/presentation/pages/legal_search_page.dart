import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lexcore/app/motion/app_motion_widgets.dart';
import 'package:lexcore/app/router/route_names.dart';
import 'package:lexcore/app/theme/app_colors.dart';
import 'package:lexcore/features/search/application/search_controller.dart';
import 'package:lexcore/shared/components/app_list_tile_item.dart';
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
          child: Column(
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
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  children: [
                    AppFadeSlideIn(
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
                            onChanged: (value) => ref
                                .read(searchControllerProvider.notifier)
                                .updateKeyword(value),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 36,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: filters.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(width: 8),
                              itemBuilder: (context, index) {
                                final selected = _selectedFilter == index;
                                return ChoiceChip(
                                  label: Text(filters[index]),
                                  selected: selected,
                                  onSelected: (_) =>
                                      setState(() => _selectedFilter = index),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  selectedColor: AppColors.primary,
                                  labelStyle: TextStyle(
                                    color: selected
                                        ? Colors.white
                                        : AppColors.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    AppFadeSlideIn(
                      delay: const Duration(milliseconds: 90),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '推荐话题',
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(color: AppColors.onSurfaceVariant),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: hotKeywords
                                .map(
                                  (word) => ActionChip(
                                    label: Text(word),
                                    backgroundColor: AppColors.primary
                                        .withValues(alpha: 0.12),
                                    side: BorderSide(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.18,
                                      ),
                                    ),
                                    labelStyle: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    onPressed: () => ref
                                        .read(searchControllerProvider.notifier)
                                        .updateKeyword(word),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    AppFadeSlideIn(
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
                              TextButton(
                                onPressed: () {},
                                child: const Text('清除记录'),
                              ),
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
                                onTap: () =>
                                    context.push(RouteNames.legalArticlePath),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppFadeSlideIn(
                      delay: const Duration(milliseconds: 200),
                      child: Container(
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
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(color: Colors.white),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '通过自然语言对话，获取精准法律建议与文书模板。',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                            ),
                            const SizedBox(height: 10),
                            FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppColors.primary,
                              ),
                              onPressed: () =>
                                  context.push(RouteNames.consultationPath),
                              child: const Text('开始对话'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
