import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lexcore/core/network/api_client.dart';
import 'package:lexcore/features/profile/application/profile_personal_info_controller.dart';
import 'package:lexcore/features/profile/data/repositories/profile_personal_info_repository.dart';
import 'package:lexcore/features/profile/domain/entities/profile_personal_info.dart';

class _NoopApiClient extends ApiClient {
  _NoopApiClient() : super(Dio());
}

class _FakeProfilePersonalInfoRepository extends ProfilePersonalInfoRepository {
  _FakeProfilePersonalInfoRepository({ProfilePersonalInfo? initialInfo})
    : _info = initialInfo ?? _mostlyCompleteInfo(),
      super(apiClient: _NoopApiClient());

  ProfilePersonalInfo _info;

  @override
  Future<ProfilePersonalInfo> load() async {
    return _info;
  }

  @override
  Future<ProfilePersonalInfo> save(ProfilePersonalInfo info) async {
    _info = info;
    return _info;
  }

  @override
  Future<String> uploadAvatar(String filePath) async {
    return 'file_avatar_mock';
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

void main() {
  test('default profile info follows weighted completeness', () async {
    final controller = ProfilePersonalInfoController(
      repository: _FakeProfilePersonalInfoRepository(),
    );
    addTearDown(controller.dispose);

    await _waitForLoad(controller);

    expect(controller.state.loading, isFalse);
    expect(controller.state.completionPercent, 80);
    expect(controller.state.missingPriorityFields, contains('手机号'));
  });

  test('valid phone update reaches full completeness', () async {
    final controller = ProfilePersonalInfoController(
      repository: _FakeProfilePersonalInfoRepository(),
    );
    addTearDown(controller.dispose);

    await _waitForLoad(controller);
    await controller.updatePhone('+8613800138000');

    expect(controller.state.completionPercent, 100);
    expect(controller.state.missingPriorityFields, isEmpty);
  });

  test('missing high-priority fields are reported', () async {
    final controller = ProfilePersonalInfoController(
      repository: _FakeProfilePersonalInfoRepository(),
    );
    addTearDown(controller.dispose);

    await _waitForLoad(controller);
    await controller.updatePhone('+8613800138000');
    await controller.updateName('');

    expect(controller.state.completionPercent, 80);
    expect(controller.state.missingPriorityFields, contains('姓名'));
  });

  test('legacy 11-digit mainland phone is normalized to E.164', () async {
    final controller = ProfilePersonalInfoController(
      repository: _FakeProfilePersonalInfoRepository(
        initialInfo: ProfilePersonalInfo.defaults().copyWith(
          avatarFileId: 'file_avatar_mock',
          name: '张三律师',
          phone: '13800138000',
          email: 'zhangsan@example.com',
          role: '企业法务',
          organization: '华东律所',
          practiceAreas: const ['劳动法'],
          language: '简体中文',
          notificationsEnabled: true,
        ),
      ),
    );
    addTearDown(controller.dispose);

    await _waitForLoad(controller);
    await controller.updatePhone(controller.state.info.phone);

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
