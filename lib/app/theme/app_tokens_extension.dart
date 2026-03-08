import 'package:flutter/material.dart';

class AppTokensExtension extends ThemeExtension<AppTokensExtension> {
  const AppTokensExtension({
    required this.success,
    required this.warning,
    required this.danger,
    required this.info,
    required this.chatAiBubble,
    required this.chatUserBubble,
  });

  final Color success;
  final Color warning;
  final Color danger;
  final Color info;
  final Color chatAiBubble;
  final Color chatUserBubble;

  @override
  ThemeExtension<AppTokensExtension> copyWith({
    Color? success,
    Color? warning,
    Color? danger,
    Color? info,
    Color? chatAiBubble,
    Color? chatUserBubble,
  }) {
    return AppTokensExtension(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      info: info ?? this.info,
      chatAiBubble: chatAiBubble ?? this.chatAiBubble,
      chatUserBubble: chatUserBubble ?? this.chatUserBubble,
    );
  }

  @override
  ThemeExtension<AppTokensExtension> lerp(
    covariant ThemeExtension<AppTokensExtension>? other,
    double t,
  ) {
    if (other is! AppTokensExtension) return this;

    return AppTokensExtension(
      success: Color.lerp(success, other.success, t) ?? success,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
      danger: Color.lerp(danger, other.danger, t) ?? danger,
      info: Color.lerp(info, other.info, t) ?? info,
      chatAiBubble:
          Color.lerp(chatAiBubble, other.chatAiBubble, t) ?? chatAiBubble,
      chatUserBubble:
          Color.lerp(chatUserBubble, other.chatUserBubble, t) ?? chatUserBubble,
    );
  }
}
