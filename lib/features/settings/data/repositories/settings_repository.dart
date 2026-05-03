import 'dart:io';

import 'package:local_auth/local_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lexcore/core/constants/app_constants.dart';
import 'package:lexcore/features/settings/domain/entities/settings_state.dart';
import 'package:lexcore/shared/config/static_ui_config.dart';
import 'package:lexcore/shared/models/legal_models.dart';

abstract class SettingsPermissionClient {
  Future<SettingsNotificationPermission> notificationStatus();

  Future<SettingsNotificationPermission> requestNotificationPermission();

  Future<void> openSystemSettings();
}

class PermissionHandlerSettingsPermissionClient
    implements SettingsPermissionClient {
  const PermissionHandlerSettingsPermissionClient();

  @override
  Future<SettingsNotificationPermission> notificationStatus() async {
    return _mapStatus(await Permission.notification.status);
  }

  @override
  Future<SettingsNotificationPermission> requestNotificationPermission() async {
    return _mapStatus(await Permission.notification.request());
  }

  @override
  Future<void> openSystemSettings() async {
    await openAppSettings();
  }

  SettingsNotificationPermission _mapStatus(PermissionStatus status) {
    if (status.isGranted || status.isLimited || status.isProvisional) {
      return SettingsNotificationPermission.granted;
    }
    if (status.isPermanentlyDenied) {
      return SettingsNotificationPermission.permanentlyDenied;
    }
    if (status.isRestricted) {
      return SettingsNotificationPermission.restricted;
    }
    return SettingsNotificationPermission.denied;
  }
}

abstract class SettingsBiometricClient {
  Future<bool> isAvailable();

  Future<bool> authenticate();
}

class LocalAuthSettingsBiometricClient implements SettingsBiometricClient {
  LocalAuthSettingsBiometricClient({LocalAuthentication? localAuth})
    : _localAuth = localAuth ?? LocalAuthentication();

  final LocalAuthentication _localAuth;

  @override
  Future<bool> isAvailable() async {
    try {
      final supported = await _localAuth.isDeviceSupported();
      final canCheck = await _localAuth.canCheckBiometrics;
      return supported && canCheck;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> authenticate() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: '请验证身份以开启生物识别登录',
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } on LocalAuthException catch (error) {
      if (error.code == LocalAuthExceptionCode.noBiometricHardware ||
          error.code == LocalAuthExceptionCode.noBiometricsEnrolled ||
          error.code == LocalAuthExceptionCode.noCredentialsSet) {
        return false;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}

typedef DirectoryResolver = Future<Directory> Function();

class SettingsCacheClient {
  SettingsCacheClient({
    DirectoryResolver? temporaryDirectoryResolver,
    DirectoryResolver? cacheDirectoryResolver,
  }) : _temporaryDirectoryResolver =
           temporaryDirectoryResolver ?? getTemporaryDirectory,
       _cacheDirectoryResolver = cacheDirectoryResolver;

  final DirectoryResolver _temporaryDirectoryResolver;
  final DirectoryResolver? _cacheDirectoryResolver;

  Future<int> calculateCacheSize() async {
    var total = 0;
    for (final directory in await _targetDirectories()) {
      total += await _directorySize(directory);
    }
    return total;
  }

  Future<int> clearTemporaryCache() async {
    var clearedBytes = 0;
    for (final directory in await _targetDirectories()) {
      clearedBytes += await _directorySize(directory);
      await _clearDirectoryChildren(directory);
    }
    return clearedBytes;
  }

  Future<List<Directory>> _targetDirectories() async {
    final directories = <Directory>[];
    try {
      directories.add(await _temporaryDirectoryResolver());
    } catch (_) {
      // Ignore unavailable temp directory on unsupported platforms.
    }
    try {
      final cacheDirectory = _cacheDirectoryResolver == null
          ? await getApplicationCacheDirectory()
          : await _cacheDirectoryResolver();
      if (!directories.any((item) => item.path == cacheDirectory.path)) {
        directories.add(cacheDirectory);
      }
    } catch (_) {
      // Some desktop/web targets may not expose an app cache directory.
    }
    return directories;
  }

  Future<int> _directorySize(Directory directory) async {
    if (!await directory.exists()) {
      return 0;
    }
    var total = 0;
    await for (final entity in directory.list(recursive: true)) {
      if (entity is File) {
        try {
          total += await entity.length();
        } catch (_) {
          // File may disappear while calculating cache size.
        }
      }
    }
    return total;
  }

  Future<void> _clearDirectoryChildren(Directory directory) async {
    if (!await directory.exists()) {
      return;
    }
    await for (final entity in directory.list()) {
      try {
        await entity.delete(recursive: true);
      } catch (_) {
        // Keep going if a temp file is locked.
      }
    }
  }
}

class SettingsRepository {
  SettingsRepository({
    SharedPreferences? preferences,
    SettingsPermissionClient? permissionClient,
    SettingsBiometricClient? biometricClient,
    SettingsCacheClient? cacheClient,
  }) : _preferences = preferences,
       _permissionClient =
           permissionClient ??
           const PermissionHandlerSettingsPermissionClient(),
       _biometricClient = biometricClient ?? LocalAuthSettingsBiometricClient(),
       _cacheClient = cacheClient ?? SettingsCacheClient();

  static const _notificationsKey = 'settings_notifications_enabled';
  static const _biometricKey = 'settings_biometric_enabled';

  final SharedPreferences? _preferences;
  final SettingsPermissionClient _permissionClient;
  final SettingsBiometricClient _biometricClient;
  final SettingsCacheClient _cacheClient;

  List<SettingItem> items() => StaticUiConfig.settingsItems;

  String version() =>
      'LexCore 版本 ${AppConstants.appVersion} (${AppConstants.copyrightYear})';

  Future<SettingsState> loadState() async {
    final prefs = await _prefs();
    final notificationPermission = await checkNotificationPermission();
    final biometricAvailable = await checkBiometricAvailability();
    final cacheSize = await calculateCacheSize();
    final savedBiometric = prefs.getBool(_biometricKey) ?? false;

    return SettingsState(
      notificationsEnabled:
          prefs.getBool(_notificationsKey) ??
          notificationPermission == SettingsNotificationPermission.granted,
      biometricEnabled: savedBiometric && biometricAvailable,
      cacheSizeBytes: cacheSize,
      notificationPermissionStatus: notificationPermission,
      biometricAvailable: biometricAvailable,
    );
  }

  Future<void> saveNotificationsEnabled(bool value) async {
    await (await _prefs()).setBool(_notificationsKey, value);
  }

  Future<void> saveBiometricEnabled(bool value) async {
    await (await _prefs()).setBool(_biometricKey, value);
  }

  Future<int> calculateCacheSize() => _cacheClient.calculateCacheSize();

  Future<int> clearTemporaryCache() => _cacheClient.clearTemporaryCache();

  Future<SettingsNotificationPermission> checkNotificationPermission() {
    return _permissionClient.notificationStatus();
  }

  Future<SettingsNotificationPermission> requestNotificationPermission() {
    return _permissionClient.requestNotificationPermission();
  }

  Future<void> openSystemNotificationSettings() {
    return _permissionClient.openSystemSettings();
  }

  Future<bool> checkBiometricAvailability() {
    return _biometricClient.isAvailable();
  }

  Future<bool> authenticateBiometric() {
    return _biometricClient.authenticate();
  }

  Future<SharedPreferences> _prefs() async {
    return _preferences ?? SharedPreferences.getInstance();
  }
}
