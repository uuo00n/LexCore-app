import 'package:flutter/material.dart';

import 'package:lexcore/app/adaptive/app_adaptive_frame.dart';
import 'package:lexcore/app/adaptive/app_breakpoints.dart';

class AppMobileCanvas extends StatelessWidget {
  const AppMobileCanvas({
    super.key,
    required this.child,
    this.maxContentWidth,
    this.padding,
  });

  final Widget child;
  final double? maxContentWidth;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewport = AppBreakpoints.fromWidth(constraints.maxWidth);
        if (viewport == AppViewportSize.compact) {
          return child;
        }

        return AppAdaptiveFrame(
          maxContentWidth:
              maxContentWidth ?? AppBreakpoints.canvasMaxWidth(viewport),
          padding: padding,
          child: child,
        );
      },
    );
  }
}
