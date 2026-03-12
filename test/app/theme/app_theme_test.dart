import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lexcore/app/theme/app_tokens_extension.dart';
import 'package:lexcore/theme.dart';

void main() {
  testWidgets('light theme app bar uses color scheme surface colors', (
    tester,
  ) async {
    final theme = MaterialTheme(ThemeData.light().textTheme).light();
    final appBarTheme = theme.appBarTheme;
    final colorScheme = theme.colorScheme;

    expect(appBarTheme.backgroundColor, colorScheme.surface);
    expect(appBarTheme.foregroundColor, colorScheme.onSurface);
    expect(appBarTheme.scrolledUnderElevation, 0);
    expect(
      appBarTheme.surfaceTintColor,
      colorScheme.surface.withValues(alpha: 0),
    );
    expect(appBarTheme.iconTheme?.color, colorScheme.onSurface);
    expect(appBarTheme.actionsIconTheme?.color, colorScheme.onSurface);
    expect(appBarTheme.titleTextStyle?.color, colorScheme.onSurface);
  });

  testWidgets('dark theme app bar uses color scheme surface colors', (
    tester,
  ) async {
    final theme = MaterialTheme(ThemeData.light().textTheme).dark();
    final appBarTheme = theme.appBarTheme;
    final colorScheme = theme.colorScheme;

    expect(appBarTheme.backgroundColor, colorScheme.surface);
    expect(appBarTheme.foregroundColor, colorScheme.onSurface);
    expect(appBarTheme.scrolledUnderElevation, 0);
    expect(
      appBarTheme.surfaceTintColor,
      colorScheme.surface.withValues(alpha: 0),
    );
    expect(appBarTheme.iconTheme?.color, colorScheme.onSurface);
    expect(appBarTheme.actionsIconTheme?.color, colorScheme.onSurface);
    expect(appBarTheme.titleTextStyle?.color, colorScheme.onSurface);
  });

  testWidgets('theme provides app tokens extension', (tester) async {
    final theme = MaterialTheme(ThemeData.light().textTheme).light();
    final tokens = theme.extension<AppTokensExtension>();

    expect(tokens, isNotNull);
  });
}
