import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_motion.dart';

enum AppRouteTransitionKind { standard, detail, modal, none }

class AppPageTransitions {
  const AppPageTransitions._();

  static Page<void> build({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
    AppRouteTransitionKind kind = AppRouteTransitionKind.standard,
  }) {
    if (kind == AppRouteTransitionKind.none) {
      return NoTransitionPage<void>(key: state.pageKey, child: child);
    }

    final platform = Theme.of(context).platform;
    final isCupertinoStyle =
        platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;

    final beginOffset = _beginOffsetFor(kind, isCupertinoStyle);
    final duration = _durationFor(kind);

    return CustomTransitionPage<void>(
      key: state.pageKey,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: AppMotion.easeOut,
        );
        final fade = Tween<double>(begin: 0, end: 1).animate(curved);
        final slide = Tween<Offset>(
          begin: beginOffset,
          end: Offset.zero,
        ).animate(curved);

        return FadeTransition(
          opacity: fade,
          child: SlideTransition(position: slide, child: child),
        );
      },
    );
  }

  static Offset _beginOffsetFor(
    AppRouteTransitionKind kind,
    bool isCupertinoStyle,
  ) {
    switch (kind) {
      case AppRouteTransitionKind.standard:
        return isCupertinoStyle
            ? const Offset(0.045, 0)
            : const Offset(0, 0.03);
      case AppRouteTransitionKind.detail:
        return isCupertinoStyle ? const Offset(0.09, 0) : const Offset(0.06, 0);
      case AppRouteTransitionKind.modal:
        return const Offset(0, 0.08);
      case AppRouteTransitionKind.none:
        return Offset.zero;
    }
  }

  static Duration _durationFor(AppRouteTransitionKind kind) {
    switch (kind) {
      case AppRouteTransitionKind.standard:
        return AppMotion.pageTransition;
      case AppRouteTransitionKind.detail:
        return AppMotion.pageTransition;
      case AppRouteTransitionKind.modal:
        return AppMotion.modalTransition;
      case AppRouteTransitionKind.none:
        return Duration.zero;
    }
  }
}
