import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lexcore/app/adaptive/app_adaptive_split_view.dart';
import 'package:lexcore/app/adaptive/app_breakpoints.dart';
import 'package:lexcore/app/motion/app_motion_widgets.dart';
import 'package:lexcore/app/router/route_names.dart';
import 'package:lexcore/app/theme/app_colors.dart';
import 'package:lexcore/features/profile/application/profile_providers.dart';
import 'package:lexcore/features/profile/domain/entities/profile_summary.dart';
import 'package:lexcore/shared/components/app_surface_card.dart';
import 'package:lexcore/shared/models/legal_models.dart';
import 'package:lexcore/shared/widgets/app_mobile_canvas.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(profileSummaryProvider);
    final menus = ref.watch(profileMenusProvider);

    return Scaffold(
      body: AppMobileCanvas(
        child: SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final viewport = AppBreakpoints.fromWidth(constraints.maxWidth);
              final splitLayout =
                  viewport == AppViewportSize.expanded ||
                  viewport == AppViewportSize.ultra;

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 6),
                    child: AppFadeSlideIn(
                      delay: const Duration(milliseconds: 20),
                      beginOffset: const Offset(0, -0.02),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.menu_rounded),
                          ),
                          Expanded(
                            child: Text(
                              '个人资料',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          IconButton(
                            onPressed: () =>
                                context.push(RouteNames.settingsPath),
                            icon: const Icon(Icons.settings_outlined),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
                      child: splitLayout
                          ? AppAdaptiveSplitView(
                              splitMinWidth: 980,
                              secondaryMaxWidth: 420,
                              primary: ListView(
                                children: [
                                  _ProfileHero(summary: summary),
                                  const SizedBox(height: 18),
                                  _SubscriptionCard(summary: summary),
                                ],
                              ),
                              secondary: _ProfileMenuPanel(menus: menus),
                            )
                          : ListView(
                              children: AppStagger.sections([
                                _ProfileHero(summary: summary),
                                const SizedBox(height: 18),
                                _SubscriptionCard(summary: summary),
                                const SizedBox(height: 18),
                                _ProfileMenuPanel(menus: menus),
                              ]),
                            ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  static IconData _iconFrom(String icon) {
    switch (icon) {
      case 'folder_open':
        return Icons.folder_open_outlined;
      case 'history':
        return Icons.history;
      case 'settings':
        return Icons.settings_outlined;
      default:
        return Icons.person_outline;
    }
  }

  static String _subtitle(String title) {
    switch (title) {
      case '我的文档':
        return '查看和管理文书资产';
      case '历史记录':
        return '咨询、分析与检索轨迹';
      case '设置':
        return '账号安全与偏好配置';
      default:
        return '';
    }
  }
}

class _ProfileMenuPanel extends StatelessWidget {
  const _ProfileMenuPanel({required this.menus});

  final List<ProfileMenuItem> menus;

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _SectionTitle(text: '账户详情', color: AppColors.primary),
        const SizedBox(height: 8),
        AppSurfaceCard(
          padding: EdgeInsets.zero,
          backgroundColor: const Color(0xFFF8FAFD),
          child: Column(
            children: [
              for (var i = 0; i < menus.length; i++)
                _SectionRow(
                  title: menus[i].title,
                  subtitle: ProfilePage._subtitle(menus[i].title),
                  leading: ProfilePage._iconFrom(menus[i].icon),
                  onTap: () => context.push(menus[i].route),
                  showDivider: i != menus.length - 1,
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _SectionTitle(text: '其他', color: AppColors.onSurfaceVariant),
        const SizedBox(height: 8),
        AppSurfaceCard(
          padding: EdgeInsets.zero,
          backgroundColor: const Color(0xFFF8FAFD),
          child: Column(
            children: [
              _SectionRow(
                title: '帮助与支持',
                subtitle: '常见问题与人工服务',
                leading: Icons.help_outline,
                onTap: () {},
                showDivider: true,
              ),
              _SectionRow(
                title: '退出登录',
                subtitle: '',
                leading: Icons.logout,
                onTap: () {},
                titleColor: const Color(0xFFDC2626),
                iconColor: const Color(0xFFDC2626),
                showChevron: false,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.summary});

  final ProfileSummary summary;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 112,
                height: 112,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    width: 4,
                  ),
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFF3F5F9),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 50,
                    color: AppColors.primary,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.edit, color: Colors.white, size: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            summary.name,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            summary.email,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: AppColors.primary.withValues(alpha: 0.12),
            ),
            child: Text(
              summary.membership,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.7,
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
    return AppSurfaceCard(
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
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      summary.membership,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.workspace_premium, color: AppColors.primary),
            ],
          ),
          const SizedBox(height: 10),
          ...summary.benefits.map((benefit) => _PlanLine(benefit)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.6),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '下次计费日期：${summary.nextBillingDate}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
                FilledButton(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(84, 34),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
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
  const _PlanLine(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 16, color: Colors.green),
          const SizedBox(width: 6),
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
    return Text(
      text,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: color,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
      ),
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
    this.showChevron = true,
    this.titleColor,
    this.iconColor,
  });

  final String title;
  final String subtitle;
  final IconData leading;
  final VoidCallback onTap;
  final bool showDivider;
  final bool showChevron;
  final Color? titleColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          border: showDivider
              ? Border(
                  bottom: BorderSide(
                    color: Theme.of(
                      context,
                    ).dividerColor.withValues(alpha: 0.5),
                  ),
                )
              : null,
        ),
        child: Row(
          children: [
            Icon(
              leading,
              color: iconColor ?? AppColors.onSurfaceVariant,
              size: 20,
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
                      color: titleColor,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            if (showChevron)
              const Icon(
                Icons.chevron_right,
                size: 20,
                color: AppColors.onSurfaceVariant,
              ),
          ],
        ),
      ),
    );
  }
}
