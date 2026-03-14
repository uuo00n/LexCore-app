import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

enum ExportFormat { markdown, text, pdf }

extension ExportFormatX on ExportFormat {
  String get extension => switch (this) {
    ExportFormat.markdown => 'md',
    ExportFormat.text => 'txt',
    ExportFormat.pdf => 'pdf',
  };

  String get mimeType => switch (this) {
    ExportFormat.markdown => 'text/markdown',
    ExportFormat.text => 'text/plain',
    ExportFormat.pdf => 'application/pdf',
  };

  String get label => switch (this) {
    ExportFormat.markdown => 'Markdown',
    ExportFormat.text => '文本',
    ExportFormat.pdf => 'PDF',
  };
}

class ExportPayload {
  const ExportPayload({
    required this.title,
    required this.markdown,
    required this.suggestedFileName,
  });

  final String title;
  final String markdown;
  final String suggestedFileName;
}

class ExportArtifact {
  const ExportArtifact({
    required this.filePath,
    required this.displayName,
    required this.mimeType,
  });

  final String filePath;
  final String displayName;
  final String mimeType;
}

abstract class AppExportService {
  Future<ExportArtifact> export({
    required ExportPayload payload,
    required ExportFormat format,
  });
}

typedef TempDirectoryResolver = Future<Directory> Function();
typedef ExportFontDataLoader = Future<ByteData> Function();
typedef TimestampProvider = DateTime Function();

class LocalAppExportService implements AppExportService {
  LocalAppExportService({
    TempDirectoryResolver? tempDirectoryResolver,
    ExportFontDataLoader? fontDataLoader,
    TimestampProvider? timestampProvider,
  }) : _tempDirectoryResolver = tempDirectoryResolver ?? getTemporaryDirectory,
       _fontDataLoader = fontDataLoader ?? _loadDefaultFontData,
       _timestampProvider = timestampProvider ?? DateTime.now;

  static const _fontAssetPath = 'assets/fonts/NotoSansSC-Regular.ttf';

  final TempDirectoryResolver _tempDirectoryResolver;
  final ExportFontDataLoader _fontDataLoader;
  final TimestampProvider _timestampProvider;

  Future<pw.Font>? _cachedPdfFont;

  @override
  Future<ExportArtifact> export({
    required ExportPayload payload,
    required ExportFormat format,
  }) async {
    final directory = await _tempDirectoryResolver();
    final displayName = _buildFileName(
      suggestedFileName: payload.suggestedFileName,
      format: format,
    );
    final outputFile = File('${directory.path}/$displayName');

    switch (format) {
      case ExportFormat.markdown:
        await outputFile.writeAsString(
          _normalizeNewlines(payload.markdown).trimRight(),
          flush: true,
        );
      case ExportFormat.text:
        await outputFile.writeAsString(
          _markdownToPlainText(payload.markdown),
          flush: true,
        );
      case ExportFormat.pdf:
        await outputFile.writeAsBytes(
          await _buildPdfBytes(payload.markdown),
          flush: true,
        );
    }

    return ExportArtifact(
      filePath: outputFile.path,
      displayName: displayName,
      mimeType: format.mimeType,
    );
  }

