import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lexcore/features/settings/presentation/pages/settings_page.dart';

void main() {
  Future<void> pumpSettings(
    WidgetTester tester, {
    required Size surfaceSize,
  }) async {
    await tester.binding.setSurfaceSize(surfaceSize);
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: SettingsPage())),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('mobile settings keeps only system entries and single exit', (
    tester,
  ) async {
    await pumpSettings(tester, surfaceSize: const Size(390, 844));

    expect(find.text('编辑资料'), findsNothing);
    expect(find.text('帮助与支持'), findsOneWidget);
    expect(find.text('退出登录'), findsOneWidget);
  });

  testWidgets('desktop split panel removes duplicated quick actions', (
    tester,
  ) async {
    await pumpSettings(tester, surfaceSize: const Size(1280, 800));

    expect(find.text('帮助与支持'), findsOneWidget);
    expect(find.text('版本信息'), findsOneWidget);
    expect(find.text('缓存管理'), findsOneWidget);
    expect(find.text('隐私政策'), findsOneWidget);
    expect(find.text('服务条款'), findsOneWidget);
    expect(find.text('编辑资料'), findsNothing);
    expect(find.text('退出登录'), findsOneWidget);
  });
}
