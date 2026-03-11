import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lexcore/features/settings/data/repositories/settings_repository.dart';
import 'package:lexcore/features/settings/domain/entities/settings_profile.dart';
import 'package:lexcore/features/settings/domain/entities/settings_state.dart';
import 'package:lexcore/shared/models/legal_models.dart';
import 'package:lexcore/shared/services/mock/mock_providers.dart';

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
  return SettingsRepository(ref.watch(mockLegalRepositoryProvider));
});

final settingsItemsProvider = Provider<List<SettingItem>>((ref) {
  return ref.watch(settingsRepositoryProvider).items();
});

final settingsProfileProvider = Provider<SettingsProfile>((ref) {
  return ref.watch(settingsRepositoryProvider).profile();
});

final settingsVersionProvider = Provider<String>((ref) {
  return ref.watch(settingsRepositoryProvider).version();
});
