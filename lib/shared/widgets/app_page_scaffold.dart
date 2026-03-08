import 'package:flutter/material.dart';

import 'package:lexcore/app/motion/app_motion_widgets.dart';
import 'package:lexcore/app/theme/app_spacing.dart';

import 'app_mobile_canvas.dart';

class AppPageScaffold extends StatelessWidget {
  const AppPageScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions = const [],
    this.bottomNavigationBar,
    this.showBackButton = true,
  });

  final String title;
  final Widget body;
  final List<Widget> actions;
  final Widget? bottomNavigationBar;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        leading: showBackButton ? null : const SizedBox.shrink(),
        automaticallyImplyLeading: showBackButton,
        actions: actions,
      ),
      body: AppMobileCanvas(
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: AppFadeSlideIn(
              delay: const Duration(milliseconds: 40),
              beginOffset: const Offset(0, 0.03),
              child: body,
            ),
          ),
        ),
      ),
      bottomNavigationBar: bottomNavigationBar == null
          ? null
          : AppMobileCanvas(child: bottomNavigationBar!),
    );
  }
}
