import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lexcore/app/router/route_names.dart';
import 'package:lexcore/features/profile/application/profile_providers.dart';
import 'package:lexcore/shared/components/app_surface_card.dart';
import 'package:lexcore/shared/widgets/app_page_scaffold.dart';

class ProfileSubscriptionManagePage extends ConsumerWidget {
  const ProfileSubscriptionManagePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshotAsync = ref.watch(profileSubscriptionSnapshotProvider);
    return AppPageScaffold(
      title: '管理订阅',
      body: snapshotAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => const Center(child: Text('订阅信息加载失败')),
        data: (snapshot) => ListView(
          children: [
            AppSurfaceCard(
              backgroundColor: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.08),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '当前计划：${snapshot.planCode}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '订阅状态：${snapshot.status}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _PlanBenefit(text: '文书剩余 ${snapshot.documentRemaining}'),
                      _PlanBenefit(text: 'PDF 剩余 ${snapshot.pdfRemaining}'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _SubscriptionActionTile(
              icon: Icons.upgrade_outlined,
              title: '升级套餐',
              subtitle: '切换到团队版或企业版',
              onTap: () =>
                  context.push(RouteNames.profileSubscriptionUpgradePath),
            ),
            _SubscriptionActionTile(
              icon: Icons.calendar_month_outlined,
              title: '调整续费周期',
              subtitle: '月付 / 年付灵活切换',
              onTap: () =>
                  context.push(RouteNames.profileSubscriptionRenewalCyclePath),
            ),
            _SubscriptionActionTile(
              icon: Icons.cancel_outlined,
              title: '取消自动续费',
              subtitle: '到期后自动停止计费',
              onTap: () =>
                  context.push(RouteNames.profileSubscriptionCancelRenewalPath),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubscriptionActionTile extends StatelessWidget {
  const _SubscriptionActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          ),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _PlanBenefit extends StatelessWidget {
  const _PlanBenefit({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}
