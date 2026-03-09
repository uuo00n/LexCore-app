import 'package:flutter/material.dart';

import 'app_breakpoints.dart';

class AppAdaptiveFrame extends StatelessWidget {
  const AppAdaptiveFrame({
    super.key,
    required this.child,
    this.maxContentWidth,
    this.padding,
    this.alignment = Alignment.topCenter,
  });

  final Widget child;
  final double? maxContentWidth;
  final EdgeInsetsGeometry? padding;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewport = AppBreakpoints.fromWidth(constraints.maxWidth);
        final resolvedMaxWidth =
            maxContentWidth ?? AppBreakpoints.maxContentWidth(viewport);
        final resolvedPadding =
            padding ??
            EdgeInsets.symmetric(
              horizontal: AppBreakpoints.horizontalPadding(viewport),
            );

        Widget current = Padding(padding: resolvedPadding, child: child);

        if (resolvedMaxWidth.isFinite) {
          current = Align(
            alignment: alignment,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: resolvedMaxWidth),
              child: current,
            ),
          );
        }

        return current;
      },
    );
  }
}
