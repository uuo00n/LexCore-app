import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class LegalMarkdownView extends StatefulWidget {
  const LegalMarkdownView({
    super.key,
    required this.assetPath,
    this.markdownData,
    this.padding = EdgeInsets.zero,
    this.styleSheet,
    this.selectable = false,
  });

  final String assetPath;
  final String? markdownData;
  final EdgeInsets padding;
  final MarkdownStyleSheet? styleSheet;
  final bool selectable;

  @override
  State<LegalMarkdownView> createState() => _LegalMarkdownViewState();
}

class _LegalMarkdownViewState extends State<LegalMarkdownView> {
  late Future<String> _markdownFuture;

  @override
  void initState() {
    super.initState();
    _markdownFuture = _loadMarkdown();
  }

  @override
  void didUpdateWidget(covariant LegalMarkdownView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.assetPath != widget.assetPath ||
        oldWidget.markdownData != widget.markdownData) {
      _markdownFuture = _loadMarkdown();
    }
  }

  Future<String> _loadMarkdown() {
    final markdownData = widget.markdownData;
    if (markdownData != null) {
      return Future<String>.value(markdownData);
    }
    return rootBundle.loadString(widget.assetPath);
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

        return Markdown(
          data: snapshot.data!,
          selectable: widget.selectable,
          padding: widget.padding,
          styleSheet: widget.styleSheet,
        );
      },
    );
  }
}
