import 'package:flutter/material.dart';

import 'app_shell_top_bar.dart';

class AppSubPageHeader extends StatelessWidget {
  const AppSubPageHeader({
    super.key,
    required this.title,
    this.actions = const [],
    this.showBackButton = true,
    this.onBackPressed,
  });

  final String title;
  final List<Widget> actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  @override
  Widget build(BuildContext context) {
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
      ],
    );
  }
}
