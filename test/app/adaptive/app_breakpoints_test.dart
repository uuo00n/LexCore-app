import 'package:flutter_test/flutter_test.dart';

import 'package:lexcore/app/adaptive/app_breakpoints.dart';

void main() {
  group('AppBreakpoints', () {
    test('classifies viewport width correctly', () {
      expect(AppBreakpoints.fromWidth(390), AppViewportSize.compact);
      expect(AppBreakpoints.fromWidth(820), AppViewportSize.medium);
      expect(AppBreakpoints.fromWidth(1280), AppViewportSize.expanded);
      expect(AppBreakpoints.fromWidth(1600), AppViewportSize.ultra);
    });

    test('returns expected max content width', () {
      expect(
        AppBreakpoints.maxContentWidth(AppViewportSize.compact),
        double.infinity,
      );
      expect(AppBreakpoints.maxContentWidth(AppViewportSize.medium), 920);
      expect(AppBreakpoints.maxContentWidth(AppViewportSize.expanded), 1160);
      expect(AppBreakpoints.maxContentWidth(AppViewportSize.ultra), 1320);
    });

    test('shows sidebar for non-compact viewports', () {
      expect(
        AppBreakpoints.showDesktopSidebar(AppViewportSize.compact),
        isFalse,
      );
      expect(AppBreakpoints.showDesktopSidebar(AppViewportSize.medium), isTrue);
      expect(
        AppBreakpoints.showDesktopSidebar(AppViewportSize.expanded),
        isTrue,
      );
    });
  });
}
