import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lexcore/features/settings/data/repositories/settings_repository.dart';
import 'package:lexcore/features/settings/domain/entities/settings_state.dart';

class _FakePermissionClient implements SettingsPermissionClient {
  @override
  Future<SettingsNotificationPermission> notificationStatus() async {
    return SettingsNotificationPermission.granted;
  }

  @override
  Future<void> openSystemSettings() async {}

  @override
  Future<SettingsNotificationPermission> requestNotificationPermission() async {
    return SettingsNotificationPermission.granted;
  }
}

class _FakeBiometricClient implements SettingsBiometricClient {
  @override
  Future<bool> authenticate() async => true;

  @override
  Future<bool> isAvailable() async => true;
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('cache size only counts temporary cache directories', () async {
    final tempDirectory = await Directory.systemTemp.createTemp(
      'settings_temp_cache',
    );
    final appCacheDirectory = await Directory.systemTemp.createTemp(
      'settings_app_cache',
    );
    addTearDown(() async {
      if (await tempDirectory.exists()) {
        await tempDirectory.delete(recursive: true);
      }
      if (await appCacheDirectory.exists()) {
        await appCacheDirectory.delete(recursive: true);
      }
    });
    await File(
      '${tempDirectory.path}/draft.md',
    ).writeAsBytes(List<int>.filled(512, 1));
    await File(
      '${appCacheDirectory.path}/export.pdf',
    ).writeAsBytes(List<int>.filled(1024, 1));

    final repository = SettingsRepository(
      preferences: await SharedPreferences.getInstance(),
      permissionClient: _FakePermissionClient(),
      biometricClient: _FakeBiometricClient(),
      cacheClient: SettingsCacheClient(
        temporaryDirectoryResolver: () async => tempDirectory,
        cacheDirectoryResolver: () async => appCacheDirectory,
      ),
    );

    expect(await repository.calculateCacheSize(), 1536);
  });

  test('clearing cache preserves shared preferences', () async {
    final tempDirectory = await Directory.systemTemp.createTemp(
      'settings_temp_cache_clear',
    );
    addTearDown(() async {
      if (await tempDirectory.exists()) {
        await tempDirectory.delete(recursive: true);
      }
    });
    await File(
      '${tempDirectory.path}/export.pdf',
    ).writeAsBytes(List<int>.filled(256, 1));
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('auth_token', 'token_001');
    await preferences.setString('app_theme_mode', 'dark');

    final repository = SettingsRepository(
      preferences: preferences,
      permissionClient: _FakePermissionClient(),
      biometricClient: _FakeBiometricClient(),
      cacheClient: SettingsCacheClient(
        temporaryDirectoryResolver: () async => tempDirectory,
        cacheDirectoryResolver: () async => tempDirectory,
      ),
    );

    expect(await repository.clearTemporaryCache(), 256);
    expect(await repository.calculateCacheSize(), 0);
    expect(preferences.getString('auth_token'), 'token_001');
    expect(preferences.getString('app_theme_mode'), 'dark');
  });
}
