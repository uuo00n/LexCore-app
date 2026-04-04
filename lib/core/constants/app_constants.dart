import 'package:flutter/foundation.dart';

class AppConstants {
  const AppConstants._();

  static const appName = '衡法智核 LexCore';
  static const appSubtitle = '智能法律服务平台';
  static const appPrimaryBrandLine = '$appName——$appSubtitle';
  static const appSlogan = '以智能内核重塑法律服务效率';
  static const appVersion = '1.0.0';
  static const copyrightYear = '2026';
  static const appAuthor = 'LexCore Team (uuo)';
  static const appCopyright = '© $copyrightYear $appAuthor';
  static const _configuredBaseApiUrl = String.fromEnvironment(
    'BASE_API_URL',
    defaultValue: '',
  );

  static String get baseApiUrl {
    final configured = _configuredBaseApiUrl.trim();
    if (configured.isNotEmpty) {
      return configured;
    }

    if (kIsWeb) {
      return 'http://localhost:8000/api/v1';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:8000/api/v1';
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return 'http://127.0.0.1:8000/api/v1';
    }
  }
}
