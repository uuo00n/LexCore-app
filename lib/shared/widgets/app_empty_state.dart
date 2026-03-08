import 'package:flutter/material.dart';

import 'package:lexcore/app/motion/app_motion_widgets.dart';

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({super.key, required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AppFadeSlideIn(
        beginOffset: const Offset(0, 0.03),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inbox_outlined, size: 40),
            const SizedBox(height: 8),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(message, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
