import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lexcore/app/theme/theme_mode_controller.dart';
import 'package:lexcore/core/constants/app_constants.dart';
import 'package:lexcore/theme.dart';

import 'router/app_router.dart';

class LexCoreApp extends ConsumerWidget {
  const LexCoreApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeControllerProvider);
    final materialTheme = MaterialTheme(ThemeData.light().textTheme);

    return MaterialApp.router(
      title: '${AppConstants.appName} · ${AppConstants.appSubtitle}',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: materialTheme.light(),
      darkTheme: materialTheme.dark(),
      themeMode: themeMode,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
          PointerDeviceKind.stylus,
          PointerDeviceKind.trackpad,
          PointerDeviceKind.unknown,
        },
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('zh', 'CN'), Locale('en', 'US')],
    );
  }
}
