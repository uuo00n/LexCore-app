import 'package:lexcore/features/splash/domain/entities/splash_state.dart';

class SplashRepository {
  const SplashRepository();

  SplashState loadConfig() => const SplashState(delayMs: 1300);
}
