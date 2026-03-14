import 'package:flutter/material.dart';

class AppShellTopBar extends StatelessWidget {
  const AppShellTopBar({
    super.key,
    required this.title,
    this.actions = const [],
    this.leading,
    this.sideWidth,
  });

  final String title;
  final List<Widget> actions;
  final Widget? leading;
  final double? sideWidth;

  static double resolveSideWidth({
    required int actionCount,
    bool hasLeading = false,
    double? sideWidth,
  }) {
    if (sideWidth != null) return sideWidth;
    final leadingCount = hasLeading ? 1 : 0;
    final slotCount = actionCount > leadingCount ? actionCount : leadingCount;
    final resolvedSideWidth = (48.0 * slotCount) + 8.0;
    return resolvedSideWidth < 56.0 ? 56.0 : resolvedSideWidth;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolvedSideWidth = AppShellTopBar.resolveSideWidth(
      actionCount: actions.length,
      hasLeading: leading != null,
      sideWidth: sideWidth,
    );
    final titleStyle =
        theme.appBarTheme.titleTextStyle ??
        theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700);
    final iconTheme =
        theme.appBarTheme.actionsIconTheme ??
        theme.appBarTheme.iconTheme ??
        IconThemeData(color: theme.colorScheme.onSurface);

    return IconTheme.merge(
      data: iconTheme,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
        child: SizedBox(
          height: 48,
          child: Stack(
            children: [
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: resolvedSideWidth),
                  child: Center(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: titleStyle,
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: resolvedSideWidth,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: actions,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(width: resolvedSideWidth, child: leading),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
