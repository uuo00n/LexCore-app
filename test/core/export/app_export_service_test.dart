import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:lexcore/core/export/app_export_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocalAppExportService', () {
    late Directory tempDir;
    late LocalAppExportService service;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('app_export_service');
      service = LocalAppExportService(
        tempDirectoryResolver: () async => tempDir,
        fontDataLoader: () async {
          final bytes = await File(
            'assets/fonts/NotoSansSC-Regular.ttf',
          ).readAsBytes();
          return ByteData.sublistView(bytes);
        },
        timestampProvider: () => DateTime(2026, 3, 14, 12, 34, 56),
      );
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    const payload = ExportPayload(
      title: '测试文档',
      suggestedFileName: '测试/文档',
      markdown: '# 标题\n\n- 第一项\n\n正文 [链接](https://example.com)',
    );

    test('exports markdown file with sanitized name', () async {
      final artifact = await service.export(
        payload: payload,
        format: ExportFormat.markdown,
      );

      expect(artifact.displayName, '测试_文档_20260314_123456.md');
      expect(artifact.mimeType, 'text/markdown');
      expect(
        await File(artifact.filePath).readAsString(),
        '# 标题\n\n- 第一项\n\n正文 [链接](https://example.com)',
      );
    });

    test('exports plain text file without markdown markers', () async {
      final artifact = await service.export(
        payload: payload,
        format: ExportFormat.text,
      );

      final text = await File(artifact.filePath).readAsString();
      expect(artifact.displayName, '测试_文档_20260314_123456.txt');
      expect(artifact.mimeType, 'text/plain');
      expect(text, contains('标题'));
      expect(text, contains('• 第一项'));
      expect(text, contains('正文 链接 (https://example.com)'));
      expect(text, isNot(contains('# 标题')));
    });

    test('exports pdf file with pdf header bytes', () async {
      final artifact = await service.export(
        payload: payload,
        format: ExportFormat.pdf,
      );

      final bytes = await File(artifact.filePath).readAsBytes();
      expect(artifact.displayName, '测试_文档_20260314_123456.pdf');
      expect(artifact.mimeType, 'application/pdf');
      expect(bytes.length, greaterThan(100));
      expect(String.fromCharCodes(bytes.take(4)), '%PDF');
    });
  });
}
