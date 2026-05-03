import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:lexcore/shared/widgets/app_page_scaffold.dart';

enum InAppWebViewKind { html, pdf }

enum InAppWebViewLoadState { loading, ready, error }

class InAppWebViewRouteArgs {
  const InAppWebViewRouteArgs({
    required this.title,
    required this.url,
    required this.kind,
  });

  final String title;
  final String url;
  final InAppWebViewKind kind;
}

class InAppWebViewPage extends StatefulWidget {
  const InAppWebViewPage({
    super.key,
    required this.title,
    required this.url,
    required this.kind,
    this.loadStateListenable,
    this.webViewChild,
    this.onReloadOverride,
    this.onOpenExternalOverride,
    this.isAndroidOverride,
  });

  final String title;
  final String url;
  final InAppWebViewKind kind;

  // Testing hooks.
  final ValueNotifier<InAppWebViewLoadState>? loadStateListenable;
  final Widget? webViewChild;
  final Future<void> Function()? onReloadOverride;
  final Future<bool> Function(Uri uri)? onOpenExternalOverride;
  final bool? isAndroidOverride;

  @override
  State<InAppWebViewPage> createState() => _InAppWebViewPageState();
}

class _InAppWebViewPageState extends State<InAppWebViewPage> {
  late final ValueNotifier<InAppWebViewLoadState> _loadStateNotifier;
  late final bool _ownsLoadStateNotifier;
  WebViewController? _controller;
  Uri? _uri;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _ownsLoadStateNotifier = widget.loadStateListenable == null;
    _loadStateNotifier =
        widget.loadStateListenable ??
        ValueNotifier<InAppWebViewLoadState>(InAppWebViewLoadState.loading);
    _initializeWebView();
  }

  @override
  void dispose() {
    if (_ownsLoadStateNotifier) {
      _loadStateNotifier.dispose();
    }
    super.dispose();
  }

  void _initializeWebView() {
    _uri = _normalizeUriForAndroidEmulator(Uri.tryParse(widget.url));
    if (widget.webViewChild != null) {
      return;
    }
    if (_uri == null || !_isHttpUri(_uri!)) {
      _errorMessage = '链接无效，请稍后重试。';
      _loadStateNotifier.value = InAppWebViewLoadState.error;
      return;
    }

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            _loadStateNotifier.value = InAppWebViewLoadState.loading;
          },
          onPageFinished: (_) {
            _loadStateNotifier.value = InAppWebViewLoadState.ready;
          },
          onWebResourceError: (error) {
            _errorMessage = error.description.isEmpty
                ? '页面加载失败，请稍后重试。'
                : error.description;
            _loadStateNotifier.value = InAppWebViewLoadState.error;
          },
          onNavigationRequest: (request) {
            final uri = Uri.tryParse(request.url);
            if (uri == null) {
              return NavigationDecision.prevent;
            }
            if (_isHttpUri(uri)) {
              return NavigationDecision.navigate;
            }
            unawaited(_openInBrowser(uri));
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(_uri!);

    _controller = controller;
  }

  Uri? _normalizeUriForAndroidEmulator(Uri? uri) {
    if (uri == null) {
      return null;
    }
    final isAndroid = widget.isAndroidOverride ?? Platform.isAndroid;
    if (!isAndroid) {
      return uri;
    }
    if (!_isLoopbackHost(uri.host)) {
      return uri;
    }
    return uri.replace(host: '10.0.2.2');
  }

  bool _isLoopbackHost(String host) {
    final normalized = host.trim().toLowerCase();
    return normalized == '127.0.0.1' ||
        normalized == 'localhost' ||
        normalized == '::1';
  }

  bool _isHttpUri(Uri uri) =>
      uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');

  Future<void> _reload() async {
    if (widget.onReloadOverride != null) {
      _loadStateNotifier.value = InAppWebViewLoadState.loading;
      await widget.onReloadOverride!.call();
      return;
    }
    if (_controller == null || _uri == null) {
      _errorMessage = '页面无法重新加载，请稍后重试。';
      _loadStateNotifier.value = InAppWebViewLoadState.error;
      return;
    }
    _loadStateNotifier.value = InAppWebViewLoadState.loading;
    await _controller!.loadRequest(_uri!);
  }

  Future<bool> _openInBrowser([Uri? target]) async {
    final uri = target ?? _uri;
    if (uri == null) {
      return false;
    }
    if (widget.onOpenExternalOverride != null) {
      return widget.onOpenExternalOverride!(uri);
    }
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<InAppWebViewLoadState>(
      valueListenable: _loadStateNotifier,
      builder: (context, loadState, _) {
        return AppPageScaffold(
          title: widget.title,
          actions: [
            IconButton(
              onPressed: _reload,
              tooltip: '刷新',
              icon: const Icon(Icons.refresh_rounded),
            ),
            IconButton(
              onPressed: () async {
                final opened = await _openInBrowser();
                if (!opened && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('浏览器打开失败，请稍后重试')),
                  );
                }
              },
              tooltip: '浏览器打开',
              icon: const Icon(Icons.open_in_browser_rounded),
            ),
          ],
          bodyPadding: EdgeInsets.zero,
          body: switch (loadState) {
            InAppWebViewLoadState.error => _InAppWebViewErrorState(
              message: _errorMessage ?? '页面加载失败，请稍后重试。',
              onRetry: _reload,
              onOpenExternal: () async {
                final opened = await _openInBrowser();
                if (!opened && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('浏览器打开失败，请稍后重试')),
                  );
                }
              },
            ),
            _ => Stack(
              children: [
                Positioned.fill(
                  child:
                      widget.webViewChild ??
                      (_controller == null
                          ? const SizedBox.shrink()
                          : WebViewWidget(controller: _controller!)),
                ),
                if (loadState == InAppWebViewLoadState.loading)
                  Positioned.fill(
                    child: ColoredBox(
                      color: Theme.of(context).colorScheme.surface,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                  ),
              ],
            ),
          },
        );
      },
    );
  }
}

class _InAppWebViewErrorState extends StatelessWidget {
  const _InAppWebViewErrorState({
    required this.message,
    required this.onRetry,
    required this.onOpenExternal,
  });

  final String message;
  final Future<void> Function() onRetry;
  final Future<void> Function() onOpenExternal;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.language_rounded, size: 40),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('重新加载')),
            const SizedBox(height: 8),
            TextButton(onPressed: onOpenExternal, child: const Text('在浏览器中打开')),
          ],
        ),
      ),
    );
  }
}
