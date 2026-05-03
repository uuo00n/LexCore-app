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
  static const _androidFallbackApiUrl = 'http://10.0.2.2:8000/api/v1';
  static const _fallbackApiUrl = 'http://115.190.4.230:8000/api/v1';
  static const _webDefaultApiPath = '/api/v1';

  static String get baseApiUrl {
    return resolveBaseApiUrl(
      configuredBaseApiUrl: _configuredBaseApiUrl,
      isWeb: kIsWeb,
      platform: defaultTargetPlatform,
    );
  }

  static String resolveBaseApiUrl({
    required String configuredBaseApiUrl,
    required bool isWeb,
    required TargetPlatform platform,
  }) {
    final configured = configuredBaseApiUrl.trim();
    if (configured.isNotEmpty) return configured;

    if (isWeb) {
      return _webDefaultApiPath;
    }

    switch (platform) {
      case TargetPlatform.android:
        return _androidFallbackApiUrl;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return _fallbackApiUrl;
    }
  }
}
