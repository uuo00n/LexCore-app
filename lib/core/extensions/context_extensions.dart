import 'package:flutter/material.dart';

import 'package:lexcore/app/theme/app_tokens_extension.dart';

extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;

  AppTokensExtension get tokens =>
      theme.extension<AppTokensExtension>() ??
      AppTokensExtension(
        success: colorScheme.primaryFixedDim,
        warning: colorScheme.tertiaryFixedDim,
        danger: colorScheme.error,
        info: colorScheme.secondary,
        chatAiBubble: colorScheme.surfaceContainerHigh,
        chatUserBubble: colorScheme.primary,
      );
}
