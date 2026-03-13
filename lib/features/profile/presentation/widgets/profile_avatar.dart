import 'package:flutter/material.dart';

import 'package:lexcore/features/profile/domain/entities/profile_personal_info.dart';
import 'package:lexcore/features/profile/presentation/widgets/profile_avatar_image_provider.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.size,
    this.borderWidth = 3,
    this.iconSize = 36,
    this.avatarPath,
  });

  final double size;
  final double borderWidth;
  final double iconSize;
  final String? avatarPath;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final localImage = buildLocalAvatarImageProvider(avatarPath);

    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.14),
          width: borderWidth,
        ),
      ),
      child: ClipOval(
        child: localImage == null
            ? Image.network(
                defaultProfileAvatarUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _AvatarFallback(dark: dark, iconSize: iconSize);
                },
              )
            : Image(
                image: localImage,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _AvatarFallback(dark: dark, iconSize: iconSize);
                },
              ),
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback({required this.dark, required this.iconSize});

  final bool dark;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: dark
          ? Theme.of(context).colorScheme.surfaceContainer
          : Theme.of(context).colorScheme.surfaceContainerLowest,
      alignment: Alignment.center,
      child: Icon(
        Icons.person,
        size: iconSize,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
