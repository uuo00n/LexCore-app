import 'package:flutter/material.dart';

import 'package:lexcore/core/utils/feature_notice.dart';
import 'package:lexcore/shared/components/app_surface_card.dart';
import 'package:lexcore/shared/widgets/app_page_scaffold.dart';

class ProfileBillingPaymentMethodsPage extends StatefulWidget {
  const ProfileBillingPaymentMethodsPage({super.key});

  @override
  State<ProfileBillingPaymentMethodsPage> createState() =>
      _ProfileBillingPaymentMethodsPageState();
}

class _ProfileBillingPaymentMethodsPageState
    extends State<ProfileBillingPaymentMethodsPage> {
  String _defaultMethodId = 'bank_ending_6688';

  static const _methods = [
    _PaymentMethod(
      id: 'bank_ending_6688',
      title: '招商银行（尾号 6688）',
      subtitle: '借记卡 · 快捷支付',
      icon: Icons.account_balance_outlined,
    ),
    _PaymentMethod(
      id: 'alipay_main',
      title: '支付宝',
      subtitle: 'huangjunbo***@example.com',
      icon: Icons.account_balance_wallet_outlined,
    ),
    _PaymentMethod(
      id: 'wechat_pay',
      title: '微信支付',
      subtitle: '已绑定常用支付账户',
      icon: Icons.payments_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      title: '支付方式',
      body: ListView(
        children: [
          for (final method in _methods) ...[
            _PaymentMethodCard(
              method: method,
              isDefault: method.id == _defaultMethodId,
              onSetDefault: () => setState(() => _defaultMethodId = method.id),
            ),
            const SizedBox(height: 10),
          ],
          FilledButton.tonalIcon(
            onPressed: () =>
                showFeatureInProgressSnackBar(context, featureLabel: '添加支付方式'),
            icon: const Icon(Icons.add_card_outlined),
            label: const Text('添加支付方式（演示）'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  const _PaymentMethodCard({
    required this.method,
    required this.isDefault,
    required this.onSetDefault,
  });

  final _PaymentMethod method;
  final bool isDefault;
  final VoidCallback onSetDefault;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppSurfaceCard(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                ),
                child: Icon(method.icon, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      method.subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: theme.colorScheme.primary,
                  ),
                  child: Text(
                    '默认',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              else
                OutlinedButton(
                  onPressed: onSetDefault,
                  child: const Text('设为默认'),
                ),
              const Spacer(),
              TextButton(
                onPressed: () => showFeatureInProgressSnackBar(
                  context,
                  featureLabel: '移除支付方式',
                ),
                child: const Text('移除'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaymentMethod {
  const _PaymentMethod({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
}
