import 'package:flutter/material.dart';

import 'package:lexcore/shared/components/app_surface_card.dart';

class AppListTileItem extends StatelessWidget {
  const AppListTileItem({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: leading,
        title: Text(title),
        subtitle: subtitle == null ? null : Text(subtitle!),
        trailing: trailing ?? const Icon(Icons.chevron_right),
      ),
    );
  }
}
