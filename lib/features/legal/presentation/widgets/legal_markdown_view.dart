import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class LegalMarkdownView extends StatefulWidget {
  const LegalMarkdownView({
    super.key,
    required this.assetPath,
    this.padding = EdgeInsets.zero,
    this.controller,
    this.onProgressChanged,
    this.styleSheet,
    this.selectable = true,
    this.physics,
  });

  final String assetPath;
  final EdgeInsets padding;
  final ScrollController? controller;
  final ValueChanged<double>? onProgressChanged;
  final MarkdownStyleSheet? styleSheet;
  final bool selectable;
  final ScrollPhysics? physics;

  @override
  State<LegalMarkdownView> createState() => _LegalMarkdownViewState();
}

class _LegalMarkdownViewState extends State<LegalMarkdownView> {
  late Future<String> _markdownFuture;
  late ScrollController _controller;
  late bool _ownsController;
  double _lastReportedProgress = -1;

  @override
  void initState() {
    super.initState();
    _markdownFuture = rootBundle.loadString(widget.assetPath);
    _setupController();
  }

  @override
  void didUpdateWidget(covariant LegalMarkdownView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.assetPath != widget.assetPath) {
      _markdownFuture = rootBundle.loadString(widget.assetPath);
    }
    if (oldWidget.controller != widget.controller) {
      _tearDownController();
      _setupController();
    }
  }

  @override
  void dispose() {
    _tearDownController();
    super.dispose();
  }

  void _setupController() {
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? ScrollController();
    _controller.addListener(_emitProgress);
  }

  void _tearDownController() {
    _controller.removeListener(_emitProgress);
    if (_ownsController) {
      _controller.dispose();
    }
  }

  void _emitProgress() {
    if (widget.onProgressChanged == null) return;

    final progress = _resolveProgress();
    if ((progress - _lastReportedProgress).abs() <= 0.001) return;

    _lastReportedProgress = progress;
    widget.onProgressChanged!(progress);
  }

  double _resolveProgress() {
    if (!_controller.hasClients) return 0;

    final maxScrollExtent = _controller.position.maxScrollExtent;
    if (maxScrollExtent <= 0) return 1;

    return (_controller.offset / maxScrollExtent).clamp(0, 1);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _markdownFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Text('条款加载失败，请稍后重试'));
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _emitProgress();
        });

        return Markdown(
          data: snapshot.data!,
          selectable: widget.selectable,
          padding: widget.padding,
          controller: _controller,
          styleSheet: widget.styleSheet,
          physics: widget.physics,
        );
      },
    );
  }
}
