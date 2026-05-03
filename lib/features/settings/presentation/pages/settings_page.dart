import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lexcore/app/adaptive/app_adaptive_split_view.dart';
import 'package:lexcore/app/adaptive/app_breakpoints.dart';
import 'package:lexcore/app/router/route_names.dart';
import 'package:lexcore/app/theme/theme_mode_controller.dart';
import 'package:lexcore/features/auth/application/auth_controller.dart';
import 'package:lexcore/features/settings/application/settings_controller.dart';
import 'package:lexcore/features/settings/domain/entities/settings_state.dart';
import 'package:lexcore/shared/components/app_surface_card.dart';
import 'package:lexcore/shared/models/legal_models.dart';
import 'package:lexcore/shared/widgets/app_page_scaffold.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  void _handleSettingTap(
    BuildContext context,
    WidgetRef ref,
    SettingItem item,
  ) {
    switch (item.icon) {
      case 'dark_mode':
        _showThemeModeSheet(context, ref);
        return;
      case 'policy':
        context.push(RouteNames.privacyPolicyPath);
        return;
      case 'description':
        context.push(RouteNames.termsOfServicePath);
        return;
      case 'info':
        context.push(RouteNames.aboutPath);
        return;
      default:
        return;
    }
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      barrierColor: Theme.of(context).colorScheme.scrim.withValues(alpha: 0.45),
      builder: (dialogContext) {
        return const _LogoutConfirmDialog();
      },
    );

    if (shouldLogout != true || !context.mounted) {
      return;
    }
    await ref.read(authControllerProvider.notifier).logout();
    if (!context.mounted) {
      return;
    }
    context.go(RouteNames.authPath);
  }

  void _showHelpSupport(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('帮助中心建设中，敬请期待')));
  }

  Future<void> _showThemeModeSheet(BuildContext context, WidgetRef ref) async {
    final currentMode = ref.read(themeModeControllerProvider);
    final controller = ref.read(themeModeControllerProvider.notifier);

    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ThemeModeOption(
                icon: Icons.brightness_auto_outlined,
                title: '跟随系统',
                selected: currentMode == ThemeMode.system,
                onTap: () {
                  controller.setThemeMode(ThemeMode.system);
                  Navigator.of(sheetContext).pop();
                },
              ),
              _ThemeModeOption(
                icon: Icons.light_mode_outlined,
                title: '浅色模式',
                selected: currentMode == ThemeMode.light,
                onTap: () {
                  controller.setThemeMode(ThemeMode.light);
                  Navigator.of(sheetContext).pop();
                },
              ),
              _ThemeModeOption(
                icon: Icons.dark_mode_outlined,
                title: '深色模式',
                selected: currentMode == ThemeMode.dark,
                onTap: () {
                  controller.setThemeMode(ThemeMode.dark);
                  Navigator.of(sheetContext).pop();
                },
              ),
              const SizedBox(height: 6),
            ],
          ),
        );
      },
    );
  }

  static String _themeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return '跟随系统';
      case ThemeMode.light:
        return '浅色模式';
      case ThemeMode.dark:
        return '深色模式';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsControllerProvider);
    final items = ref.watch(settingsItemsProvider);
    final version = ref.watch(settingsVersionProvider);
    final themeMode = ref.watch(themeModeControllerProvider);

    return AppPageScaffold(
      title: '设置',
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
              version: version,
              themeMode: themeMode,
              showHelpEntry: true,
              showVersionInMain: true,
              onNotificationChanged: (value) => ref
                  .read(settingsControllerProvider.notifier)
                  .setNotifications(value),
              onBiometricChanged: (value) => ref
                  .read(settingsControllerProvider.notifier)
                  .setBiometric(value),
              onSettingTap: (item) => _handleSettingTap(context, ref, item),
              onHelpTap: () => _showHelpSupport(context),
              onLogout: () => _confirmLogout(context, ref),
            );
          }

          return AppAdaptiveSplitView(
            splitMinWidth: 980,
            secondaryMaxWidth: 360,
            primary: _SettingsMain(
              state: state,
              items: items,
              version: version,
              themeMode: themeMode,
              showHelpEntry: false,
              showVersionInMain: false,
              onNotificationChanged: (value) => ref
                  .read(settingsControllerProvider.notifier)
                  .setNotifications(value),
              onBiometricChanged: (value) => ref
                  .read(settingsControllerProvider.notifier)
                  .setBiometric(value),
              onSettingTap: (item) => _handleSettingTap(context, ref, item),
              onHelpTap: () => _showHelpSupport(context),
              onLogout: () => _confirmLogout(context, ref),
            ),
            secondary: _SettingsSidePanel(
              version: version,
              onHelpTap: () => _showHelpSupport(context),
            ),
          );
        },
      ),
    );
  }
}

