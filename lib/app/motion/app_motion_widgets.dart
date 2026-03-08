import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'app_motion.dart';

class AppFadeSlideIn extends StatefulWidget {
  const AppFadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = AppMotion.pageTransition,
    this.beginOffset = const Offset(0, 0.04),
    this.curve = AppMotion.easeOut,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset beginOffset;
  final Curve curve;

  @override
  State<AppFadeSlideIn> createState() => _AppFadeSlideInState();
}

class _AppFadeSlideInState extends State<AppFadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    final curve = CurvedAnimation(parent: _controller, curve: widget.curve);
    _opacity = Tween<double>(begin: 0, end: 1).animate(curve);
    _slide = Tween<Offset>(
      begin: widget.beginOffset,
      end: Offset.zero,
    ).animate(curve);
    _play();
  }

  Future<void> _play() async {
    if (widget.delay > Duration.zero) {
      await Future<void>.delayed(widget.delay);
    }
    if (!mounted) return;
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant AppFadeSlideIn oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.delay != widget.delay ||
        oldWidget.duration != widget.duration ||
        oldWidget.beginOffset != widget.beginOffset) {
      _controller
        ..duration = widget.duration
        ..reset();
      _play();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

class AppStagger {
  const AppStagger._();

  static List<Widget> sections(
    List<Widget> children, {
    Duration initialDelay = AppMotion.staggerInitialDelay,
    Duration step = AppMotion.staggerStep,
    Offset beginOffset = const Offset(0, 0.035),
  }) {
    return List<Widget>.generate(children.length, (index) {
      final delayMs =
          initialDelay.inMilliseconds + (step.inMilliseconds * index);
      return AppFadeSlideIn(
        delay: Duration(milliseconds: delayMs),
        beginOffset: beginOffset,
        child: children[index],
      );
    });
  }
}

class AppAnimatedSwap extends StatelessWidget {
  const AppAnimatedSwap({
    super.key,
    required this.child,
    required this.stateKey,
    this.duration = AppMotion.component,
  });

  final Widget child;
  final Object stateKey;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      reverseDuration: duration,
      switchInCurve: AppMotion.easeOut,
      switchOutCurve: AppMotion.easeInOut,
      transitionBuilder: (child, animation) {
        final offset = Tween<Offset>(
          begin: const Offset(0, 0.03),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: AppMotion.easeOut));
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: offset, child: child),
        );
      },
      child: KeyedSubtree(key: ValueKey<Object>(stateKey), child: child),
    );
  }
}

class AppStaggeredListEntrance extends StatelessWidget {
  const AppStaggeredListEntrance({
    super.key,
    required this.itemBuilder,
    required this.itemCount,
    this.maxAnimatedItems = 6,
    this.separatorBuilder,
  });

  final IndexedWidgetBuilder itemBuilder;
  final int itemCount;
  final int maxAnimatedItems;
  final IndexedWidgetBuilder? separatorBuilder;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (var i = 0; i < itemCount; i++) {
      final child = itemBuilder(context, i);
      final shouldAnimate = i < maxAnimatedItems;
      if (shouldAnimate) {
        children.add(
          AppFadeSlideIn(
            delay: Duration(
              milliseconds:
                  AppMotion.staggerInitialDelay.inMilliseconds +
                  (AppMotion.staggerStep.inMilliseconds * i),
            ),
            beginOffset: const Offset(0, 0.025),
            child: child,
          ),
        );
      } else {
        children.add(child);
      }
      if (separatorBuilder != null && i < itemCount - 1) {
        children.add(separatorBuilder!(context, i));
      }
    }

    return Column(children: children);
  }
}

double motionLerp(double begin, double end, double t) {
  return begin + (end - begin) * math.max(0, math.min(1, t));
}
