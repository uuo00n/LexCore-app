import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lexcore/features/consultation/presentation/pages/consultation_stitch_detail_page.dart';
import 'package:lexcore/shared/widgets/app_shell_top_bar.dart';

void main() {
  Future<void> pumpStitchDetailPage(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(
      const MaterialApp(home: ConsultationStitchDetailPage()),
    );
    await tester.pump(const Duration(milliseconds: 900));
  }

  testWidgets('consultation stitch detail uses unified top bar', (
    tester,
  ) async {
    await pumpStitchDetailPage(tester);

    expect(find.byType(AppShellTopBar), findsOneWidget);
    expect(find.text('LexCore 解答详情'), findsOneWidget);
    expect(find.text('专业法律智能分析'), findsOneWidget);
  });
}
