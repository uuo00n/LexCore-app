import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lexcore/app/adaptive/app_adaptive_split_view.dart';

void main() {
  testWidgets('uses stacked layout for narrow width', (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(900, 1000);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 900,
            child: AppAdaptiveSplitView(
              primary: Container(
                key: const ValueKey('primary'),
                height: 200,
                color: Colors.blue,
              ),
              secondary: Container(
                key: const ValueKey('secondary'),
                height: 120,
                color: Colors.red,
              ),
            ),
          ),
        ),
      ),
    );

    final primary = tester.getRect(find.byKey(const ValueKey('primary')));
    final secondary = tester.getRect(find.byKey(const ValueKey('secondary')));

    expect(secondary.top, greaterThan(primary.bottom));
  });

  testWidgets('uses side-by-side layout for wide width', (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(1400, 1000);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 1200,
            child: AppAdaptiveSplitView(
              primary: Container(
                key: const ValueKey('primary'),
                height: 200,
                color: Colors.blue,
              ),
              secondary: Container(
                key: const ValueKey('secondary'),
                height: 120,
                color: Colors.red,
              ),
            ),
          ),
        ),
      ),
    );

    final primary = tester.getRect(find.byKey(const ValueKey('primary')));
    final secondary = tester.getRect(find.byKey(const ValueKey('secondary')));

    expect(secondary.left, greaterThan(primary.right));
  });
}
