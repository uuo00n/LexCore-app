import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lexcore/app/theme/app_colors.dart';
import 'package:lexcore/app/theme/app_theme.dart';

void main() {
  testWidgets('light theme app bar uses high-contrast colors', (tester) async {
    final appBarTheme = AppTheme.light().appBarTheme;

    expect(appBarTheme.backgroundColor, AppColors.surface);
    expect(appBarTheme.foregroundColor, AppColors.onSurface);
    expect(appBarTheme.scrolledUnderElevation, 0);
    expect(appBarTheme.surfaceTintColor, Colors.transparent);
    expect(appBarTheme.iconTheme?.color, AppColors.onSurface);
    expect(appBarTheme.actionsIconTheme?.color, AppColors.onSurface);
    expect(appBarTheme.titleTextStyle?.color, AppColors.onSurface);
  });

  testWidgets('dark theme app bar uses high-contrast colors', (tester) async {
    final appBarTheme = AppTheme.dark().appBarTheme;

    expect(appBarTheme.backgroundColor, AppColors.backgroundDark);
    expect(appBarTheme.foregroundColor, Colors.white);
    expect(appBarTheme.scrolledUnderElevation, 0);
    expect(appBarTheme.surfaceTintColor, Colors.transparent);
    expect(appBarTheme.iconTheme?.color, Colors.white);
    expect(appBarTheme.actionsIconTheme?.color, Colors.white);
    expect(appBarTheme.titleTextStyle?.color, Colors.white);
  });
}
