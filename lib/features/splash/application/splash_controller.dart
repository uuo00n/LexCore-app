import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lexcore/features/splash/data/repositories/splash_repository.dart';

final splashRepositoryProvider = Provider<SplashRepository>((ref) {
  return const SplashRepository();
});

final splashDelayProvider = Provider<Duration>((ref) {
  final config = ref.watch(splashRepositoryProvider).loadConfig();
  return Duration(milliseconds: config.delayMs);
});
