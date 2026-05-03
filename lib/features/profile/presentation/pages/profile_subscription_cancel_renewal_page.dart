import 'package:flutter/material.dart';

import 'package:lexcore/core/utils/feature_notice.dart';
import 'package:lexcore/shared/components/app_surface_card.dart';
import 'package:lexcore/shared/widgets/app_page_scaffold.dart';

class ProfileSubscriptionCancelRenewalPage extends StatefulWidget {
  const ProfileSubscriptionCancelRenewalPage({super.key});

  @override
  State<ProfileSubscriptionCancelRenewalPage> createState() =>
      _ProfileSubscriptionCancelRenewalPageState();
}

class _ProfileSubscriptionCancelRenewalPageState
    extends State<ProfileSubscriptionCancelRenewalPage> {
  String _reason = 'cost';
  bool _confirmed = false;

  static const _reasons = [
    ('cost', '价格不符合预期'),
    ('frequency', '使用频率较低'),
    ('feature', '功能暂不匹配需求'),
    ('other', '其他原因'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppPageScaffold(
      title: '取消自动续费',
      body: ListView(
        children: [
          AppSurfaceCard(
            backgroundColor: theme.colorScheme.errorContainer.withValues(
              alpha: 0.42,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '取消后当前周期仍可继续使用',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '订阅将在到期后停止，不会立刻影响已开通权益。',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('取消原因', style: theme.textTheme.titleSmall),
                const SizedBox(height: 6),
                for (final item in _reasons)
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => setState(() => _reason = item.$1),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 2,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _reason == item.$1
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off_outlined,
                            color: _reason == item.$1
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: Text(item.$2)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppSurfaceCard(
            child: CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _confirmed,
              onChanged: (value) {
                setState(() => _confirmed = value ?? false);
              },
              title: const Text('我已确认取消自动续费仅为演示操作'),
              subtitle: Text(
                '实际环境中会二次验证并发送确认通知。',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: _confirmed
                ? () => showFeatureInProgressSnackBar(
                    context,
                    featureLabel: '确认取消自动续费',
                  )
                : null,
            child: const Text('确认取消（演示）'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
