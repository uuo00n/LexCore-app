import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lexcore/features/profile/presentation/pages/profile_personal_info_page.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pumpPersonalInfoPage(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: ProfilePersonalInfoPage())),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('avatar edit badge opens action sheet', (tester) async {
    await pumpPersonalInfoPage(tester);

    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();

    expect(find.text('从相册选择'), findsOneWidget);
    expect(find.text('恢复默认头像'), findsOneWidget);
  });

  testWidgets('editing valid phone updates completeness percent', (
    tester,
  ) async {
    await pumpPersonalInfoPage(tester);

    expect(find.text('80%'), findsOneWidget);

    await tester.tap(find.text('手机号').first);
    await tester.pumpAndSettle();
    final inputField = find.descendant(
      of: find.byType(InternationalPhoneNumberInput),
      matching: find.byType(TextField),
    );
    await tester.enterText(inputField, '13800138000');
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    expect(find.text('100%'), findsOneWidget);
  });

  testWidgets('phone edit input matches auth minimal style', (tester) async {
    await pumpPersonalInfoPage(tester);

    await tester.tap(find.text('手机号').first);
    await tester.pumpAndSettle();

    final phoneInput = tester.widget<InternationalPhoneNumberInput>(
      find.byType(InternationalPhoneNumberInput),
    );
    final decoration = phoneInput.inputDecoration;
    final selector = phoneInput.selectorConfig;

    expect(decoration?.filled, isTrue);
    expect(decoration?.border, isA<UnderlineInputBorder>());
    expect(decoration?.enabledBorder, isA<UnderlineInputBorder>());
    expect(decoration?.focusedBorder, isA<UnderlineInputBorder>());
    expect(selector.selectorType, PhoneInputSelectorType.BOTTOM_SHEET);
    expect(selector.setSelectorButtonAsPrefixIcon, isFalse);
    expect(selector.useEmoji, isFalse);
    expect(phoneInput.spaceBetweenSelectorAndTextField, 16);
  });

  testWidgets('phone edit sheet uses comfortable card layout', (tester) async {
    await pumpPersonalInfoPage(tester);

    await tester.tap(find.text('手机号').first);
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('phone-edit-sheet-handle')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('phone-edit-sheet-card')), findsOneWidget);
    expect(find.text('支持国际区号，号码将以国际标准保存'), findsOneWidget);
  });

  testWidgets('taiwan number renders china flag asset in editor', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'profile_personal_info_v1': jsonEncode({'phone': '+886912345678'}),
    });

    await pumpPersonalInfoPage(tester);
    await tester.tap(find.text('手机号').first);
    await tester.pumpAndSettle();

    expect(
      find.byWidgetPredicate(
        (widget) => _matchesIntlFlagAsset(widget, 'assets/flags/cn.png'),
      ),
      findsWidgets,
    );
    expect(
      find.byWidgetPredicate(
        (widget) => _matchesIntlFlagAsset(widget, 'assets/flags/tw.png'),
      ),
      findsNothing,
    );
  });

  testWidgets('name edit persists after rebuilding page', (tester) async {
    await pumpPersonalInfoPage(tester);

    await tester.tap(find.text('姓名').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '张三律师');
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    expect(find.text('张三律师'), findsWidgets);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: ProfilePersonalInfoPage())),
    );
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('profile_personal_info_v1');
    expect(raw, isNotNull);
    expect(
      ProfilePersonalInfoSnapshot.fromJson(
        jsonDecode(raw!) as Map<String, dynamic>,
      ).name,
      '张三律师',
    );
    expect(find.text('张三律师'), findsWidgets);
  });
}

class ProfilePersonalInfoSnapshot {
  const ProfilePersonalInfoSnapshot({required this.name});

  final String name;

  factory ProfilePersonalInfoSnapshot.fromJson(Map<String, dynamic> json) {
    return ProfilePersonalInfoSnapshot(name: json['name'] as String? ?? '');
  }
}

bool _matchesIntlFlagAsset(Widget widget, String assetName) {
  if (widget is! Image) {
    return false;
  }
  final image = widget.image;
  return image is AssetImage &&
      image.assetName == assetName &&
      image.package == 'intl_phone_number_input';
}
