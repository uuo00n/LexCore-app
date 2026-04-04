import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lexcore/features/settings/data/repositories/settings_repository.dart';
import 'package:lexcore/features/settings/domain/entities/settings_state.dart';
import 'package:lexcore/shared/models/legal_models.dart';

class SettingsController extends StateNotifier<SettingsState> {
  SettingsController()
    : super(
        const SettingsState(
          notificationsEnabled: true,
          biometricEnabled: false,
        ),
      );

  void setNotifications(bool value) {
    state = state.copyWith(notificationsEnabled: value);
  }

  void setBiometric(bool value) {
    state = state.copyWith(biometricEnabled: value);
  }
}

final settingsControllerProvider =
    StateNotifierProvider<SettingsController, SettingsState>((ref) {
      return SettingsController();
    });

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return const SettingsRepository();
});

final settingsItemsProvider = Provider<List<SettingItem>>((ref) {
  return ref.watch(settingsRepositoryProvider).items();
});

final settingsVersionProvider = Provider<String>((ref) {
  return ref.watch(settingsRepositoryProvider).version();
});
