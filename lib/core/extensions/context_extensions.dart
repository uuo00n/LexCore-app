import 'package:flutter/material.dart';

import 'package:lexcore/app/theme/app_tokens_extension.dart';

extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);

  AppTokensExtension get tokens =>
      theme.extension<AppTokensExtension>() ??
      const AppTokensExtension(
        success: Colors.green,
        warning: Colors.orange,
        danger: Colors.red,
        info: Colors.blue,
        chatAiBubble: Color(0xFFE8ECF9),
        chatUserBubble: Color(0xFF0B50DA),
      );
}
