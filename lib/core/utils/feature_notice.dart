import 'package:flutter/material.dart';

const String kFeatureInProgressMessage = '功能建设中，敬请期待';

void showFeatureInProgressSnackBar(
  BuildContext context, {
  String? featureLabel,
}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) {
    return;
  }

  final normalizedLabel = featureLabel?.trim() ?? '';
  final message = normalizedLabel.isEmpty
      ? kFeatureInProgressMessage
      : '$normalizedLabel功能建设中，敬请期待';

  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
