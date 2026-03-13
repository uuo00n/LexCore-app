import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lexcore/app/router/route_names.dart';
import 'package:lexcore/core/extensions/router_navigation_extensions.dart';
import 'package:lexcore/features/profile/application/profile_providers.dart';
import 'package:lexcore/features/profile/domain/entities/profile_summary.dart';
import 'package:lexcore/features/profile/presentation/widgets/profile_avatar.dart';
import 'package:lexcore/shared/models/legal_models.dart';
import 'package:lexcore/shared/widgets/app_mobile_canvas.dart';
import 'package:lexcore/shared/widgets/app_shell_top_bar.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(profileSummaryProvider);
    final personalInfo = ref.watch(profilePersonalInfoControllerProvider).info;
    final menus = ref.watch(profileMenusProvider);
    final accountMenus = _buildAccountMenus();
    final contentMenus = _buildContentMenus(menus);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: AppMobileCanvas(
        maxContentWidth: 560,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _ProfileTopBar(
                onSettingsTap: () => context.push(RouteNames.settingsPath),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 118),
                  children: [
                    _ProfileHero(
                      summary: summary,
                      name: personalInfo.name,
                      email: personalInfo.email,
                      avatarPath: personalInfo.avatarPath,
                    ),
                    const SizedBox(height: 20),
                    _SectionTitle(
                      text: '账号与订阅',
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 8),
                    _SectionCard(
                      children: [
                        for (var i = 0; i < accountMenus.length; i++)
                          _SectionRow(
                            title: accountMenus[i].title,
                            subtitle: accountMenus[i].subtitle,
                            leading: accountMenus[i].icon,
                            onTap: () =>
                                context.navigateByRoute(accountMenus[i].route),
                            showDivider: i != accountMenus.length - 1,
                          ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _SubscriptionCard(summary: summary),
                    const SizedBox(height: 20),
                    _SectionTitle(
                      text: '内容与记录',
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 8),
                    _SectionCard(
                      children: [
                        for (var i = 0; i < contentMenus.length; i++)
                          _SectionRow(
                            title: contentMenus[i].title,
                            subtitle: contentMenus[i].subtitle,
                            leading: contentMenus[i].icon,
                            onTap: () =>
                                context.navigateByRoute(contentMenus[i].route),
                            showDivider: i != contentMenus.length - 1,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static List<_ProfileEntry> _buildAccountMenus() {
    return const [
      _ProfileEntry(
        title: '个人信息',
        subtitle: '姓名、头像与基本资料',
        icon: Icons.person_outline,
        route: RouteNames.profilePersonalInfoPath,
      ),
      _ProfileEntry(
        title: '账号安全',
        subtitle: '密码、双重验证',
        icon: Icons.shield_outlined,
        route: RouteNames.profileSecurityPath,
      ),
      _ProfileEntry(
        title: '账单与订阅',
        subtitle: '历史订单与支付方式',
        icon: Icons.payments_outlined,
        route: RouteNames.profileBillingPath,
      ),
    ];
  }

  static List<_ProfileEntry> _buildContentMenus(List<ProfileMenuItem> menus) {
    if (menus.isNotEmpty) {
      return menus
          .map(
            (item) => _ProfileEntry(
              title: item.title,
              subtitle: _contentSubtitleFor(item.title),
              icon: _iconFromMenu(item.icon),
              route: item.route,
            ),
          )
          .toList();
    }

    final fallbackRoutes = [
      RouteNames.savedDocumentsPath,
      RouteNames.historyPath,
    ];

    return [
      _ProfileEntry(
        title: '我的文档',
        subtitle: _contentSubtitleFor('我的文档'),
        icon: _iconFromMenu('folder_open'),
        route: fallbackRoutes[0],
      ),
      _ProfileEntry(
        title: '历史记录',
        subtitle: _contentSubtitleFor('历史记录'),
        icon: _iconFromMenu('history'),
        route: fallbackRoutes[1],
      ),
    ];
  }

  static String _contentSubtitleFor(String title) {
    switch (title) {
      case '我的文档':
        return '查看保存的法律文档';
      case '历史记录':
        return '查看咨询与分析历史';
      default:
        return '';
    }
  }

  static IconData _iconFromMenu(String icon) {
    switch (icon) {
      case 'folder_open':
        return Icons.folder_open_outlined;
      case 'history':
        return Icons.history;
      default:
        return Icons.menu_book_outlined;
    }
  }
}

class _ProfileTopBar extends StatelessWidget {
  const _ProfileTopBar({required this.onSettingsTap});

  final VoidCallback onSettingsTap;

  @override
  Widget build(BuildContext context) {
    return AppShellTopBar(
      title: '个人资料',
      actions: [
        IconButton(
          onPressed: onSettingsTap,
          icon: const Icon(Icons.settings_outlined),
          tooltip: '设置',
        ),
      ],
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({
    required this.summary,
    required this.name,
    required this.email,
    required this.avatarPath,
  });

  final ProfileSummary summary;
  final String name;
  final String email;
  final String? avatarPath;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        children: [
          ProfileAvatar(
            size: 112,
            borderWidth: 4,
            iconSize: 48,
            avatarPath: avatarPath,
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            email,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
            ),
            child: Text(
              summary.membership,
              style: theme.textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubscriptionCard extends StatelessWidget {
  const _SubscriptionCard({required this.summary});

  final ProfileSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: dark
            ? Theme.of(context).colorScheme.surfaceContainer
            : Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: dark
              ? Theme.of(context).colorScheme.outline.withValues(alpha: 0.28)
              : Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '当前订阅计划',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      summary.membership,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.workspace_premium,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...summary.benefits.map((benefit) => _PlanLine(text: benefit)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: dark
                      ? Theme.of(
                          context,
                        ).colorScheme.outline.withValues(alpha: 0.28)
                      : Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '下次计费日期：${summary.nextBillingDate}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                FilledButton(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(88, 34),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('管理订阅'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanLine extends StatelessWidget {
  const _PlanLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            size: 18,
            color: Theme.of(context).colorScheme.primaryFixedDim,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.9,
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: dark
            ? Theme.of(context).colorScheme.surfaceContainerHigh
            : Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }
}

class _SectionRow extends StatelessWidget {
  const _SectionRow({
    required this.title,
    required this.subtitle,
    required this.leading,
    required this.onTap,
    this.showDivider = false,
  });

  final String title;
  final String subtitle;
  final IconData leading;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: showDivider
              ? Border(
                  bottom: BorderSide(
                    color: dark
                        ? Theme.of(
                            context,
                          ).colorScheme.outline.withValues(alpha: 0.28)
                        : Theme.of(context).colorScheme.outlineVariant,
                  ),
                )
              : null,
        ),
        child: Row(
          children: [
            Icon(
              leading,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 21,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileEntry {
  const _ProfileEntry({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
}
