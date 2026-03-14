import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class AppShare {
  const AppShare._();

  static Future<ShareResult> shareText({
    required BuildContext pageContext,
    BuildContext? anchorContext,
    required String text,
    String? subject,
  }) {
    return SharePlus.instance.share(
      ShareParams(
        text: text,
        subject: subject,
        sharePositionOrigin: _shouldProvideShareOrigin
            ? _resolveShareOrigin(
                pageContext: pageContext,
                anchorContext: anchorContext,
              )
            : null,
      ),
    );
  }

  static Future<ShareResult> shareFile({
    required BuildContext pageContext,
    BuildContext? anchorContext,
    required String filePath,
    required String mimeType,
    String? fileName,
    String? text,
    String? subject,
    String? title,
  }) {
    return shareFiles(
      pageContext: pageContext,
      anchorContext: anchorContext,
      files: [XFile(filePath, mimeType: mimeType, name: fileName)],
      text: text,
      subject: subject,
      title: title,
    );
  }

  static Future<ShareResult> shareFiles({
    required BuildContext pageContext,
    BuildContext? anchorContext,
    required List<XFile> files,
    String? text,
    String? subject,
    String? title,
  }) {
    return SharePlus.instance.share(
      ShareParams(
        files: files,
        text: text,
        subject: subject,
        title: title,
        sharePositionOrigin: _shouldProvideShareOrigin
            ? _resolveShareOrigin(
                pageContext: pageContext,
                anchorContext: anchorContext,
              )
            : null,
      ),
    );
  }

  static bool get _shouldProvideShareOrigin {
    if (kIsWeb) return false;
    return switch (defaultTargetPlatform) {
      TargetPlatform.iOS || TargetPlatform.macOS => true,
      _ => false,
    };
  }

  static Rect _resolveShareOrigin({
    required BuildContext pageContext,
    BuildContext? anchorContext,
  }) {
    final anchorRect = _rectFromContext(anchorContext);
    if (anchorRect != null) return anchorRect;

    final pageRect = _rectFromContext(pageContext);
    if (pageRect != null) return pageRect;

    final mediaQuery = MediaQuery.maybeOf(pageContext);
    final size = mediaQuery?.size;
    if (size != null && !size.isEmpty) {
      return Offset.zero & size;
    }

    return const Rect.fromLTWH(0, 0, 1, 1);
  }

  static Rect? _rectFromContext(BuildContext? context) {
    if (context == null) return null;
    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) {
      return null;
    }

    final rect = renderObject.localToGlobal(Offset.zero) & renderObject.size;
    if (rect.isEmpty) return null;
    return rect;
  }
}
