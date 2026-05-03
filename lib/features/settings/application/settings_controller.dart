import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lexcore/features/settings/data/repositories/settings_repository.dart';
import 'package:lexcore/features/settings/domain/entities/settings_state.dart';
import 'package:lexcore/shared/models/legal_models.dart';

class SettingsController extends StateNotifier<SettingsState> {
  SettingsController({required SettingsRepository repository})
    : _repository = repository,
      super(
        const SettingsState(
          notificationsEnabled: true,
          biometricEnabled: false,
          loading: true,
        ),
      ) {
    _load();
  }

  final SettingsRepository _repository;

  Future<void> refresh() async {
    await _load();
  }

  Future<void> setNotifications(bool value) async {
    state = state.copyWith(clearFeedbackMessage: true);
    if (!value) {
      await _repository.saveNotificationsEnabled(false);
      state = state.copyWith(
        notificationsEnabled: false,
        feedbackMessage: '消息通知已关闭',
      );
      return;
    }

    state = state.copyWith(loading: true);
    final permission = await _repository.requestNotificationPermission();
    if (!mounted) {
      return;
    }

    final granted = permission == SettingsNotificationPermission.granted;
    await _repository.saveNotificationsEnabled(granted);
    state = state.copyWith(
      loading: false,
      notificationsEnabled: granted,
      notificationPermissionStatus: permission,
      feedbackMessage: granted ? '消息通知已开启' : '通知权限未开启，请在系统设置中允许通知',
    );
  }

  Future<void> setBiometric(bool value) async {
    state = state.copyWith(clearFeedbackMessage: true);
    if (!value) {
      await _repository.saveBiometricEnabled(false);
      state = state.copyWith(
        biometricEnabled: false,
        feedbackMessage: '生物识别登录已关闭',
      );
      return;
    }

    state = state.copyWith(loading: true);
    final available = await _repository.checkBiometricAvailability();
    if (!mounted) {
      return;
    }
    if (!available) {
      await _repository.saveBiometricEnabled(false);
      state = state.copyWith(
        loading: false,
        biometricAvailable: false,
        biometricEnabled: false,
        feedbackMessage: '当前设备未配置可用的生物识别',
      );
      return;
    }

    final authenticated = await _repository.authenticateBiometric();
    if (!mounted) {
      return;
    }
    await _repository.saveBiometricEnabled(authenticated);
    state = state.copyWith(
      loading: false,
      biometricAvailable: available,
      biometricEnabled: authenticated,
      feedbackMessage: authenticated ? '生物识别登录已开启' : '身份验证未通过',
    );
  }

  Future<void> refreshCacheSize() async {
    final size = await _repository.calculateCacheSize();
    if (!mounted) {
      return;
    }
    state = state.copyWith(cacheSizeBytes: size);
  }

  Future<void> clearTemporaryCache() async {
    state = state.copyWith(loading: true, clearFeedbackMessage: true);
    await _repository.clearTemporaryCache();
    final size = await _repository.calculateCacheSize();
    if (!mounted) {
      return;
    }
    state = state.copyWith(
      loading: false,
      cacheSizeBytes: size,
      feedbackMessage: '缓存已清理',
    );
  }

  Future<void> openNotificationSettings() {
    return _repository.openSystemNotificationSettings();
  }

  void clearFeedbackMessage() {
    state = state.copyWith(clearFeedbackMessage: true);
  }

  Future<void> _load() async {
    state = state.copyWith(loading: true, clearFeedbackMessage: true);
    final nextState = await _repository.loadState();
    if (!mounted) {
      return;
    }
    state = nextState.copyWith(loading: false);
  }
}

final settingsControllerProvider =
    StateNotifierProvider<SettingsController, SettingsState>((ref) {
      return SettingsController(
        repository: ref.watch(settingsRepositoryProvider),
      );
    });

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});

final settingsItemsProvider = Provider<List<SettingItem>>((ref) {
  return ref.watch(settingsRepositoryProvider).items();
});

final settingsVersionProvider = Provider<String>((ref) {
  return ref.watch(settingsRepositoryProvider).version();
});
