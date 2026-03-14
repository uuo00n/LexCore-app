import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:lexcore/app/motion/app_motion.dart';

class AppSearchableDropdownField extends StatefulWidget {
  const AppSearchableDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.helperText,
    this.errorText,
    this.menuHeight = 280,
    this.emptyResultText = '未找到匹配项',
  });

  final String label;
  final String? value;
  final List<String> options;
  final ValueChanged<String?> onChanged;
  final String? helperText;
  final String? errorText;
  final double menuHeight;
  final String emptyResultText;

  @override
  State<AppSearchableDropdownField> createState() =>
      _AppSearchableDropdownFieldState();
}

class _AppSearchableDropdownFieldState extends State<AppSearchableDropdownField>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late final MenuController _menuController;
  late final AnimationController _animationController;
  late final Animation<double> _opacity;
  late final Animation<double> _sizeFactor;

  bool _isMenuExpanded = false;
  bool _suppressTextListener = false;
  late String? _currentValue;
  late String _lastObservedText;
  String _searchQuery = '';

  List<String> get _filteredOptions {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return widget.options;
    }
    return widget.options
        .where((option) => option.toLowerCase().contains(query))
        .toList();
  }

  bool get _disableAnimations =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
    _lastObservedText = widget.value ?? '';
    _controller = TextEditingController(text: widget.value ?? '');
    _focusNode = FocusNode()..addListener(_handleFocusChange);
    _menuController = MenuController();
    _animationController = AnimationController(
      vsync: this,
      duration: AppMotion.component,
      reverseDuration: AppMotion.componentFast,
    );
    _opacity = CurvedAnimation(
      parent: _animationController,
      curve: AppMotion.easeOut,
      reverseCurve: AppMotion.easeInOut,
    );
    _sizeFactor = CurvedAnimation(
      parent: _animationController,
      curve: AppMotion.easeOut,
      reverseCurve: AppMotion.easeInOut,
    );
    _controller.addListener(_handleTextChanged);
  }

  @override
  void didUpdateWidget(covariant AppSearchableDropdownField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _currentValue = widget.value;
      _searchQuery = '';
      _syncText(widget.value ?? '');
    }
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_handleTextChanged)
      ..dispose();
    _focusNode
      ..removeListener(_handleFocusChange)
      ..dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus) {
      _openMenu();
      return;
    }
    _restoreSelectionText();
    _closeMenu();
  }

  void _handleTextChanged() {
    if (!mounted || _suppressTextListener) {
      return;
    }
    final nextText = _controller.text;
    if (nextText == _lastObservedText) {
      return;
    }
    _lastObservedText = nextText;
    _searchQuery = _focusNode.hasFocus ? _controller.text : '';
    if (_focusNode.hasFocus) {
      _openMenu();
    }
    setState(() {});
  }

  void _syncText(String value) {
    if (_controller.text == value) {
      return;
    }
    _suppressTextListener = true;
    _controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
    _suppressTextListener = false;
    _lastObservedText = value;
    _searchQuery = '';
    if (mounted) {
      setState(() {});
    }
  }

  void _restoreSelectionText() {
    final selectedText = _currentValue ?? '';
    if (_controller.text == selectedText) {
      return;
    }
    _syncText(selectedText);
  }

  void _openMenu() {
    if (_menuController.isOpen || _isMenuExpanded) {
      return;
    }
    _menuController.open();
  }

  void _closeMenu() {
    if (!_menuController.isOpen && !_isMenuExpanded) {
      return;
    }
    _menuController.close();
  }

  Future<void> _handleOpenRequested(Offset? _, VoidCallback showOverlay) async {
    showOverlay();
    if (!mounted) {
      return;
    }
    if (_isMenuExpanded &&
        (_animationController.status == AnimationStatus.forward ||
            _animationController.status == AnimationStatus.completed)) {
      return;
    }
    setState(() {
      _isMenuExpanded = true;
    });
    if (_disableAnimations) {
      _animationController.value = 1;
      return;
    }
    await _animationController.forward(from: 0);
  }

  Future<void> _handleCloseRequested(VoidCallback hideOverlay) async {
    if (mounted && _isMenuExpanded) {
      setState(() {
        _isMenuExpanded = false;
      });
    }
    if (_disableAnimations) {
      _animationController.value = 0;
      hideOverlay();
      return;
    }
    await _animationController.reverse();
    hideOverlay();
  }

  void _handleFieldTap() {
    _searchQuery = '';
    final currentText = _controller.text;
    if (currentText.isNotEmpty && currentText == (_currentValue ?? '')) {
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: currentText.length,
      );
    }
    _focusNode.requestFocus();
    _openMenu();
  }

  void _handleTrailingTap() {
    if (_menuController.isOpen || _isMenuExpanded) {
      _focusNode.unfocus();
      _closeMenu();
      return;
    }
    _searchQuery = '';
    _focusNode.requestFocus();
    _openMenu();
  }

  void _selectOption(String option) {
    _currentValue = option;
    _syncText(option);
    widget.onChanged(option);
    _focusNode.unfocus();
    _closeMenu();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return RawMenuAnchor(
      controller: _menuController,
      onOpenRequested: _handleOpenRequested,
      onCloseRequested: _handleCloseRequested,
      overlayBuilder: (context, info) {
        final options = _filteredOptions;
        final hasResults = options.isNotEmpty;
        final itemCount = hasResults ? options.length : 1;
        final estimatedHeight = 12.0 + (itemCount * 50.0);
        final maxHeight = math.min(widget.menuHeight, estimatedHeight);

        return Positioned(
          top: info.anchorRect.bottom + 4,
          left: info.anchorRect.left,
          width: info.anchorRect.width,
          child: TextFieldTapRegion(
            child: TapRegion(
              groupId: info.tapRegionGroupId,
              onTapOutside: (_) {
                _focusNode.unfocus();
                _closeMenu();
              },
              child: FadeTransition(
                opacity: _opacity,
                child: SizeTransition(
                  axisAlignment: -1,
                  sizeFactor: _sizeFactor,
                  child: Material(
                    color: colorScheme.surfaceContainerHighest,
                    surfaceTintColor: colorScheme.surfaceTint.withValues(
                      alpha: 0,
                    ),
                    elevation: 8,
                    shadowColor: colorScheme.shadow.withValues(alpha: 0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: colorScheme.outlineVariant),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: maxHeight),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shrinkWrap: true,
                        itemCount: itemCount,
                        itemBuilder: (context, index) {
                          if (!hasResults) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              child: Text(
                                widget.emptyResultText,
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            );
                          }

                          final option = options[index];
                          final isSelected = option == _currentValue;

                          return InkWell(
                            onTap: () => _selectOption(option),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      option,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge
                                          ?.copyWith(
                                            fontWeight: isSelected
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                          ),
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(
                                      Icons.check_rounded,
                                      size: 18,
                                      color: colorScheme.primary,
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      builder: (context, _, child) {
        return TextFieldTapRegion(
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            onTap: _handleFieldTap,
            decoration: _dropdownDecoration(
              context,
              label: widget.label,
              helperText: widget.helperText,
              errorText: widget.errorText,
              trailing: IconButton(
                onPressed: _handleTrailingTap,
                splashRadius: 18,
                icon: AnimatedRotation(
                  turns: _isMenuExpanded ? 0.5 : 0,
                  duration: _disableAnimations
                      ? Duration.zero
                      : AppMotion.component,
                  curve: AppMotion.easeOut,
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: _isMenuExpanded
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

InputDecoration _dropdownDecoration(
  BuildContext context, {
  required String label,
  required Widget trailing,
  String? helperText,
  String? errorText,
}) {
  final colorScheme = Theme.of(context).colorScheme;
  final baseBorder = UnderlineInputBorder(
    borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(12),
      topRight: Radius.circular(12),
    ),
    borderSide: BorderSide(color: colorScheme.outlineVariant, width: 1.8),
  );

  return InputDecoration(
    labelText: label,
    helperText: helperText,
    errorText: errorText,
    helperStyle: TextStyle(color: colorScheme.onSurfaceVariant),
    filled: true,
    fillColor: colorScheme.surfaceContainerHigh,
    contentPadding: const EdgeInsets.fromLTRB(14, 22, 14, 10),
    border: baseBorder,
    enabledBorder: baseBorder,
    focusedBorder: baseBorder.copyWith(
      borderSide: BorderSide(color: colorScheme.primary, width: 2),
    ),
    suffixIcon: trailing,
  );
}
