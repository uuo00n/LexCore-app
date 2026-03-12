import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lexcore/features/home/presentation/pages/home_page.dart';

void main() {
  Future<void> pumpHomePage(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HomePage())),
    );
    await tester.pump(const Duration(milliseconds: 900));
  }

  Finder activityItem(int index) {
    return find.byKey(ValueKey<String>('home_recent_activity_item_$index'));
  }

  Finder activitySubtitle(int index) {
    return find.byKey(ValueKey<String>('home_recent_activity_subtitle_$index'));
  }

  testWidgets('recent activity list renders all items with mapped icons', (
    tester,
  ) async {
    await pumpHomePage(tester);

    expect(
      find.byKey(const ValueKey('home_recent_activity_list')),
      findsOneWidget,
    );
    expect(activityItem(0), findsOneWidget);
    expect(activityItem(1), findsOneWidget);
    expect(activityItem(2), findsOneWidget);
    expect(activityItem(3), findsNothing);

    expect(
      find.descendant(
        of: activityItem(0),
        matching: find.byIcon(Icons.history),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: activityItem(1),
        matching: find.byIcon(Icons.article_outlined),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: activityItem(2),
        matching: find.byIcon(Icons.analytics_outlined),
      ),
      findsOneWidget,
    );
  });

  testWidgets('recent activity subtitle includes bullet and row is tappable', (
    tester,
  ) async {
    await pumpHomePage(tester);

    for (var i = 0; i < 3; i++) {
      final subtitle = tester.widget<Text>(activitySubtitle(i));
      expect(subtitle.data, isNotNull);
      expect(subtitle.data!, contains('•'));
      expect(
        find.descendant(
          of: activityItem(i),
          matching: find.byIcon(Icons.chevron_right),
        ),
        findsOneWidget,
      );
    }

    await tester.tap(activityItem(0));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('home quick actions no longer show legal search entry', (
    tester,
  ) async {
    await pumpHomePage(tester);

    expect(find.text('法律搜索'), findsNothing);
    expect(find.text('法规与案例检索'), findsNothing);
  });
}
