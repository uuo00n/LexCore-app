import 'dart:io';

import 'package:flutter/material.dart';

ImageProvider<Object>? buildLocalAvatarImageProvider(String avatarPath) {
  final file = File(avatarPath);
  if (!file.existsSync()) {
    return null;
  }
  return FileImage(file);
}
