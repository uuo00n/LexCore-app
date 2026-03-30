import 'package:flutter/material.dart';

import 'package:lexcore/core/utils/feature_notice.dart';
import 'package:lexcore/shared/components/app_surface_card.dart';
import 'package:lexcore/shared/widgets/app_page_scaffold.dart';

class ProfileSubscriptionManagePage extends StatelessWidget {
  const ProfileSubscriptionManagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      title: '管理订阅',
      subtitle: '会员计划与计费',
      body: ListView(
        children: [
          AppSurfaceCard(
            backgroundColor: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.08),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '当前计划：PRO 会员',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '下次计费日期：2024年12月1日',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: const [
                    _PlanBenefit(text: '无限次智能咨询'),
                    _PlanBenefit(text: '高级文书模板'),
                    _PlanBenefit(text: '优先导出能力'),
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
                showFeatureInProgressSnackBar(context, featureLabel: '升级套餐'),
          ),
          _SubscriptionActionTile(
            icon: Icons.calendar_month_outlined,
            title: '调整续费周期',
            subtitle: '月付 / 年付灵活切换',
            onTap: () =>
                showFeatureInProgressSnackBar(context, featureLabel: '续费周期调整'),
          ),
          _SubscriptionActionTile(
            icon: Icons.cancel_outlined,
            title: '取消自动续费',
            subtitle: '到期后自动停止计费',
            onTap: () =>
                showFeatureInProgressSnackBar(context, featureLabel: '取消自动续费'),
          ),
        ],
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
