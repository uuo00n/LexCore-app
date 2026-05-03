import 'package:flutter/material.dart';

import 'package:lexcore/core/utils/feature_notice.dart';
import 'package:lexcore/shared/components/app_surface_card.dart';
import 'package:lexcore/shared/widgets/app_page_scaffold.dart';

class ProfileSubscriptionUpgradePage extends StatefulWidget {
  const ProfileSubscriptionUpgradePage({super.key});

  @override
  State<ProfileSubscriptionUpgradePage> createState() =>
      _ProfileSubscriptionUpgradePageState();
}

class _ProfileSubscriptionUpgradePageState
    extends State<ProfileSubscriptionUpgradePage> {
  String _selectedPlanCode = 'pro_yearly';

  static const _plans = [
    _UpgradePlan(
      code: 'pro_monthly',
      title: 'PRO 月付',
      priceLabel: '￥98 / 月',
      desc: '适合个人律师与轻量团队',
      benefits: ['每月 300 次文书生成', '每月 120 次 PDF 导出', '优先模型响应'],
    ),
    _UpgradePlan(
      code: 'pro_yearly',
      title: 'PRO 年付',
      priceLabel: '￥980 / 年',
      desc: '适合高频使用用户，年度更省',
      benefits: ['每月 380 次文书生成', '每月 180 次 PDF 导出', '专属续费优惠'],
    ),
    _UpgradePlan(
      code: 'team_yearly',
      title: 'TEAM 年付',
      priceLabel: '￥2680 / 年',
      desc: '适合法务团队协作与审批流',
      benefits: ['团队席位管理', '共享案例知识库', '高级权限控制'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedPlan = _plans.firstWhere(
      (plan) => plan.code == _selectedPlanCode,
      orElse: () => _plans[0],
    );

    return AppPageScaffold(
      title: '升级套餐',
      body: ListView(
        children: [
          AppSurfaceCard(
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.08),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '当前套餐：${selectedPlan.title}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '升级后即时生效，费用按规则折算（演示数据）。',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          for (final plan in _plans) ...[
            _PlanCard(
              plan: plan,
              selected: _selectedPlanCode == plan.code,
              onTap: () => setState(() => _selectedPlanCode = plan.code),
            ),
            const SizedBox(height: 10),
          ],
          AppSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('权益摘要', style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                for (final benefit in selectedPlan.benefits)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            benefit,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: () =>
                showFeatureInProgressSnackBar(context, featureLabel: '确认升级'),
            child: const Text('确认升级（演示）'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.selected,
    required this.onTap,
  });

  final _UpgradePlan plan;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppSurfaceCard(
      onTap: onTap,
      backgroundColor: selected
          ? theme.colorScheme.primary.withValues(alpha: 0.08)
          : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  plan.priceLabel,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  plan.desc,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            selected
                ? Icons.radio_button_checked
                : Icons.radio_button_off_outlined,
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

class _UpgradePlan {
  const _UpgradePlan({
    required this.code,
    required this.title,
    required this.priceLabel,
    required this.desc,
    required this.benefits,
  });

  final String code;
  final String title;
  final String priceLabel;
  final String desc;
  final List<String> benefits;
}
