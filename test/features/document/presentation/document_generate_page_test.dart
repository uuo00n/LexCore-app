import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lexcore/features/document/presentation/pages/document_generate_page.dart';
import 'package:lexcore/shared/widgets/app_searchable_dropdown_field.dart';
import 'package:lexcore/shared/widgets/app_shell_top_bar.dart';

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

  Finder findDocumentTypeDropdown() => find.byType(AppSearchableDropdownField);

  Future<void> openDocumentTypeDropdown(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.keyboard_arrow_down_rounded));
    await tester.pumpAndSettle();
  }

  testWidgets('uses unified spacing in compact layout', (tester) async {
    await pumpDocumentGeneratePage(tester, size: const Size(390, 844));

    expect(find.byType(AppShellTopBar), findsOneWidget);
    expect(find.text('LexCore 文书生成'), findsOneWidget);
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

  testWidgets('configures document type dropdown with filter and menu style', (
    tester,
  ) async {
    await pumpDocumentGeneratePage(tester, size: const Size(390, 844));

    final dropdown = tester.widget<AppSearchableDropdownField>(
      findDocumentTypeDropdown(),
    );
    expect(dropdown.value, '劳动仲裁申请书');
    expect(dropdown.menuHeight, 280);
    expect(dropdown.options.length, 4);
  });

  testWidgets('shows all document type options and updates after selection', (
    tester,
  ) async {
    await pumpDocumentGeneratePage(tester, size: const Size(390, 844));
    await openDocumentTypeDropdown(tester);

    expect(find.text('劳动仲裁申请书'), findsAtLeastNWidgets(2));
    expect(find.text('律师函'), findsOneWidget);
    expect(find.text('合同审查意见'), findsOneWidget);
    expect(find.text('企业合规报告'), findsOneWidget);

    await tester.tap(find.text('律师函').last);
    await tester.pumpAndSettle();

    expect(find.text('律师函'), findsOneWidget);
  });

  testWidgets('filters document type options and can select filtered result', (
    tester,
  ) async {
    await pumpDocumentGeneratePage(tester, size: const Size(390, 844));
    await openDocumentTypeDropdown(tester);

    final textFieldInDropdown = find.descendant(
      of: findDocumentTypeDropdown(),
      matching: find.byType(TextField),
    );

    await tester.enterText(textFieldInDropdown, '律师');
    await tester.pumpAndSettle();

    expect(find.text('律师函'), findsOneWidget);
    expect(find.text('劳动仲裁申请书'), findsNothing);
    expect(find.text('合同审查意见'), findsNothing);
    expect(find.text('企业合规报告'), findsNothing);

    await tester.tap(find.text('律师函').last);
    await tester.pumpAndSettle();

    expect(find.text('律师函'), findsOneWidget);
  });
}
