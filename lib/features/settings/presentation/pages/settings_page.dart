import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lexcore/app/theme/app_colors.dart';
import 'package:lexcore/features/settings/application/settings_controller.dart';
import 'package:lexcore/shared/widgets/app_page_scaffold.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsControllerProvider);
    final items = ref.watch(settingsItemsProvider);
    final profile = ref.watch(settingsProfileProvider);
    final version = ref.watch(settingsVersionProvider);

    return AppPageScaffold(
      title: '设置',
      actions: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
      ],
      body: ListView(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.name,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        profile.membership,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      FilledButton(
                        onPressed: () {},
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(86, 36),
                          shape: const StadiumBorder(),
                        ),
                        child: const Text('编辑资料'),
                      ),
                    ],
                  ),
                ),
                const CircleAvatar(
                  radius: 34,
                  backgroundColor: Color(0x220B50DA),
                  child: Icon(Icons.person, color: AppColors.primary, size: 34),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '账户设置',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          _SettingRow(
            icon: Icons.notifications_outlined,
            title: '消息通知',
            subtitle: '案件进度与文档提醒',
            trailing: Switch(
              value: state.notificationsEnabled,
              onChanged: (value) => ref
                  .read(settingsControllerProvider.notifier)
                  .setNotifications(value),
            ),
          ),
          _SettingRow(
            icon: Icons.fingerprint,
            title: '生物识别登录',
            subtitle: 'Face ID / 指纹快速验证',
            trailing: Switch(
              value: state.biometricEnabled,
              onChanged: (value) => ref
                  .read(settingsControllerProvider.notifier)
                  .setBiometric(value),
            ),
          ),
          ...items.map(
            (item) => _SettingRow(
              icon: _iconFrom(item.icon),
              title: item.title,
              subtitle: item.subtitle,
              trailing: const Icon(Icons.chevron_right),
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: () {},
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFEE4E2),
              foregroundColor: const Color(0xFFB42318),
              minimumSize: const Size.fromHeight(46),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.logout),
            label: const Text('退出登录'),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              version,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFrom(String icon) {
    switch (icon) {
      case 'dark_mode':
        return Icons.contrast_outlined;
      case 'cleaning_services':
        return Icons.cleaning_services_outlined;
      case 'policy':
        return Icons.policy_outlined;
      case 'info':
        return Icons.info_outline;
      default:
        return Icons.settings;
    }
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFD),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColors.primary.withValues(alpha: 0.1),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
