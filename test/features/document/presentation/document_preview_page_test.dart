import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lexcore/features/document/presentation/pages/document_preview_page.dart';
import 'package:lexcore/shared/widgets/app_shell_top_bar.dart';

void main() {
  Future<void> pumpDocumentPreviewPage(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: DocumentPreviewPage())),
    );
    await tester.pump(const Duration(milliseconds: 900));
  }

  testWidgets('document preview uses unified top bar', (tester) async {
    await pumpDocumentPreviewPage(tester);

    expect(find.byType(AppShellTopBar), findsOneWidget);
    expect(find.text('文档预览'), findsOneWidget);
    expect(find.byIcon(Icons.more_vert_rounded), findsOneWidget);
  });
}
