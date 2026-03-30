import 'package:flutter/material.dart';

import 'package:lexcore/core/utils/feature_notice.dart';
import 'package:lexcore/shared/widgets/app_page_scaffold.dart';

class ProfileSecurityPage extends StatelessWidget {
  const ProfileSecurityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppPageScaffold(
      title: '账号安全',
      body: ListView(
        children: [
          _ActionRow(
            icon: Icons.lock_outline,
            title: '修改登录密码',
            subtitle: '建议定期更新密码以保护账号安全',
            onTap: () =>
                showFeatureInProgressSnackBar(context, featureLabel: '修改密码'),
          ),
          _ActionRow(
            icon: Icons.phonelink_lock_outlined,
            title: '双重验证',
            subtitle: '开启后登录时需要额外验证码',
            onTap: () =>
                showFeatureInProgressSnackBar(context, featureLabel: '双重验证'),
          ),
          _ActionRow(
            icon: Icons.devices_outlined,
            title: '登录设备管理',
            subtitle: '查看并管理已登录设备',
            onTap: () =>
                showFeatureInProgressSnackBar(context, featureLabel: '登录设备管理'),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: theme.colorScheme.surfaceContainerLow,
            ),
            child: Text(
              '安全功能当前为演示状态，后续将接入账号中心服务。',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
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
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
          ),
          child: Icon(icon, color: theme.colorScheme.primary),
        ),
        title: Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
