import 'package:flutter/material.dart';

import 'app_motion.dart';

class AppTabTransitionContainer extends StatefulWidget {
  const AppTabTransitionContainer({
    super.key,
    required this.currentIndex,
    required this.children,
  });

  final int currentIndex;
  final List<Widget> children;

  @override
  State<AppTabTransitionContainer> createState() =>
      _AppTabTransitionContainerState();
}

class _AppTabTransitionContainerState extends State<AppTabTransitionContainer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late int _activeIndex;
  int? _outgoingIndex;
  int _direction = 1;

  @override
  void initState() {
    super.initState();
    _activeIndex = widget.currentIndex;
    _controller =
        AnimationController(
          vsync: this,
          duration: AppMotion.tabSwitch,
          value: 1,
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed && mounted) {
            setState(() {
              _outgoingIndex = null;
            });
          }
        });
  }

  @override
  void didUpdateWidget(covariant AppTabTransitionContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex == oldWidget.currentIndex) return;
    setState(() {
      _outgoingIndex = oldWidget.currentIndex;
      _activeIndex = widget.currentIndex;
      _direction = widget.currentIndex > oldWidget.currentIndex ? 1 : -1;
    });
    _controller
      ..value = 0
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: List<Widget>.generate(widget.children.length, (index) {
        final isActive = index == _activeIndex;
        final isOutgoing = index == _outgoingIndex;

        if (!isActive && !isOutgoing) {
          return Offstage(
            offstage: true,
            child: TickerMode(enabled: false, child: widget.children[index]),
          );
        }

        final animation = CurvedAnimation(
          parent: _controller,
          curve: AppMotion.easeOut,
          reverseCurve: AppMotion.easeInOut,
        );

        final enteringOffset = Tween<Offset>(
          begin: Offset(0.02 * _direction, 0),
          end: Offset.zero,
        ).animate(animation);
        final leavingOffset = Tween<Offset>(
          begin: Offset.zero,
          end: Offset(-0.02 * _direction, 0),
        ).animate(animation);

        return IgnorePointer(
          ignoring: !isActive,
          child: TickerMode(
            enabled: isActive,
            child: FadeTransition(
              opacity: isActive
                  ? Tween<double>(begin: 0, end: 1).animate(animation)
                  : Tween<double>(begin: 1, end: 0).animate(animation),
              child: SlideTransition(
                position: isActive ? enteringOffset : leavingOffset,
                child: widget.children[index],
              ),
            ),
          ),
        );
      }),
    );
  }
}
