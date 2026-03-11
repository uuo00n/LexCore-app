import 'package:flutter/material.dart';

enum AppViewportSize { compact, medium, expanded, ultra }

class AppBreakpoints {
  const AppBreakpoints._();

  static const double compactMaxWidth = 600;
  static const double mediumMaxWidth = 1024;
  static const double expandedMaxWidth = 1440;

  static AppViewportSize fromWidth(double width) {
    if (width < compactMaxWidth) {
      return AppViewportSize.compact;
    }
    if (width < mediumMaxWidth) {
      return AppViewportSize.medium;
    }
    if (width < expandedMaxWidth) {
      return AppViewportSize.expanded;
    }
    return AppViewportSize.ultra;
  }

  static double maxContentWidth(AppViewportSize viewport) {
    switch (viewport) {
      case AppViewportSize.compact:
        return double.infinity;
      case AppViewportSize.medium:
        return 920;
      case AppViewportSize.expanded:
        return 1160;
      case AppViewportSize.ultra:
        return 1320;
    }
  }

  static double canvasMaxWidth(AppViewportSize viewport) {
    switch (viewport) {
      case AppViewportSize.compact:
        return double.infinity;
      case AppViewportSize.medium:
        return 860;
      case AppViewportSize.expanded:
        return 1160;
      case AppViewportSize.ultra:
        return 1320;
    }
  }

  static double horizontalPadding(AppViewportSize viewport) {
    switch (viewport) {
      case AppViewportSize.compact:
        return 0;
      case AppViewportSize.medium:
        return 20;
      case AppViewportSize.expanded:
        return 24;
      case AppViewportSize.ultra:
        return 32;
    }
  }

  static bool showDesktopSidebar(AppViewportSize viewport) {
    return viewport != AppViewportSize.compact;
  }
}

extension AppBreakpointContext on BuildContext {
  AppViewportSize get viewportSize {
    return AppBreakpoints.fromWidth(MediaQuery.sizeOf(this).width);
  }

  bool get isCompactViewport => viewportSize == AppViewportSize.compact;

  bool get isMediumViewport => viewportSize == AppViewportSize.medium;

  bool get isLargeViewport =>
      viewportSize == AppViewportSize.expanded ||
      viewportSize == AppViewportSize.ultra;
}
