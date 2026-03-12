import 'package:flutter/material.dart';

class AppShadows {
  const AppShadows._();

  static List<BoxShadow> card(BuildContext context) => [
    BoxShadow(
      color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.08),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.03),
      blurRadius: 2,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> cardPressed(BuildContext context) => [
    BoxShadow(
      color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.07),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
    BoxShadow(
      color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.02),
      blurRadius: 2,
      offset: const Offset(0, 1),
    ),
  ];
}
