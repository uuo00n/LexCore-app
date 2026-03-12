import 'package:flutter/material.dart';

import 'package:lexcore/app/motion/app_motion.dart';
import 'package:lexcore/app/theme/app_shadows.dart';

class AppSurfaceCard extends StatefulWidget {
  const AppSurfaceCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;

  @override
  State<AppSurfaceCard> createState() => _AppSurfaceCardState();
}

class _AppSurfaceCardState extends State<AppSurfaceCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final canTap = widget.onTap != null;
    final card = Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.7),
        ),
        boxShadow: _pressed
            ? AppShadows.cardPressed(context)
            : AppShadows.card(context),
      ),
      child: Padding(padding: widget.padding, child: widget.child),
    );

    final animatedCard = AnimatedScale(
      scale: _pressed && canTap ? 0.985 : 1,
      duration: AppMotion.componentFast,
      curve: AppMotion.easeInOut,
      child: AnimatedContainer(
        duration: AppMotion.component,
        curve: AppMotion.easeOut,
        child: card,
      ),
    );

    if (!canTap) return animatedCard;

    return Material(
      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: widget.onTap,
        onHighlightChanged: (value) {
          if (!mounted) return;
          setState(() => _pressed = value);
        },
        child: animatedCard,
      ),
    );
  }
}
