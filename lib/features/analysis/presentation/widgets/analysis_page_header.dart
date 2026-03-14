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
    final sideWidth = actions.length > 1 ? 104.0 : 56.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
      child: Column(
        children: [
          AppShellTopBar(
            title: title,
            sideWidth: sideWidth,
            leading: Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
            actions: actions,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: sideWidth),
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
      ),
    );
  }
}
