import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'package:lexcore/app/motion/app_motion_widgets.dart';

class AppLoadingState extends StatelessWidget {
  const AppLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return AppFadeSlideIn(
      beginOffset: const Offset(0, 0.02),
      child: ListView.separated(
        itemCount: 3,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            highlightColor: Theme.of(context).colorScheme.surfaceContainerLow,
            child: Container(
              height: 88,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          );
        },
      ),
    );
  }
}
