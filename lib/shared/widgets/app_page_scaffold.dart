import 'package:flutter/material.dart';

import 'package:lexcore/app/adaptive/app_breakpoints.dart';
import 'package:lexcore/app/motion/app_motion_widgets.dart';
import 'package:lexcore/app/theme/app_spacing.dart';

import 'app_mobile_canvas.dart';
import 'app_sub_page_header.dart';

class AppPageScaffold extends StatelessWidget {
  const AppPageScaffold({
    super.key,
    required this.title,
    required this.body,
    this.subtitle,
    this.actions = const [],
    this.bottomNavigationBar,
    this.showBackButton = true,
    this.onBackPressed,
    this.backgroundColor,
    this.maxContentWidth,
    this.bodyPadding,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
  });

  final String title;
  final String? subtitle;
  final Widget body;
  final List<Widget> actions;
  final Widget? bottomNavigationBar;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final double? maxContentWidth;
  final EdgeInsetsGeometry? bodyPadding;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  @override
  Widget build(BuildContext context) {
    final viewport = context.viewportSize;
    final horizontalPadding = switch (viewport) {
      AppViewportSize.compact => AppSpacing.md,
      AppViewportSize.medium => 20.0,
      AppViewportSize.expanded => 24.0,
      AppViewportSize.ultra => 28.0,
    };

    final resolvedBodyPadding =
        bodyPadding ??
        EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: AppSpacing.sm,
        );

    return Scaffold(
      backgroundColor: backgroundColor,
      body: AppMobileCanvas(
        maxContentWidth: maxContentWidth,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              AppFadeSlideIn(
                delay: const Duration(milliseconds: 20),
                beginOffset: const Offset(0, -0.02),
                child: AppSubPageHeader(
                  title: title,
                  subtitle: subtitle,
                  actions: actions,
                  showBackButton: showBackButton,
                  onBackPressed: onBackPressed,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: resolvedBodyPadding,
                  child: AppFadeSlideIn(
                    delay: const Duration(milliseconds: 40),
                    beginOffset: const Offset(0, 0.03),
                    child: body,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: bottomNavigationBar == null
          ? null
          : AppMobileCanvas(
              maxContentWidth: maxContentWidth,
              child: bottomNavigationBar!,
            ),
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }
}
