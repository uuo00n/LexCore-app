import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lexcore/core/network/api_client.dart';
import 'package:lexcore/core/storage/local_storage.dart';
import 'package:lexcore/features/profile/data/repositories/profile_personal_info_repository.dart';
import 'package:lexcore/features/profile/domain/entities/profile_personal_info.dart';
import 'package:lexcore/features/profile/presentation/pages/profile_personal_info_page.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pumpPersonalInfoPage(
    WidgetTester tester, {
    _FakeProfilePersonalInfoRepository? repository,
  }) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    final preferences = await SharedPreferences.getInstance();
    final resolvedRepository =
        repository ?? _FakeProfilePersonalInfoRepository(preferences);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
          profilePersonalInfoRepositoryProvider.overrideWithValue(
            resolvedRepository,
          ),
        ],
        child: const MaterialApp(home: ProfilePersonalInfoPage()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('avatar edit badge opens action sheet', (tester) async {
    await pumpPersonalInfoPage(tester);

    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();

    expect(find.text('从相册选择'), findsOneWidget);
    expect(find.text('移除头像'), findsOneWidget);
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
    await pumpPersonalInfoPage(tester);
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

class _NoopApiClient extends ApiClient {
  _NoopApiClient() : super(Dio());
}

class _FakeProfilePersonalInfoRepository extends ProfilePersonalInfoRepository {
  _FakeProfilePersonalInfoRepository(this._preferences)
    : super(apiClient: _NoopApiClient(), preferences: _preferences);

  static const _storageKey = 'profile_personal_info_v1';

  final SharedPreferences _preferences;

  @override
  Future<ProfilePersonalInfo> load() async {
    final raw = _preferences.getString(_storageKey);
    if (raw == null || raw.trim().isEmpty) {
      return _mostlyCompleteInfo();
    }
    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      return _mostlyCompleteInfo();
    }
    return _infoFromJson(decoded.cast<String, dynamic>());
  }

  @override
  Future<ProfilePersonalInfo> save(ProfilePersonalInfo info) async {
    await _preferences.setString(_storageKey, jsonEncode(info.toJson()));
    return info;
  }

  @override
  Future<String> uploadAvatar(String filePath) async {
    return 'file_avatar_mock';
  }

  ProfilePersonalInfo _infoFromJson(Map<String, dynamic> json) {
    final base = _mostlyCompleteInfo();
    return base.copyWith(
      avatarPath: json['avatarPath'] as String?,
      avatarFileId: json['avatarFileId'] as String?,
      name: json['name'] as String? ?? base.name,
      phone: json['phone'] as String? ?? base.phone,
      email: json['email'] as String? ?? base.email,
      role: json['role'] as String? ?? base.role,
      organization: json['organization'] as String? ?? base.organization,
      practiceAreas: ((json['practiceAreas'] as List?) ?? base.practiceAreas)
          .whereType<String>()
          .toList(),
      language: json['language'] as String? ?? base.language,
      notificationsEnabled:
          json['notificationsEnabled'] as bool? ?? base.notificationsEnabled,
    );
  }
}

ProfilePersonalInfo _mostlyCompleteInfo() {
  return ProfilePersonalInfo.defaults().copyWith(
    avatarFileId: 'file_avatar_mock',
    name: '张三律师',
    phone: '',
    email: 'zhangsan@example.com',
    role: '企业法务',
    organization: '华东律所',
    practiceAreas: const ['劳动法'],
    language: '简体中文',
  );
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
