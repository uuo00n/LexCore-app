import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lexcore/features/cases/presentation/pages/case_list_page.dart';

void main() {
  Future<void> pumpCaseListPage(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(const MaterialApp(home: CaseListPage()));
    await tester.pump(const Duration(milliseconds: 800));
  }

  testWidgets('renders stitch-style header and filter chips', (tester) async {
    await pumpCaseListPage(tester);

    expect(find.text('案件列表'), findsOneWidget);
    expect(find.byIcon(Icons.menu), findsOneWidget);
    expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('cases_page_search_field')),
      findsOneWidget,
    );
    expect(find.text('搜索案件、当事人或案号...'), findsOneWidget);
    expect(find.text('全部'), findsOneWidget);
    expect(find.text('进行中'), findsAtLeastNWidgets(1));
    expect(find.text('已结案'), findsAtLeastNWidgets(1));
    expect(find.text('草稿'), findsOneWidget);
    expect(find.text('更多'), findsOneWidget);
  });

  testWidgets('renders case cards and progress content', (tester) async {
    await pumpCaseListPage(tester);

    final listFinder = find.byKey(const ValueKey<String>('cases_page_list'));

    expect(
      find.byKey(const ValueKey<String>('cases_page_card_0')),
      findsOneWidget,
    );
    expect(find.text('案号: (2023) 沪01民初1024号'), findsOneWidget);
    expect(find.text('65%'), findsOneWidget);

    await tester.drag(listFinder, const Offset(0, -360));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('cases_page_card_3')),
      findsOneWidget,
    );
    expect(find.text('跨境电商劳动合同仲裁案件'), findsOneWidget);
    expect(find.text('45%'), findsOneWidget);
  });
}
