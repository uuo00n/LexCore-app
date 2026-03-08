import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lexcore/app/motion/app_motion_widgets.dart';
import 'package:lexcore/app/theme/app_colors.dart';
import 'package:lexcore/core/utils/date_time_utils.dart';
import 'package:lexcore/features/home/application/home_providers.dart';
import 'package:lexcore/shared/components/app_surface_card.dart';
import 'package:lexcore/shared/widgets/app_mobile_canvas.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeData = ref.watch(homeDataProvider);
    final recentActivitySection = Column(
      children: [
        Row(
          children: [
            Text('最近活动', style: Theme.of(context).textTheme.titleSmall),
            const Spacer(),
            TextButton(onPressed: () {}, child: const Text('查看全部')),
          ],
        ),
        const SizedBox(height: 6),
        ...homeData.activities.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: AppSurfaceCard(
              onTap: () {},
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: AppColors.surfaceVariant,
                    ),
                    child: const Icon(Icons.history, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${DateTimeUtils.relativeFromNow(item.time)} · ${item.tag}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),
        ),
      ],
    );

    return Scaffold(
      body: AppMobileCanvas(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const AppFadeSlideIn(
                delay: Duration(milliseconds: 20),
                beginOffset: Offset(0, -0.02),
                child: _HomeTopBar(),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  children: AppStagger.sections([
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '您好, 法律专家',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(color: AppColors.primary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '今天想处理什么法律事务？',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.onSurfaceVariant),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          '核心服务',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: AppColors.onSurfaceVariant,
                                letterSpacing: 0.4,
                              ),
                        ),
                        const SizedBox(height: 10),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: homeData.actions.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 1.2,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                              ),
                          itemBuilder: (context, index) {
                            final action = homeData.actions[index];
                            final highlighted = index == 0;
                            final iconColor = highlighted
                                ? Colors.white
                                : AppColors.onSurfaceVariant;

                            return AppSurfaceCard(
                              backgroundColor: highlighted
                                  ? AppColors.primary.withValues(alpha: 0.95)
                                  : Colors.white,
                              onTap: () => context.push(action.route),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: highlighted
                                          ? Colors.white.withValues(alpha: 0.24)
                                          : AppColors.surfaceVariant,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      _iconFrom(action.icon),
                                      color: iconColor,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    action.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          color: highlighted
                                              ? Colors.white
                                              : AppColors.onSurface,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    action.subtitle,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: highlighted
                                              ? Colors.white.withValues(
                                                  alpha: 0.86,
                                                )
                                              : AppColors.onSurfaceVariant,
                                        ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    recentActivitySection,
                    const SizedBox(height: 12),
                  ]),
                ),
              ),
            ],
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

class _HomeTopBar extends StatelessWidget {
  const _HomeTopBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 2, 10, 2),
      child: Row(
        children: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.menu_rounded)),
          Text('LexiAI', style: Theme.of(context).textTheme.titleMedium),
          const Spacer(),
          IconButton(onPressed: () {}, icon: const Icon(Icons.search_rounded)),
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: AppColors.primary.withValues(alpha: 0.16),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: const Icon(Icons.person, size: 18, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
