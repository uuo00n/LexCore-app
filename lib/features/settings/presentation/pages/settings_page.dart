import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lexcore/app/adaptive/app_adaptive_split_view.dart';
import 'package:lexcore/app/adaptive/app_breakpoints.dart';
import 'package:lexcore/app/router/route_names.dart';
import 'package:lexcore/app/theme/app_colors.dart';
import 'package:lexcore/features/settings/application/settings_controller.dart';
import 'package:lexcore/features/settings/domain/entities/settings_state.dart';
import 'package:lexcore/shared/components/app_surface_card.dart';
import 'package:lexcore/shared/models/legal_models.dart';
import 'package:lexcore/shared/widgets/app_page_scaffold.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  void _handleSettingTap(BuildContext context, SettingItem item) {
    switch (item.icon) {
      case 'policy':
        context.push(RouteNames.privacyPolicyPath);
        return;
      case 'description':
        context.push(RouteNames.termsOfServicePath);
        return;
      default:
        return;
    }
  }

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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final viewport = AppBreakpoints.fromWidth(constraints.maxWidth);
          final splitLayout =
              viewport == AppViewportSize.expanded ||
              viewport == AppViewportSize.ultra;

          if (!splitLayout) {
            return _SettingsMain(
              state: state,
              items: items,
              profileName: profile.name,
              profileMembership: profile.membership,
              version: version,
              onNotificationChanged: (value) => ref
                  .read(settingsControllerProvider.notifier)
                  .setNotifications(value),
              onBiometricChanged: (value) => ref
                  .read(settingsControllerProvider.notifier)
                  .setBiometric(value),
              onSettingTap: (item) => _handleSettingTap(context, item),
            );
          }

          return AppAdaptiveSplitView(
            splitMinWidth: 980,
            secondaryMaxWidth: 360,
            primary: _SettingsMain(
              state: state,
              items: items,
              profileName: profile.name,
              profileMembership: profile.membership,
              version: version,
              showAccountHeader: true,
              onNotificationChanged: (value) => ref
                  .read(settingsControllerProvider.notifier)
                  .setNotifications(value),
              onBiometricChanged: (value) => ref
                  .read(settingsControllerProvider.notifier)
                  .setBiometric(value),
              onSettingTap: (item) => _handleSettingTap(context, item),
            ),
            secondary: _SettingsSidePanel(
              version: version,
              onOpenPrivacyPolicy: () =>
                  context.push(RouteNames.privacyPolicyPath),
              onOpenTermsOfService: () =>
                  context.push(RouteNames.termsOfServicePath),
            ),
          );
        },
      ),
    );
  }
}

class _SettingsMain extends StatelessWidget {
  const _SettingsMain({
    required this.state,
    required this.items,
    required this.profileName,
    required this.profileMembership,
    required this.version,
    required this.onNotificationChanged,
    required this.onBiometricChanged,
    required this.onSettingTap,
    this.showAccountHeader = true,
  });

  final SettingsState state;
  final List<SettingItem> items;
  final String profileName;
  final String profileMembership;
  final String version;
  final ValueChanged<bool> onNotificationChanged;
  final ValueChanged<bool> onBiometricChanged;
  final ValueChanged<SettingItem> onSettingTap;
  final bool showAccountHeader;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        if (showAccountHeader)
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
                        profileName,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        profileMembership,
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
            onChanged: onNotificationChanged,
          ),
        ),
        _SettingRow(
          icon: Icons.fingerprint,
          title: '生物识别登录',
          subtitle: 'Face ID / 指纹快速验证',
          trailing: Switch(
            value: state.biometricEnabled,
            onChanged: onBiometricChanged,
          ),
        ),
        ...items.map(
          (item) => _SettingRow(
            icon: _iconFrom(item.icon),
            title: item.title,
            subtitle: item.subtitle,
            trailing: const Icon(Icons.chevron_right),
            onTap: () => onSettingTap(item),
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
      case 'description':
        return Icons.description_outlined;
      case 'info':
        return Icons.info_outline;
      default:
        return Icons.settings;
    }
  }
}

class _SettingsSidePanel extends StatelessWidget {
  const _SettingsSidePanel({
    required this.version,
    required this.onOpenPrivacyPolicy,
    required this.onOpenTermsOfService,
  });

  final String version;
  final VoidCallback onOpenPrivacyPolicy;
  final VoidCallback onOpenTermsOfService;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        AppSurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('桌面端快捷操作', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 10),
              FilledButton.tonalIcon(
                onPressed: () {},
                icon: const Icon(Icons.cleaning_services_outlined),
                label: const Text('清理缓存'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: onOpenPrivacyPolicy,
                icon: const Icon(Icons.policy_outlined),
                label: const Text('查看隐私政策'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: onOpenTermsOfService,
                icon: const Icon(Icons.description_outlined),
                label: const Text('查看服务条款'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        AppSurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('版本信息', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Text(
                version,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Container(
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

    if (onTap == null) {
      return content;
    }

    return GestureDetector(onTap: onTap, child: content);
  }
}
