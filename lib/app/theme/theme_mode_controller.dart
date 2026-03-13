import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lexcore/app/theme/theme_mode_repository.dart';

class ThemeModeController extends StateNotifier<ThemeMode> {
  ThemeModeController({
    required ThemeModeRepository repository,
  })  : _repository = repository,
        super(ThemeMode.system) {
    _load();
  }

  final ThemeModeRepository _repository;

  Future<void> _load() async {
    try {
      state = await _repository.load();
    } catch (_) {
      // Keep default ThemeMode.system on failure.
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    try {
      await _repository.save(mode);
    } catch (_) {
      // State already updated; persistence failure is non-critical.
    }
  }
}

final themeModeRepositoryProvider = Provider<ThemeModeRepository>((ref) {
  return const ThemeModeRepository();
});

final themeModeControllerProvider =
    StateNotifierProvider<ThemeModeController, ThemeMode>((ref) {
  return ThemeModeController(
    repository: ref.watch(themeModeRepositoryProvider),
  );
});
