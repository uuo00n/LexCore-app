import 'package:flutter/material.dart';

import 'package:lexcore/app/theme/app_spacing.dart';

import 'app_shell_top_bar.dart';

class AppSubPageHeader extends StatelessWidget {
  const AppSubPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
    this.showBackButton = true,
    this.onBackPressed,
  });

  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  @override
  Widget build(BuildContext context) {
    final resolvedSideWidth = AppShellTopBar.resolveSideWidth(
      actionCount: actions.length,
      hasLeading: showBackButton,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppShellTopBar(
          title: title,
          leading: showBackButton
              ? IconButton(
                  onPressed:
                      onBackPressed ?? () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.arrow_back_rounded),
                  tooltip: '返回',
                )
              : null,
          actions: actions,
        ),
        if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xxs),
          Padding(
            padding: EdgeInsets.fromLTRB(
              resolvedSideWidth + AppSpacing.xs,
              0,
              resolvedSideWidth + AppSpacing.xs,
              AppSpacing.xs,
            ),
            child: Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
