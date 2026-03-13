import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lexcore/features/profile/application/profile_personal_info_controller.dart';
import 'package:lexcore/features/profile/data/repositories/profile_personal_info_repository.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('default profile info follows weighted completeness', () async {
    final controller = ProfilePersonalInfoController(
      repository: const ProfilePersonalInfoRepository(),
    );
    addTearDown(controller.dispose);

    await _waitForLoad(controller);

    expect(controller.state.loading, isFalse);
    expect(controller.state.completionPercent, 80);
    expect(controller.state.missingPriorityFields, contains('手机号'));
  });

  test('valid phone update reaches full completeness', () async {
    final controller = ProfilePersonalInfoController(
      repository: const ProfilePersonalInfoRepository(),
    );
    addTearDown(controller.dispose);

    await _waitForLoad(controller);
    await controller.updatePhone('+8613800138000');

    expect(controller.state.completionPercent, 100);
    expect(controller.state.missingPriorityFields, isEmpty);
  });

  test('missing high-priority fields are reported', () async {
    final controller = ProfilePersonalInfoController(
      repository: const ProfilePersonalInfoRepository(),
    );
    addTearDown(controller.dispose);

    await _waitForLoad(controller);
    await controller.updatePhone('+8613800138000');
    await controller.updateName('');

    expect(controller.state.completionPercent, 80);
    expect(controller.state.missingPriorityFields, contains('姓名'));
  });

  test('legacy 11-digit mainland phone is normalized to E.164', () async {
    SharedPreferences.setMockInitialValues({
      'profile_personal_info_v1': jsonEncode({
        'name': '张三律师',
        'phone': '13800138000',
        'email': 'zhangsan@example.com',
        'role': '企业法务',
        'organization': '华东律所',
        'practiceAreas': ['劳动法'],
        'language': '简体中文',
        'notificationsEnabled': true,
      }),
    });

    final controller = ProfilePersonalInfoController(
      repository: const ProfilePersonalInfoRepository(),
    );
    addTearDown(controller.dispose);

    await _waitForLoad(controller);

    expect(controller.state.info.phone, '+8613800138000');
    expect(controller.state.completionPercent, 100);
    expect(controller.state.missingPriorityFields, isEmpty);
  });
}

Future<void> _waitForLoad(ProfilePersonalInfoController controller) async {
  for (var i = 0; i < 20; i++) {
    if (!controller.state.loading) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  fail('controller did not finish loading');
}
