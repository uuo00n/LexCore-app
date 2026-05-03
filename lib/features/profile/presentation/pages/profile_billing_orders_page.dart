import 'package:flutter/material.dart';

import 'package:lexcore/core/utils/feature_notice.dart';
import 'package:lexcore/shared/components/app_surface_card.dart';
import 'package:lexcore/shared/widgets/app_page_scaffold.dart';

class ProfileBillingOrdersPage extends StatefulWidget {
  const ProfileBillingOrdersPage({super.key});

  @override
  State<ProfileBillingOrdersPage> createState() =>
      _ProfileBillingOrdersPageState();
}

class _ProfileBillingOrdersPageState extends State<ProfileBillingOrdersPage> {
  String _filter = 'all';

  static const _orders = [
    _OrderItem(
      id: 'OD20260402001',
      planName: 'PRO 年付',
      amountLabel: '￥980.00',
      dateLabel: '2026-04-02 10:32',
      status: 'paid',
    ),
    _OrderItem(
      id: 'OD20260302009',
      planName: 'PRO 月付',
      amountLabel: '￥98.00',
      dateLabel: '2026-03-02 09:15',
      status: 'paid',
    ),
    _OrderItem(
      id: 'OD20260201011',
      planName: 'PRO 月付',
      amountLabel: '￥98.00',
      dateLabel: '2026-02-01 11:03',
      status: 'refund',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final list = _orders.where((item) {
      if (_filter == 'all') {
        return true;
      }
      return item.status == _filter;
    }).toList();

    return AppPageScaffold(
      title: '历史订单',
      body: ListView(
        children: [
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _FilterChip(
                  selected: _filter == 'all',
                  text: '全部',
                  onTap: () => setState(() => _filter = 'all'),
                ),
                _FilterChip(
                  selected: _filter == 'paid',
                  text: '已支付',
                  onTap: () => setState(() => _filter = 'paid'),
                ),
                _FilterChip(
                  selected: _filter == 'refund',
                  text: '已退款',
                  onTap: () => setState(() => _filter = 'refund'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (list.isEmpty)
            AppSurfaceCard(
              child: Text(
                '当前筛选条件下暂无订单记录。',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            )
          else
            for (final order in list) ...[
              _OrderCard(item: order),
              const SizedBox(height: 10),
            ],
          const SizedBox(height: 4),
          OutlinedButton.icon(
            onPressed: () =>
                showFeatureInProgressSnackBar(context, featureLabel: '下载发票'),
            icon: const Icon(Icons.receipt_long_outlined),
            label: const Text('下载发票（演示）'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.item});

  final _OrderItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = switch (item.status) {
      'paid' => ('已支付', theme.colorScheme.primary, theme.colorScheme.onPrimary),
      'refund' => (
        '已退款',
        theme.colorScheme.tertiary,
        theme.colorScheme.onTertiary,
      ),
      _ => ('处理中', theme.colorScheme.secondary, theme.colorScheme.onSecondary),
    };

    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.planName,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: status.$2,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  status.$1,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: status.$3,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '订单号：${item.id}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '支付时间：${item.dateLabel}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            item.amountLabel,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.selected,
    required this.text,
    required this.onTap,
  });

  final bool selected;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(text),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}

class _OrderItem {
  const _OrderItem({
    required this.id,
    required this.planName,
    required this.amountLabel,
    required this.dateLabel,
    required this.status,
  });

  final String id;
  final String planName;
  final String amountLabel;
  final String dateLabel;
  final String status;
}
