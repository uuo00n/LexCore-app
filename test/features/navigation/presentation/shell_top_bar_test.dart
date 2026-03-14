import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lexcore/features/history/presentation/pages/history_page.dart';
import 'package:lexcore/features/home/presentation/pages/home_page.dart';
import 'package:lexcore/features/profile/presentation/pages/profile_page.dart';
import 'package:lexcore/features/search/presentation/pages/legal_search_page.dart';

void main() {
  const viewportWidth = 390.0;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pumpShellPage(WidgetTester tester, Widget page) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(ProviderScope(child: MaterialApp(home: page)));
    await tester.pump(const Duration(milliseconds: 900));
  }

  void expectTitleCentered(WidgetTester tester, String title) {
    final centerX = tester.getCenter(find.text(title)).dx;
    expect(centerX, closeTo(viewportWidth / 2, 2.0));
  }

  testWidgets('home top bar has unified title and no sidebar menu button', (
    tester,
  ) async {
    await pumpShellPage(tester, const HomePage());

    expect(find.text('LexCore'), findsOneWidget);
    expect(find.byIcon(Icons.menu_rounded), findsNothing);
    expectTitleCentered(tester, 'LexCore');
  });

  testWidgets('search top bar has unified title and no sidebar menu button', (
    tester,
  ) async {
    await pumpShellPage(tester, const LegalSearchPage());

    expect(find.text('LexCore 法条检索'), findsOneWidget);
    expect(find.byIcon(Icons.menu), findsNothing);
    expectTitleCentered(tester, 'LexCore 法条检索');
  });

  testWidgets('history top bar has unified title and no sidebar menu button', (
    tester,
  ) async {
    await pumpShellPage(tester, const HistoryPage());

    expect(find.text('历史记录'), findsOneWidget);
    expect(find.byIcon(Icons.menu_rounded), findsNothing);
    expectTitleCentered(tester, '历史记录');
  });

  testWidgets('profile top bar has no back button', (tester) async {
    await pumpShellPage(tester, const ProfilePage());

    expect(find.text('个人资料'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsNothing);
    expectTitleCentered(tester, '个人资料');
  });
}
