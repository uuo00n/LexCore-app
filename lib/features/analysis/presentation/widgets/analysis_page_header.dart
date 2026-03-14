import 'package:flutter/material.dart';

import 'package:lexcore/shared/widgets/app_shell_top_bar.dart';

class AnalysisPageHeader extends StatelessWidget {
  const AnalysisPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
  });

  final String title;
  final String? subtitle;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final resolvedSideWidth = AppShellTopBar.resolveSideWidth(
      actionCount: actions.length,
      hasLeading: true,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppShellTopBar(
          title: title,
          leading: IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: '返回',
          ),
          actions: actions,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Padding(
            padding: EdgeInsets.fromLTRB(
              resolvedSideWidth + 8,
              0,
              resolvedSideWidth + 8,
              8,
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
