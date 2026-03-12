import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lexcore/features/search/presentation/pages/legal_search_page.dart';
import 'package:lexcore/shared/components/app_list_tile_item.dart';

void main() {
  Future<void> pumpLegalSearchPage(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: LegalSearchPage())),
    );
    await tester.pump(const Duration(milliseconds: 900));
  }

  testWidgets('search results use unified list tile style', (tester) async {
    await pumpLegalSearchPage(tester);

    expect(find.byType(AppListTileItem), findsNWidgets(2));
    expect(find.text('中华人民共和国劳动合同法 第三十条'), findsOneWidget);
    expect(find.byIcon(Icons.gavel_outlined), findsWidgets);
  });
}
