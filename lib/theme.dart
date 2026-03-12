import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:lexcore/app/theme/app_radius.dart';
import 'package:lexcore/app/theme/app_text_styles.dart';
import 'package:lexcore/app/theme/app_tokens_extension.dart';

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff475d92),
      surfaceTint: Color(0xff475d92),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffd9e2ff),
      onPrimaryContainer: Color(0xff2f4578),
      secondary: Color(0xff585e71),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffdce2f9),
      onSecondaryContainer: Color(0xff404659),
      tertiary: Color(0xff725572),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xfffdd7fa),
      onTertiaryContainer: Color(0xff593d59),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff93000a),
      surface: Color(0xfffaf8ff),
      onSurface: Color(0xff1a1b20),
      onSurfaceVariant: Color(0xff44464f),
      outline: Color(0xff757780),
      outlineVariant: Color(0xffc5c6d0),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2f3036),
      inversePrimary: Color(0xffb0c6ff),
      primaryFixed: Color(0xffd9e2ff),
      onPrimaryFixed: Color(0xff001945),
      primaryFixedDim: Color(0xffb0c6ff),
      onPrimaryFixedVariant: Color(0xff2f4578),
      secondaryFixed: Color(0xffdce2f9),
      onSecondaryFixed: Color(0xff151b2c),
      secondaryFixedDim: Color(0xffc0c6dc),
      onSecondaryFixedVariant: Color(0xff404659),
      tertiaryFixed: Color(0xfffdd7fa),
      onTertiaryFixed: Color(0xff2a122c),
      tertiaryFixedDim: Color(0xffe0bbdd),
      onTertiaryFixedVariant: Color(0xff593d59),
      surfaceDim: Color(0xffdad9e0),
      surfaceBright: Color(0xfffaf8ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff4f3fa),
      surfaceContainer: Color(0xffeeedf4),
      surfaceContainerHigh: Color(0xffe8e7ef),
      surfaceContainerHighest: Color(0xffe2e2e9),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff1c3466),
      surfaceTint: Color(0xff475d92),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff566ca1),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff2f3648),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff666d81),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff472d48),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff826381),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff740006),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffcf2c27),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffaf8ff),
      onSurface: Color(0xff0f1116),
      onSurfaceVariant: Color(0xff34363e),
      outline: Color(0xff50525a),
      outlineVariant: Color(0xff6b6d75),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2f3036),
      inversePrimary: Color(0xffb0c6ff),
      primaryFixed: Color(0xff566ca1),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff3d5387),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff666d81),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff4e5467),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff826381),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff684b68),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffc6c6cd),
      surfaceBright: Color(0xfffaf8ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff4f3fa),
      surfaceContainer: Color(0xffe8e7ef),
      surfaceContainerHigh: Color(0xffdddce3),
      surfaceContainerHighest: Color(0xffd1d1d8),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff102a5c),
      surfaceTint: Color(0xff475d92),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff31487b),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff252c3d),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff42495b),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff3c233d),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff5c405c),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff600004),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff98000a),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffaf8ff),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff000000),
      outline: Color(0xff2a2c33),
      outlineVariant: Color(0xff474951),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2f3036),
      inversePrimary: Color(0xffb0c6ff),
      primaryFixed: Color(0xff31487b),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff183163),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff42495b),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff2c3244),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff5c405c),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff432a44),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffb8b8bf),
      surfaceBright: Color(0xfffaf8ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff1f0f7),
      surfaceContainer: Color(0xffe2e2e9),
      surfaceContainerHigh: Color(0xffd4d4db),
      surfaceContainerHighest: Color(0xffc6c6cd),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffb0c6ff),
      surfaceTint: Color(0xffb0c6ff),
      onPrimary: Color(0xff162e60),
      primaryContainer: Color(0xff2f4578),
      onPrimaryContainer: Color(0xffd9e2ff),
      secondary: Color(0xffc0c6dc),
      onSecondary: Color(0xff2a3042),
      secondaryContainer: Color(0xff404659),
      onSecondaryContainer: Color(0xffdce2f9),
      tertiary: Color(0xffe0bbdd),
      onTertiary: Color(0xff412742),
      tertiaryContainer: Color(0xff593d59),
      onTertiaryContainer: Color(0xfffdd7fa),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff121318),
      onSurface: Color(0xffe2e2e9),
      onSurfaceVariant: Color(0xffc5c6d0),
      outline: Color(0xff8f9099),
      outlineVariant: Color(0xff44464f),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe2e2e9),
      inversePrimary: Color(0xff475d92),
      primaryFixed: Color(0xffd9e2ff),
      onPrimaryFixed: Color(0xff001945),
      primaryFixedDim: Color(0xffb0c6ff),
      onPrimaryFixedVariant: Color(0xff2f4578),
      secondaryFixed: Color(0xffdce2f9),
      onSecondaryFixed: Color(0xff151b2c),
      secondaryFixedDim: Color(0xffc0c6dc),
      onSecondaryFixedVariant: Color(0xff404659),
      tertiaryFixed: Color(0xfffdd7fa),
      onTertiaryFixed: Color(0xff2a122c),
      tertiaryFixedDim: Color(0xffe0bbdd),
      onTertiaryFixedVariant: Color(0xff593d59),
      surfaceDim: Color(0xff121318),
      surfaceBright: Color(0xff38393f),
      surfaceContainerLowest: Color(0xff0c0e13),
      surfaceContainerLow: Color(0xff1a1b20),
      surfaceContainer: Color(0xff1e1f25),
      surfaceContainerHigh: Color(0xff282a2f),
      surfaceContainerHighest: Color(0xff33343a),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffd1dcff),
      surfaceTint: Color(0xffb0c6ff),
      onPrimary: Color(0xff062355),
      primaryContainer: Color(0xff7a90c8),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xffd6dcf3),
      onSecondary: Color(0xff1f2536),
      secondaryContainer: Color(0xff8a90a5),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xfff7d1f4),
      onTertiary: Color(0xff351d37),
      tertiaryContainer: Color(0xffa886a6),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffd2cc),
      onError: Color(0xff540003),
      errorContainer: Color(0xffff5449),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff121318),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffdbdce6),
      outline: Color(0xffb0b1bb),
      outlineVariant: Color(0xff8e9099),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe2e2e9),
      inversePrimary: Color(0xff304679),
      primaryFixed: Color(0xffd9e2ff),
      onPrimaryFixed: Color(0xff000f30),
      primaryFixedDim: Color(0xffb0c6ff),
      onPrimaryFixedVariant: Color(0xff1c3466),
      secondaryFixed: Color(0xffdce2f9),
      onSecondaryFixed: Color(0xff0a1121),
      secondaryFixedDim: Color(0xffc0c6dc),
      onSecondaryFixedVariant: Color(0xff2f3648),
      tertiaryFixed: Color(0xfffdd7fa),
      onTertiaryFixed: Color(0xff1f0821),
      tertiaryFixedDim: Color(0xffe0bbdd),
      onTertiaryFixedVariant: Color(0xff472d48),
      surfaceDim: Color(0xff121318),
      surfaceBright: Color(0xff43444a),
      surfaceContainerLowest: Color(0xff06070c),
      surfaceContainerLow: Color(0xff1c1d23),
      surfaceContainer: Color(0xff26282d),
      surfaceContainerHigh: Color(0xff313238),
      surfaceContainerHighest: Color(0xff3c3d43),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffedefff),
      surfaceTint: Color(0xffb0c6ff),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xffacc2fd),
      onPrimaryContainer: Color(0xff000a25),
      secondary: Color(0xffedefff),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xffbcc2d8),
      onSecondaryContainer: Color(0xff050b1b),
      tertiary: Color(0xffffeafa),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xffdcb7d9),
      onTertiaryContainer: Color(0xff18031b),
      error: Color(0xffffece9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffaea4),
      onErrorContainer: Color(0xff220001),
      surface: Color(0xff121318),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff),
      outline: Color(0xffefeffa),
      outlineVariant: Color(0xffc1c2cc),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe2e2e9),
      inversePrimary: Color(0xff304679),
      primaryFixed: Color(0xffd9e2ff),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xffb0c6ff),
      onPrimaryFixedVariant: Color(0xff000f30),
      secondaryFixed: Color(0xffdce2f9),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xffc0c6dc),
      onSecondaryFixedVariant: Color(0xff0a1121),
      tertiaryFixed: Color(0xfffdd7fa),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xffe0bbdd),
      onTertiaryFixedVariant: Color(0xff1f0821),
      surfaceDim: Color(0xff121318),
      surfaceBright: Color(0xff4f5056),
      surfaceContainerLowest: Color(0xff000000),
      surfaceContainerLow: Color(0xff1e1f25),
      surfaceContainer: Color(0xff2f3036),
      surfaceContainerHigh: Color(0xff3a3b41),
      surfaceContainerHighest: Color(0xff45464c),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }

  ThemeData theme(ColorScheme colorScheme) {
    final resolvedTextTheme = GoogleFonts.publicSansTextTheme(textTheme)
        .copyWith(
          displayLarge: AppTextStyles.displayLarge,
          titleLarge: AppTextStyles.titleLarge,
          titleMedium: AppTextStyles.titleMedium,
          titleSmall: AppTextStyles.titleSmall,
          bodyMedium: AppTextStyles.bodyMedium,
          bodySmall: AppTextStyles.bodySmall,
          labelMedium: AppTextStyles.labelMedium,
        )
        .apply(
          bodyColor: colorScheme.onSurface,
          displayColor: colorScheme.onSurface,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: colorScheme.brightness,
      colorScheme: colorScheme,
      textTheme: resolvedTextTheme,
      scaffoldBackgroundColor: colorScheme.surface,
      canvasColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: colorScheme.surface.withValues(alpha: 0),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: resolvedTextTheme.titleMedium?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        actionsIconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: colorScheme.surfaceContainerLowest,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.large),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.12)),
        ),
      ),
      dividerColor: colorScheme.outline.withValues(alpha: 0.25),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: resolvedTextTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        labelStyle: resolvedTextTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.medium,
          borderSide: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.22),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.medium,
          borderSide: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.22),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.medium,
          borderSide: BorderSide(color: colorScheme.primary, width: 1.2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
          shape: const StadiumBorder(),
          textStyle: resolvedTextTheme.titleSmall,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          backgroundColor: colorScheme.surface.withValues(alpha: 0),
          shape: const CircleBorder(),
        ),
      ),
      extensions: [_tokensFor(colorScheme)],
    );
  }

  AppTokensExtension _tokensFor(ColorScheme colorScheme) {
    return AppTokensExtension(
      success: colorScheme.primaryFixedDim,
      warning: colorScheme.tertiaryFixedDim,
      danger: colorScheme.error,
      info: colorScheme.secondary,
      chatAiBubble: colorScheme.surfaceContainerHigh,
      chatUserBubble: colorScheme.primary,
    );
  }

  List<ExtendedColor> get extendedColors => [];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
