import 'package:flutter/material.dart';

import 'package:lexcore/shared/widgets/app_page_scaffold.dart';

class ProfilePersonalInfoPage extends StatelessWidget {
  const ProfilePersonalInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      title: '个人信息',
      body: ListView(
        children: [
          const _ProfileHeader(
            name: 'LexCore 用户',
            email: 'lexcore_user@example.com',
          ),
          const SizedBox(height: 20),
          const _SectionHeader(text: '基础资料'),
          const SizedBox(height: 8),
          _InfoActionRow(
            icon: Icons.person_outline,
            title: '姓名',
            subtitle: 'LexCore 用户',
            onTap: () {},
          ),
          _InfoActionRow(
            icon: Icons.phone_outlined,
            title: '手机号',
            subtitle: '138****2601',
            onTap: () {},
          ),
          _InfoActionRow(
            icon: Icons.email_outlined,
            title: '邮箱',
            subtitle: 'lexcore_user@example.com',
            onTap: () {},
          ),
          const SizedBox(height: 18),
          const _SectionHeader(text: '职业信息'),
          const SizedBox(height: 8),
          _InfoActionRow(
            icon: Icons.work_outline,
            title: '职位角色',
            subtitle: '个人法律顾问',
            onTap: () {},
          ),
          _InfoActionRow(
            icon: Icons.business_outlined,
            title: '所属机构',
            subtitle: '独立执业',
            onTap: () {},
          ),
          _InfoActionRow(
            icon: Icons.category_outlined,
            title: '业务领域',
            subtitle: '民商事纠纷 / 劳动争议',
            onTap: () {},
          ),
          const SizedBox(height: 18),
          const _SectionHeader(text: '偏好设置'),
          const SizedBox(height: 8),
          _InfoActionRow(
            icon: Icons.language_outlined,
            title: '语言偏好',
            subtitle: '简体中文',
            onTap: () {},
          ),
          _InfoActionRow(
            icon: Icons.notifications_outlined,
            title: '通知设置',
            subtitle: '已开启',
            onTap: () {},
          ),
          const SizedBox(height: 12),
          const _InfoNote(),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.name, required this.email});

  final String name;
  final String email;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.14),
                width: 3,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.surfaceContainerLow,
              ),
              child: Icon(
                Icons.person,
                size: 36,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            name,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            email,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Text(
        text,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _InfoActionRow extends StatelessWidget {
  const _InfoActionRow({
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

class _InfoNote extends StatelessWidget {
  const _InfoNote();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.surfaceContainerLow,
      ),
      child: Text(
        '资料修改功能将在后续版本接入真实数据源。',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
