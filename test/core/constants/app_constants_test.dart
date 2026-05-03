import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lexcore/core/constants/app_constants.dart';

void main() {
  group('AppConstants.resolveBaseApiUrl', () {
    test('returns configured url when provided', () {
      final resolved = AppConstants.resolveBaseApiUrl(
        configuredBaseApiUrl: ' https://api.example.com/v1 ',
        isWeb: false,
        platform: TargetPlatform.android,
      );

      expect(resolved, 'https://api.example.com/v1');
    });

    test('uses same-origin api path on web when not configured', () {
      final resolved = AppConstants.resolveBaseApiUrl(
        configuredBaseApiUrl: '',
        isWeb: true,
        platform: TargetPlatform.windows,
      );

      expect(resolved, '/api/v1');
    });

    test(
      'uses android localhost bridge host on android when not configured',
      () {
        final resolved = AppConstants.resolveBaseApiUrl(
          configuredBaseApiUrl: '',
          isWeb: false,
          platform: TargetPlatform.android,
        );

        expect(resolved, 'http://10.0.2.2:8000/api/v1');
      },
    );

    test(
      'uses legacy fallback host on non-android platforms when not configured',
      () {
        final resolved = AppConstants.resolveBaseApiUrl(
          configuredBaseApiUrl: '',
          isWeb: false,
          platform: TargetPlatform.macOS,
        );

        expect(resolved, 'http://115.190.4.230:8000/api/v1');
      },
    );
  });
}
