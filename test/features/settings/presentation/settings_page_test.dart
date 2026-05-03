import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lexcore/app/router/route_names.dart';
import 'package:lexcore/features/settings/application/settings_controller.dart';
import 'package:lexcore/features/settings/data/repositories/settings_repository.dart';
import 'package:lexcore/features/settings/domain/entities/settings_state.dart';
import 'package:lexcore/features/settings/presentation/pages/help_support_page.dart';
import 'package:lexcore/features/settings/presentation/pages/settings_page.dart';

class _FakePermissionClient implements SettingsPermissionClient {
  _FakePermissionClient({
    this.status = SettingsNotificationPermission.denied,
    this.requestResult = SettingsNotificationPermission.granted,
  });

  SettingsNotificationPermission status;
  SettingsNotificationPermission requestResult;

  @override
  Future<SettingsNotificationPermission> notificationStatus() async => status;

  @override
  Future<void> openSystemSettings() async {}

  @override
  Future<SettingsNotificationPermission> requestNotificationPermission() async {
    status = requestResult;
    return requestResult;
  }
}

class _FakeBiometricClient implements SettingsBiometricClient {
  _FakeBiometricClient({this.available = true, this.authenticated = true});

  bool available;
  bool authenticated;

  @override
  Future<bool> authenticate() async => authenticated;

  @override
  Future<bool> isAvailable() async => available;
}

class _FakeSettingsRepository extends SettingsRepository {
  _FakeSettingsRepository({
    required this.preferences,
    _FakePermissionClient? permissionClient,
    _FakeBiometricClient? biometricClient,
    this.cacheSizeBytes = 0,
  }) : permissionClient = permissionClient ?? _FakePermissionClient(),
       biometricClient = biometricClient ?? _FakeBiometricClient(),
       super(
         preferences: preferences,
         permissionClient: permissionClient ?? _FakePermissionClient(),
         biometricClient: biometricClient ?? _FakeBiometricClient(),
       );

  final SharedPreferences preferences;
  final _FakePermissionClient permissionClient;
  final _FakeBiometricClient biometricClient;
  int cacheSizeBytes;

  @override
  Future<SettingsState> loadState() async {
    final notificationPermission = await checkNotificationPermission();
    final biometricAvailable = await checkBiometricAvailability();
    return SettingsState(
      notificationsEnabled:
          preferences.getBool('settings_notifications_enabled') ??
          notificationPermission == SettingsNotificationPermission.granted,
      biometricEnabled:
          (preferences.getBool('settings_biometric_enabled') ?? false) &&
          biometricAvailable,
      cacheSizeBytes: cacheSizeBytes,
      notificationPermissionStatus: notificationPermission,
      biometricAvailable: biometricAvailable,
    );
  }

  @override
  Future<void> saveNotificationsEnabled(bool value) {
    return preferences.setBool('settings_notifications_enabled', value);
  }

  @override
  Future<void> saveBiometricEnabled(bool value) {
    return preferences.setBool('settings_biometric_enabled', value);
  }

  @override
  Future<int> calculateCacheSize() async => cacheSizeBytes;

  @override
  Future<int> clearTemporaryCache() async {
    final clearedBytes = cacheSizeBytes;
    cacheSizeBytes = 0;
    return clearedBytes;
  }

  @override
  Future<SettingsNotificationPermission> checkNotificationPermission() {
    return permissionClient.notificationStatus();
  }

  @override
  Future<SettingsNotificationPermission> requestNotificationPermission() {
    return permissionClient.requestNotificationPermission();
  }

  @override
  Future<bool> checkBiometricAvailability() {
    return biometricClient.isAvailable();
  }

  @override
  Future<bool> authenticateBiometric() {
    return biometricClient.authenticate();
  }
}

