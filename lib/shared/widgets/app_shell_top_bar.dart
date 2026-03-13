import 'package:flutter/material.dart';

class AppShellTopBar extends StatelessWidget {
  const AppShellTopBar({
    super.key,
    required this.title,
    this.actions = const [],
    this.leading,
    this.sideWidth = 56,
  });

  final String title;
  final List<Widget> actions;
  final Widget? leading;
  final double sideWidth;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
      child: SizedBox(
        height: 48,
        child: Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: sideWidth),
                child: Center(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: sideWidth,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: actions,
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(width: sideWidth, child: leading),
            ),
          ],
        ),
      ),
    );
  }
}
