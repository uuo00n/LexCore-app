import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lexcore/app/adaptive/app_breakpoints.dart';
import 'package:lexcore/app/motion/app_motion_widgets.dart';
import 'package:lexcore/core/utils/date_time_utils.dart';
import 'package:lexcore/features/home/application/home_providers.dart';
import 'package:lexcore/features/home/domain/entities/home_entity.dart';
import 'package:lexcore/shared/components/app_list_tile_item.dart';
import 'package:lexcore/shared/components/app_surface_card.dart';
import 'package:lexcore/shared/widgets/app_mobile_canvas.dart';
import 'package:lexcore/shared/widgets/app_shell_top_bar.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeData = ref.watch(homeDataProvider);

    return Scaffold(
      body: AppMobileCanvas(
        child: SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final viewport = AppBreakpoints.fromWidth(constraints.maxWidth);
              final gridColumnCount = switch (viewport) {
                AppViewportSize.compact => 2,
                AppViewportSize.medium => 3,
                AppViewportSize.expanded => 3,
                AppViewportSize.ultra => 4,
              };
              final useSplitLayout =
                  viewport == AppViewportSize.expanded ||
                  viewport == AppViewportSize.ultra;

              return Column(
                children: [
                  const AppFadeSlideIn(
                    delay: Duration(milliseconds: 20),
                    beginOffset: Offset(0, -0.02),
                    child: _HomeTopBar(),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      child: useSplitLayout
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 7,
                                  child: _CoreSection(
                                    gridColumnCount: gridColumnCount,
                                    homeData: homeData,
                                    iconFrom: _iconFrom,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 4,
                                  child: _RecentActivitySection(
                                    homeData: homeData,
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: AppStagger.sections([
                                _CoreSection(
                                  gridColumnCount: gridColumnCount,
                                  homeData: homeData,
                                  iconFrom: _iconFrom,
                                ),
                                _RecentActivitySection(homeData: homeData),
                              ]),
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

  IconData _iconFrom(String icon) {
    switch (icon) {
      case 'chat_bubble':
        return Icons.chat_bubble_outline;
      case 'description':
        return Icons.description_outlined;
      case 'analytics':
        return Icons.analytics_outlined;
      case 'gavel':
        return Icons.gavel_outlined;
      default:
        return Icons.apps;
    }
  }
}

class _CoreSection extends StatelessWidget {
  const _CoreSection({
    required this.gridColumnCount,
    required this.homeData,
    required this.iconFrom,
  });

  final int gridColumnCount;
  final HomeEntity homeData;
  final IconData Function(String) iconFrom;

  @override
  Widget build(BuildContext context) {
    return AppFadeSlideIn(
      delay: const Duration(milliseconds: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '您好, 法律专家',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '今天想处理什么法律事务？',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            '核心服务',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: homeData.actions.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: gridColumnCount,
              childAspectRatio: gridColumnCount > 3 ? 1.1 : 1.2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              final action = homeData.actions[index];
              final highlighted = index == 0;
              final iconColor = highlighted
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurfaceVariant;

              return AppSurfaceCard(
                backgroundColor: highlighted
                    ? Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.95)
                    : Theme.of(context).colorScheme.surfaceContainerLowest,
                onTap: () => context.push(action.route),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: highlighted
                            ? Theme.of(
                                context,
                              ).colorScheme.onPrimary.withValues(alpha: 0.24)
                            : Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(iconFrom(action.icon), color: iconColor),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      action.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: highlighted
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      action.subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: highlighted
                            ? Theme.of(
                                context,
                              ).colorScheme.onPrimary.withValues(alpha: 0.86)
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _RecentActivitySection extends StatelessWidget {
  const _RecentActivitySection({required this.homeData});

  final HomeEntity homeData;

  IconData _iconFromTag(String tag) {
    switch (tag) {
      case '文档':
        return Icons.article_outlined;
      case '分析':
        return Icons.analytics_outlined;
      case '咨询':
      default:
        return Icons.history;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppFadeSlideIn(
      delay: const Duration(milliseconds: 90),
      child: Column(
        children: [
          Row(
            children: [
              Text('最近活动', style: Theme.of(context).textTheme.titleSmall),
              const Spacer(),
              TextButton(onPressed: () {}, child: const Text('查看全部')),
            ],
          ),
          const SizedBox(height: 6),
          Column(
            key: const ValueKey('home_recent_activity_list'),
            children: List<Widget>.generate(homeData.activities.length, (
              index,
            ) {
              final item = homeData.activities[index];
              final isLast = index == homeData.activities.length - 1;
              return AppListTileItem(
                key: ValueKey<String>('home_recent_activity_item_$index'),
                title: item.title,
                subtitle:
                    '${DateTimeUtils.relativeFromNow(item.time)} • ${item.tag}',
                subtitleKey: ValueKey<String>(
                  'home_recent_activity_subtitle_$index',
                ),
                leadingIcon: _iconFromTag(item.tag),
                showBottomDivider: !isLast,
                onTap: () {},
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _HomeTopBar extends StatelessWidget {
  const _HomeTopBar();

  @override
  Widget build(BuildContext context) {
    return AppShellTopBar(
      title: 'LexiAI',
      sideWidth: 96,
      actions: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.search_rounded)),
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.16),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Icon(
            Icons.person,
            size: 18,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
