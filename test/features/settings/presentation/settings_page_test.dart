import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lexcore/features/settings/presentation/pages/settings_page.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pumpSettings(
    WidgetTester tester, {
    required Size surfaceSize,
    List<Override>? overrides,
  }) async {
    await tester.binding.setSurfaceSize(surfaceSize);
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides ?? const [],
        child: const MaterialApp(home: SettingsPage()),
      ),
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

  testWidgets('theme mode subtitle shows default label', (tester) async {
    await pumpSettings(tester, surfaceSize: const Size(390, 844));

    expect(find.text('主题模式'), findsOneWidget);
    expect(find.text('跟随系统'), findsOneWidget);
  });

  testWidgets('tapping theme mode opens bottom sheet with three options', (
    tester,
  ) async {
    await pumpSettings(tester, surfaceSize: const Size(390, 844));

    await tester.tap(find.text('主题模式'));
    await tester.pumpAndSettle();

    expect(find.text('跟随系统'), findsWidgets);
    expect(find.text('浅色模式'), findsOneWidget);
    expect(find.text('深色模式'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);
  });

  testWidgets('selecting dark mode updates subtitle', (tester) async {
    await pumpSettings(tester, surfaceSize: const Size(390, 844));

    await tester.tap(find.text('主题模式'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('深色模式'));
    await tester.pumpAndSettle();

    expect(find.text('深色模式'), findsOneWidget);
  });

  testWidgets('selecting light mode updates subtitle', (tester) async {
    await pumpSettings(tester, surfaceSize: const Size(390, 844));

    await tester.tap(find.text('主题模式'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('浅色模式'));
    await tester.pumpAndSettle();

    expect(find.text('浅色模式'), findsOneWidget);
  });
}
