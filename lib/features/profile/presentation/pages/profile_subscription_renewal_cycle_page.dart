import 'package:flutter/material.dart';

import 'package:lexcore/core/utils/feature_notice.dart';
import 'package:lexcore/shared/components/app_surface_card.dart';
import 'package:lexcore/shared/widgets/app_page_scaffold.dart';

class ProfileSubscriptionRenewalCyclePage extends StatefulWidget {
  const ProfileSubscriptionRenewalCyclePage({super.key});

  @override
  State<ProfileSubscriptionRenewalCyclePage> createState() =>
      _ProfileSubscriptionRenewalCyclePageState();
}

class _ProfileSubscriptionRenewalCyclePageState
    extends State<ProfileSubscriptionRenewalCyclePage> {
  String _cycle = 'yearly';
  bool _autoRenewEnabled = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final yearly = _cycle == 'yearly';

    return AppPageScaffold(
      title: '调整续费周期',
      body: ListView(
        children: [
          AppSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('当前周期', style: theme.textTheme.titleSmall),
                const SizedBox(height: 10),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'monthly', label: Text('月付')),
                    ButtonSegment(value: 'yearly', label: Text('年付')),
                  ],
                  selected: {_cycle},
                  showSelectedIcon: false,
                  onSelectionChanged: (selection) {
                    setState(() => _cycle = selection.first);
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  yearly ? '当前为年付：续费时可享受年度折扣。' : '当前为月付：按月灵活续费。',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppSurfaceCard(
            child: SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: _autoRenewEnabled,
              title: Text(
                '自动续费',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: Text(
                _autoRenewEnabled ? '已开启，到期后自动扣费续期。' : '已关闭，到期后不会自动扣费。',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              onChanged: (value) => setState(() => _autoRenewEnabled = value),
            ),
          ),
          const SizedBox(height: 12),
          AppSurfaceCard(
            backgroundColor: theme.colorScheme.secondary.withValues(alpha: 0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('费用说明', style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                Text(
                  '• 切换周期将在下个计费日生效\n'
                  '• 年付平均每月更优惠（演示说明）\n'
                  '• 周期调整后可再次修改',
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.55),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: () =>
                showFeatureInProgressSnackBar(context, featureLabel: '保存续费周期'),
            child: const Text('保存设置（演示）'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
