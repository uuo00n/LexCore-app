import 'package:flutter/material.dart';

import 'profile_avatar_image_provider_stub.dart'
    if (dart.library.io) 'profile_avatar_image_provider_io.dart'
    as impl;

ImageProvider<Object>? buildLocalAvatarImageProvider(String? avatarPath) {
  if (avatarPath == null || avatarPath.trim().isEmpty) {
    return null;
  }
  return impl.buildLocalAvatarImageProvider(avatarPath);
}
