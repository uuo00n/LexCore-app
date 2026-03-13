import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lexcore/app/theme/theme_mode_controller.dart';
import 'package:lexcore/app/theme/theme_mode_repository.dart';

void main() {
  group('ThemeModeRepository', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('load returns ThemeMode.system when no value stored', () async {
      final repo = const ThemeModeRepository();
      expect(await repo.load(), ThemeMode.system);
    });

    test('save then load returns saved value', () async {
      final repo = const ThemeModeRepository();
      await repo.save(ThemeMode.dark);
      expect(await repo.load(), ThemeMode.dark);
    });

    test('save light then load returns light', () async {
      final repo = const ThemeModeRepository();
      await repo.save(ThemeMode.light);
      expect(await repo.load(), ThemeMode.light);
    });

    test('load falls back to system for unknown value', () async {
      SharedPreferences.setMockInitialValues({'app_theme_mode': 'unknown'});
      final repo = const ThemeModeRepository();
      expect(await repo.load(), ThemeMode.system);
    });
  });

  group('ThemeModeController', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('initial state is ThemeMode.system', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(themeModeControllerProvider), ThemeMode.system);
    });

    test('setThemeMode updates state to dark', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container
          .read(themeModeControllerProvider.notifier)
          .setThemeMode(ThemeMode.dark);

      expect(container.read(themeModeControllerProvider), ThemeMode.dark);
    });

    test('setThemeMode persists and restores across instances', () async {
      // Pre-populate SharedPreferences as if a previous session saved 'light'.
      SharedPreferences.setMockInitialValues({'app_theme_mode': 'light'});

      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Subscribe to force the provider to be created and start loading.
      final subscription = container.listen(
        themeModeControllerProvider,
        (_, _) {},
      );

      // Allow the async _load to complete.
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(container.read(themeModeControllerProvider), ThemeMode.light);
      subscription.close();
    });

    test('setThemeMode back to system clears override', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container
          .read(themeModeControllerProvider.notifier)
          .setThemeMode(ThemeMode.dark);
      await container
          .read(themeModeControllerProvider.notifier)
          .setThemeMode(ThemeMode.system);

      expect(container.read(themeModeControllerProvider), ThemeMode.system);
    });
  });
}