Future<_FakeSettingsRepository> _buildRepository({
  SharedPreferences? preferences,
  _FakePermissionClient? permissionClient,
  _FakeBiometricClient? biometricClient,
  int cacheSizeBytes = 0,
}) async {
  final prefs = preferences ?? await SharedPreferences.getInstance();
  return _FakeSettingsRepository(
    preferences: prefs,
    permissionClient: permissionClient,
    biometricClient: biometricClient,
    cacheSizeBytes: cacheSizeBytes,
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pumpSettings(
    WidgetTester tester, {
    required Size surfaceSize,
    SettingsRepository? repository,
  }) async {
    await tester.binding.setSurfaceSize(surfaceSize);
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    final resolvedRepository = repository ?? await _buildRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(resolvedRepository),
        ],
        child: MaterialApp.router(
          routerConfig: GoRouter(
            initialLocation: RouteNames.settingsPath,
            routes: [
              GoRoute(
                path: RouteNames.settingsPath,
                name: RouteNames.settings,
                builder: (context, state) => const SettingsPage(),
              ),
              GoRoute(
                path: RouteNames.helpSupportPath,
                name: RouteNames.helpSupport,
                builder: (context, state) => const HelpSupportPage(),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  testWidgets('mobile settings keeps only system entries and single exit', (
    tester,
  ) async {
    await pumpSettings(tester, surfaceSize: const Size(390, 844));

    expect(find.text('编辑资料'), findsNothing);
    expect(find.text('帮助与支持'), findsOneWidget);
    expect(find.text('退出登录'), findsOneWidget);
  });

  testWidgets('desktop split panel removes duplicated quick actions', (
    tester,
  ) async {
    await pumpSettings(tester, surfaceSize: const Size(1280, 800));

    expect(find.text('帮助与支持'), findsOneWidget);
    expect(find.text('版本信息'), findsOneWidget);
    expect(find.text('缓存管理'), findsOneWidget);
    expect(find.text('隐私政策'), findsOneWidget);
    expect(find.text('服务条款'), findsOneWidget);
    expect(find.text('编辑资料'), findsNothing);
    expect(find.text('退出登录'), findsOneWidget);
  });

  testWidgets('theme mode subtitle shows default label', (tester) async {
    await pumpSettings(tester, surfaceSize: const Size(390, 844));

    expect(find.text('主题模式'), findsOneWidget);
    expect(find.text('跟随系统'), findsOneWidget);
  });

  testWidgets('tapping theme mode opens bottom sheet with three options', (
    tester,
  ) async {
    await pumpSettings(tester, surfaceSize: const Size(390, 844));

    await tester.tap(find.text('主题模式'));
    await tester.pumpAndSettle();

    expect(find.text('跟随系统'), findsWidgets);
    expect(find.text('浅色模式'), findsOneWidget);
    expect(find.text('深色模式'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);
  });

  testWidgets('selecting dark mode updates subtitle', (tester) async {
    await pumpSettings(tester, surfaceSize: const Size(390, 844));

    await tester.tap(find.text('主题模式'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('深色模式'));
    await tester.pumpAndSettle();

    expect(find.text('深色模式'), findsOneWidget);
  });

  testWidgets('selecting light mode updates subtitle', (tester) async {
    await pumpSettings(tester, surfaceSize: const Size(390, 844));

    await tester.tap(find.text('主题模式'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('浅色模式'));
    await tester.pumpAndSettle();

    expect(find.text('浅色模式'), findsOneWidget);
  });

  testWidgets('cache management shows size and clears temp cache', (
    tester,
  ) async {
    final repository = await _buildRepository(cacheSizeBytes: 2048);

    await pumpSettings(
      tester,
      surfaceSize: const Size(390, 844),
      repository: repository,
    );

    await tester.tap(find.text('缓存管理'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('临时导出缓存'), findsOneWidget);
    expect(find.text('2.0 KB'), findsOneWidget);

    await tester.tap(find.text('清理缓存'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('缓存已清理'), findsOneWidget);
    expect(repository.cacheSizeBytes, 0);
  });

  testWidgets('help support entry opens help center', (tester) async {
    await pumpSettings(tester, surfaceSize: const Size(390, 844));

    await tester.tap(find.text('帮助与支持'));
    await tester.pumpAndSettle();

    expect(find.byType(HelpSupportPage), findsOneWidget);
    expect(find.text('常见问题'), findsOneWidget);
    expect(find.textContaining(HelpSupportPage.supportEmail), findsOneWidget);
    expect(find.textContaining('09:30 - 18:30'), findsOneWidget);
  });

  testWidgets('notification switch persists after permission is granted', (
    tester,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    final permissionClient = _FakePermissionClient(
      status: SettingsNotificationPermission.denied,
      requestResult: SettingsNotificationPermission.granted,
    );
    final repository = await _buildRepository(
      preferences: preferences,
      permissionClient: permissionClient,
    );
    await pumpSettings(
      tester,
      surfaceSize: const Size(390, 844),
      repository: repository,
    );

    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();

    expect(find.text('消息通知已开启'), findsOneWidget);
    expect(preferences.getBool('settings_notifications_enabled'), isTrue);

    await pumpSettings(
      tester,
      surfaceSize: const Size(390, 844),
      repository: await _buildRepository(
        preferences: preferences,
        permissionClient: permissionClient,
      ),
    );
    expect(tester.widget<Switch>(find.byType(Switch).first).value, isTrue);
  });

  testWidgets('notification switch rolls back when permission is denied', (
    tester,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    final repository = await _buildRepository(
      preferences: preferences,
      permissionClient: _FakePermissionClient(
        status: SettingsNotificationPermission.denied,
        requestResult: SettingsNotificationPermission.denied,
      ),
    );
    await pumpSettings(
      tester,
      surfaceSize: const Size(390, 844),
      repository: repository,
    );

    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();

    expect(tester.widget<Switch>(find.byType(Switch).first).value, isFalse);
    expect(find.text('通知权限未开启，请在系统设置中允许通知'), findsOneWidget);
  });

  testWidgets('biometric switch persists after successful authentication', (
    tester,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    final biometricClient = _FakeBiometricClient(
      available: true,
      authenticated: true,
    );
    final repository = await _buildRepository(
      preferences: preferences,
      biometricClient: biometricClient,
    );
    await pumpSettings(
      tester,
      surfaceSize: const Size(390, 844),
      repository: repository,
    );

    await tester.tap(find.byType(Switch).at(1));
    await tester.pumpAndSettle();

    expect(find.text('生物识别登录已开启'), findsOneWidget);
    expect(preferences.getBool('settings_biometric_enabled'), isTrue);

    await pumpSettings(
      tester,
      surfaceSize: const Size(390, 844),
      repository: await _buildRepository(
        preferences: preferences,
        biometricClient: biometricClient,
      ),
    );
    expect(tester.widget<Switch>(find.byType(Switch).at(1)).value, isTrue);
  });

  testWidgets('biometric switch stays off when device is unavailable', (
    tester,
  ) async {
    final repository = await _buildRepository(
      biometricClient: _FakeBiometricClient(available: false),
    );
    await pumpSettings(
      tester,
      surfaceSize: const Size(390, 844),
      repository: repository,
    );

    expect(tester.widget<Switch>(find.byType(Switch).at(1)).value, isFalse);
    expect(find.text('当前设备暂不可用'), findsOneWidget);
  });

  testWidgets('tapping logout opens confirmation dialog', (tester) async {
    await pumpSettings(tester, surfaceSize: const Size(390, 844));

    await tester.tap(find.text('退出登录'));
    await tester.pumpAndSettle();

    expect(find.text('确定退出登录？'), findsOneWidget);
    expect(find.text('退出后需要重新输入账号密码登录。'), findsOneWidget);
    expect(find.text('取消'), findsOneWidget);
    expect(find.text('退出登录'), findsWidgets);
    expect(
      find.byKey(const ValueKey('logout_confirm_actions_row')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('logout_confirm_cancel_button')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('logout_confirm_submit_button')),
      findsOneWidget,
    );
  });
}
