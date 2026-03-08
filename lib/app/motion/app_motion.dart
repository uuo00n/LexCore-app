import 'package:flutter/animation.dart';

class AppMotion {
  const AppMotion._();

  // Route level motion: keep transitions crisp but not abrupt.
  static const Duration pageTransition = Duration(milliseconds: 280);
  static const Duration pageTransitionShort = Duration(milliseconds: 240);
  static const Duration modalTransition = Duration(milliseconds: 260);

  // Bottom navigation and tab switching rhythm.
  static const Duration tabSwitch = Duration(milliseconds: 220);
  static const Duration navItem = Duration(milliseconds: 200);

  // Component interactions and state changes.
  static const Duration component = Duration(milliseconds: 180);
  static const Duration componentFast = Duration(milliseconds: 160);

  // Stagger timings for lightweight first-screen entrances.
  static const Duration staggerStep = Duration(milliseconds: 40);
  static const Duration staggerInitialDelay = Duration(milliseconds: 40);

  static const Curve easeOut = Curves.easeOutCubic;
  static const Curve easeInOut = Curves.easeInOutCubic;
  static const Curve emphasized = Curves.fastOutSlowIn;
}