  Future<Uint8List> _buildPdfBytes(String markdown) async {
    final font = await _loadPdfFont();
    final document = pw.Document(
      theme: pw.ThemeData.withFont(
        base: font,
        bold: font,
        italic: font,
        boldItalic: font,
      ),
    );

    final content = _normalizeNewlines(markdown).trim();
    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(32, 40, 32, 40),
        build: (context) => _buildPdfWidgets(content, font),
      ),
    );

    return document.save();
  }

  List<pw.Widget> _buildPdfWidgets(String markdown, pw.Font font) {
    if (markdown.isEmpty) {
      return [
        pw.Text('暂无可导出的内容', style: pw.TextStyle(font: font, fontSize: 12)),
      ];
    }

    final widgets = <pw.Widget>[];
    var inCodeBlock = false;
    var previousBlank = false;

    for (final rawLine in markdown.split('\n')) {
      final trimmed = rawLine.trim();
      if (trimmed.startsWith('```')) {
        inCodeBlock = !inCodeBlock;
        continue;
      }

      if (trimmed.isEmpty) {
        if (!previousBlank) {
          widgets.add(pw.SizedBox(height: 8));
        }
        previousBlank = true;
        continue;
      }

      previousBlank = false;
      if (trimmed == '---' || trimmed == '***' || trimmed == '___') {
        widgets.add(pw.Divider());
        widgets.add(pw.SizedBox(height: 8));
        continue;
      }

      if (inCodeBlock) {
        widgets.add(
          pw.Container(
            width: double.infinity,
            margin: const pw.EdgeInsets.only(bottom: 6),
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey200,
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Text(
              rawLine,
              style: pw.TextStyle(font: font, fontSize: 10),
            ),
          ),
        );
        continue;
      }

      final headingMatch = RegExp(r'^(#{1,6})\s+(.*)$').firstMatch(trimmed);
      if (headingMatch != null) {
        final level = headingMatch.group(1)!.length;
        widgets.add(
          pw.Padding(
            padding: pw.EdgeInsets.only(top: level == 1 ? 4 : 8, bottom: 6),
            child: pw.Text(
              _stripInlineMarkdown(headingMatch.group(2)!),
              style: pw.TextStyle(
                font: font,
                fontSize: switch (level) {
                  1 => 20,
                  2 => 16,
                  3 => 14,
                  _ => 12,
                },
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
        );
        continue;
      }

      final bulletMatch = RegExp(r'^[-*+]\s+(.*)$').firstMatch(trimmed);
      if (bulletMatch != null) {
        widgets.add(
          pw.Padding(
            padding: const pw.EdgeInsets.only(left: 8, bottom: 4),
            child: pw.Text(
              '• ${_stripInlineMarkdown(bulletMatch.group(1)!)}',
              style: pw.TextStyle(font: font, fontSize: 11.5),
            ),
          ),
        );
        continue;
      }

      final orderedMatch = RegExp(r'^(\d+)\.\s+(.*)$').firstMatch(trimmed);
      if (orderedMatch != null) {
        widgets.add(
          pw.Padding(
            padding: const pw.EdgeInsets.only(left: 8, bottom: 4),
            child: pw.Text(
              '${orderedMatch.group(1)}. ${_stripInlineMarkdown(orderedMatch.group(2)!)}',
              style: pw.TextStyle(font: font, fontSize: 11.5),
            ),
          ),
        );
        continue;
      }

      final quoteMatch = RegExp(r'^>\s?(.*)$').firstMatch(trimmed);
      if (quoteMatch != null) {
        widgets.add(
          pw.Container(
            width: double.infinity,
            margin: const pw.EdgeInsets.only(bottom: 6),
            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: pw.BoxDecoration(
              border: pw.Border(
                left: pw.BorderSide(color: PdfColors.grey500, width: 2),
              ),
              color: PdfColors.grey100,
            ),
            child: pw.Text(
              _stripInlineMarkdown(quoteMatch.group(1)!),
              style: pw.TextStyle(font: font, fontSize: 11.5),
            ),
          ),
        );
        continue;
      }

      widgets.add(
        pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 6),
          child: pw.Text(
            _stripInlineMarkdown(trimmed),
            style: pw.TextStyle(font: font, fontSize: 11.5, lineSpacing: 2),
          ),
        ),
      );
    }

    return widgets;
  }

  Future<pw.Font> _loadPdfFont() {
    return _cachedPdfFont ??= _fontDataLoader().then(pw.Font.ttf);
  }

  String _buildFileName({
    required String suggestedFileName,
    required ExportFormat format,
  }) {
    final sanitizedBaseName = _sanitizeBaseName(suggestedFileName);
    final timestamp = _formatTimestamp(_timestampProvider());
    return '${sanitizedBaseName}_$timestamp.${format.extension}';
  }

  String _sanitizeBaseName(String value) {
    var sanitized = value.trim();
    if (sanitized.isEmpty) {
      sanitized = 'lexcore_export';
    }

    for (final format in ExportFormat.values) {
      final suffix = '.${format.extension}';
      if (sanitized.toLowerCase().endsWith(suffix)) {
        sanitized = sanitized.substring(0, sanitized.length - suffix.length);
        break;
      }
    }

    sanitized = sanitized
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');

    if (sanitized.isEmpty) {
      return 'lexcore_export';
    }
    if (sanitized.length <= 64) {
      return sanitized;
    }
    return sanitized.substring(0, 64);
  }

  String _formatTimestamp(DateTime timestamp) {
    String twoDigits(int value) => value.toString().padLeft(2, '0');

    return '${timestamp.year}'
        '${twoDigits(timestamp.month)}'
        '${twoDigits(timestamp.day)}'
        '_'
        '${twoDigits(timestamp.hour)}'
        '${twoDigits(timestamp.minute)}'
        '${twoDigits(timestamp.second)}';
  }

  String _markdownToPlainText(String markdown) {
    final buffer = StringBuffer();
    final lines = _normalizeNewlines(markdown).split('\n');
    var inCodeBlock = false;
    var previousBlank = false;

    for (final rawLine in lines) {
      final trimmed = rawLine.trim();
      if (trimmed.startsWith('```')) {
        inCodeBlock = !inCodeBlock;
        continue;
      }

      if (trimmed.isEmpty) {
        if (!previousBlank) {
          buffer.writeln();
        }
        previousBlank = true;
        continue;
      }

      previousBlank = false;
      if (trimmed == '---' || trimmed == '***' || trimmed == '___') {
        buffer.writeln();
        continue;
      }

      if (inCodeBlock) {
        buffer.writeln(rawLine);
        continue;
      }

      final headingMatch = RegExp(r'^(#{1,6})\s+(.*)$').firstMatch(trimmed);
      if (headingMatch != null) {
        buffer.writeln(_stripInlineMarkdown(headingMatch.group(2)!));
        buffer.writeln();
        continue;
      }

      final bulletMatch = RegExp(r'^[-*+]\s+(.*)$').firstMatch(trimmed);
      if (bulletMatch != null) {
        buffer.writeln('• ${_stripInlineMarkdown(bulletMatch.group(1)!)}');
        continue;
      }

      final orderedMatch = RegExp(r'^(\d+)\.\s+(.*)$').firstMatch(trimmed);
      if (orderedMatch != null) {
        buffer.writeln(
          '${orderedMatch.group(1)}. ${_stripInlineMarkdown(orderedMatch.group(2)!)}',
        );
        continue;
      }

      final quoteMatch = RegExp(r'^>\s?(.*)$').firstMatch(trimmed);
      if (quoteMatch != null) {
        buffer.writeln(_stripInlineMarkdown(quoteMatch.group(1)!));
        continue;
      }

      buffer.writeln(_stripInlineMarkdown(trimmed));
    }

    return buffer.toString().trimRight();
  }

  String _stripInlineMarkdown(String value) {
    var text = value;
    text = text.replaceAllMapped(
      RegExp(r'!\[([^\]]*)\]\(([^)]+)\)'),
      (match) => match.group(1)?.trim() ?? '',
    );
    text = text.replaceAllMapped(
      RegExp(r'\[([^\]]+)\]\(([^)]+)\)'),
      (match) => '${match.group(1)} (${match.group(2)})',
    );
    text = text.replaceAllMapped(
      RegExp(r'(\*\*|__)(.*?)\1'),
      (match) => match.group(2) ?? '',
    );
    text = text.replaceAllMapped(
      RegExp(r'(\*|_)(.*?)\1'),
      (match) => match.group(2) ?? '',
    );
    text = text.replaceAllMapped(
      RegExp(r'~~(.*?)~~'),
      (match) => match.group(1) ?? '',
    );
    text = text.replaceAll('`', '');
    text = text.replaceAll(RegExp(r'<[^>]+>'), '');
    return text.trim();
  }

  String _normalizeNewlines(String value) {
    return value.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
  }

  static Future<ByteData> _loadDefaultFontData() {
    return rootBundle.load(_fontAssetPath);
  }
}
