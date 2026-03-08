import 'package:flutter/material.dart';

import 'package:lexcore/app/motion/app_motion.dart';

class AppPrimaryButton extends StatefulWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  State<AppPrimaryButton> createState() => _AppPrimaryButtonState();
}

class _AppPrimaryButtonState extends State<AppPrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
      child: AnimatedScale(
        scale: _pressed ? 0.985 : 1,
        duration: AppMotion.componentFast,
        curve: AppMotion.easeInOut,
        child: FilledButton.icon(
          onPressed: widget.onPressed,
          icon: widget.icon == null
              ? const SizedBox.shrink()
              : Icon(widget.icon, size: 18),
          label: Text(widget.label),
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
        ),
      ),
    );
  }
}