class _LogoutConfirmDialog extends StatelessWidget {
  const _LogoutConfirmDialog();

  static const actionsRowKey = ValueKey('logout_confirm_actions_row');
  static const cancelButtonKey = ValueKey('logout_confirm_cancel_button');
  static const confirmButtonKey = ValueKey('logout_confirm_submit_button');

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer.withValues(alpha: 0.88),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    color: colorScheme.error,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '确定退出登录？',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '退出后需要重新输入账号密码登录。',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                key: actionsRowKey,
                children: [
                  Expanded(
                    child: TextButton(
                      key: cancelButtonKey,
                      style: TextButton.styleFrom(
                        minimumSize: const Size.fromHeight(46),
                        backgroundColor: colorScheme.surfaceContainerHigh,
                        foregroundColor: colorScheme.onSurface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('取消'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      key: confirmButtonKey,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(46),
                        backgroundColor: colorScheme.error,
                        foregroundColor: colorScheme.onError,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('退出登录'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsMain extends StatelessWidget {
  const _SettingsMain({
    required this.state,
    required this.items,
    required this.version,
    required this.themeMode,
    required this.showHelpEntry,
    required this.showVersionInMain,
    required this.onNotificationChanged,
    required this.onBiometricChanged,
    required this.onSettingTap,
    required this.onHelpTap,
    required this.onLogout,
  });

  final SettingsState state;
  final List<SettingItem> items;
  final String version;
  final ThemeMode themeMode;
  final bool showHelpEntry;
  final bool showVersionInMain;
  final ValueChanged<bool> onNotificationChanged;
  final ValueChanged<bool> onBiometricChanged;
  final ValueChanged<SettingItem> onSettingTap;
  final VoidCallback onHelpTap;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Text(
          '系统与偏好',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Theme.of(context).colorScheme.primary,
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
        ...items.map((item) {
          final subtitle = item.icon == 'dark_mode'
              ? SettingsPage._themeModeLabel(themeMode)
              : item.subtitle;
          return _SettingRow(
            icon: _iconFrom(item.icon),
            title: item.title,
            subtitle: subtitle,
            trailing: const Icon(Icons.chevron_right),
            onTap: () => onSettingTap(item),
          );
        }),
        if (showHelpEntry)
          _SettingRow(
            icon: Icons.help_outline,
            title: '帮助与支持',
            subtitle: '查看常见问题与联系支持',
            trailing: const Icon(Icons.chevron_right),
            onTap: onHelpTap,
          ),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: onLogout,
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.errorContainer,
            foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
            minimumSize: const Size.fromHeight(46),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.logout),
          label: const Text('退出登录'),
        ),
        if (showVersionInMain) ...[
          const SizedBox(height: 12),
          Center(
            child: Text(
              version,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
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
  const _SettingsSidePanel({required this.version, required this.onHelpTap});

  final String version;
  final VoidCallback onHelpTap;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        AppSurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('帮助与支持', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 10),
              FilledButton.tonalIcon(
                onPressed: onHelpTap,
                icon: const Icon(Icons.help_outline),
                label: const Text('打开帮助中心'),
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
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
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
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
            ),
            child: Icon(icon, color: Theme.of(context).colorScheme.primary),
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
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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

class _ThemeModeOption extends StatelessWidget {
  const _ThemeModeOption({
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      trailing: selected
          ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
          : null,
      onTap: onTap,
    );
  }
}
