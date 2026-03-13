import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lexcore/features/document/presentation/pages/document_generate_page.dart';

void main() {
  Future<void> pumpDocumentGeneratePage(
    WidgetTester tester, {
    required Size size,
  }) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(const MaterialApp(home: DocumentGeneratePage()));
    await tester.pumpAndSettle();
  }

  Finder findFormListViewWithUnifiedPadding() {
    return find.byWidgetPredicate(
      (widget) =>
          widget is ListView &&
          widget.padding == const EdgeInsets.fromLTRB(16, 18, 16, 28),
      description: 'ListView with unified horizontal spacing',
    );
  }

  testWidgets('uses unified spacing in compact layout', (tester) async {
    await pumpDocumentGeneratePage(tester, size: const Size(390, 844));

    expect(findFormListViewWithUnifiedPadding(), findsOneWidget);
    expect(find.text('创建新文档'), findsOneWidget);
  });

  testWidgets('uses unified spacing in split layout for both panels', (
    tester,
  ) async {
    await pumpDocumentGeneratePage(tester, size: const Size(1280, 900));

    expect(findFormListViewWithUnifiedPadding(), findsNWidgets(2));
    expect(find.text('创建新文档'), findsOneWidget);
    expect(find.text('推荐模板'), findsOneWidget);
  });
}
