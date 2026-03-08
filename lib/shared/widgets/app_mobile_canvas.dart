import 'package:flutter/material.dart';

class AppMobileCanvas extends StatelessWidget {
  const AppMobileCanvas({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final shouldConstrain = constraints.maxWidth > 540;
        if (!shouldConstrain) {
          return child;
        }

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border(
                  left: BorderSide(
                    color: Theme.of(context).dividerColor,
                    width: 0.6,
                  ),
                  right: BorderSide(
                    color: Theme.of(context).dividerColor,
                    width: 0.6,
                  ),
                ),
              ),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
