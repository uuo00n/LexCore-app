import 'package:flutter/material.dart';

class AppAdaptiveSplitView extends StatelessWidget {
  const AppAdaptiveSplitView({
    super.key,
    required this.primary,
    required this.secondary,
    this.gap = 16,
    this.splitMinWidth = 980,
    this.secondaryMaxWidth = 360,
  });

  final Widget primary;
  final Widget secondary;
  final double gap;
  final double splitMinWidth;
  final double secondaryMaxWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < splitMinWidth) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              primary,
              SizedBox(height: gap),
              secondary,
            ],
          );
        }

        final estimatedSecondary = constraints.maxWidth * 0.32;
        final sideWidth = estimatedSecondary.clamp(300.0, secondaryMaxWidth);

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: primary),
            SizedBox(width: gap),
            SizedBox(width: sideWidth, child: secondary),
          ],
        );
      },
    );
  }
}
