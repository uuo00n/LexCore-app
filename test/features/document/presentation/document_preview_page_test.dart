import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lexcore/app/di/app_providers.dart';
import 'package:lexcore/core/export/app_export_service.dart';
import 'package:lexcore/features/document/presentation/pages/document_preview_page.dart';
import 'package:lexcore/shared/widgets/app_shell_top_bar.dart';

class _FakeExportService implements AppExportService {
  final exportedFormats = <ExportFormat>[];
  final createdDirectories = <Directory>[];

  Future<void> dispose() async {
    for (final directory in createdDirectories) {
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    }
  }

  @override
  Future<ExportArtifact> export({
    required ExportPayload payload,
    required ExportFormat format,
  }) async {
    exportedFormats.add(format);
    final directory = await Directory.systemTemp.createTemp(
      'document_preview_page_test',
    );
    createdDirectories.add(directory);

    final displayName = 'document_export.${format.extension}';
    final file = File('${directory.path}/$displayName');
    await file.writeAsString('fake ${format.name}');

    return ExportArtifact(
      filePath: file.path,
      displayName: displayName,
      mimeType: format.mimeType,
    );
  }
}

void main() {
  Future<void> pumpDocumentPreviewPage(
    WidgetTester tester, {
    Size size = const Size(390, 844),
    AppExportService? exportService,
  }) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          if (exportService != null)
            appExportServiceProvider.overrideWithValue(exportService),
        ],
        child: const MaterialApp(home: DocumentPreviewPage()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 900));
  }

  List<MethodCall> mockShareChannel() {
    const channel = MethodChannel('dev.fluttercommunity.plus/share');
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          return '';
        });
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });
    return calls;
  }

  testWidgets('document preview uses unified top bar', (tester) async {
    await pumpDocumentPreviewPage(tester);

    expect(find.byType(AppShellTopBar), findsOneWidget);
    expect(find.text('文档预览'), findsOneWidget);
    expect(find.byIcon(Icons.more_vert_rounded), findsOneWidget);
  });

  testWidgets('document preview top action exports markdown file', (
    tester,
  ) async {
    final exportService = _FakeExportService();
    addTearDown(exportService.dispose);
    mockShareChannel();
    await pumpDocumentPreviewPage(
      tester,
      size: const Size(1200, 900),
      exportService: exportService,
    );

    await tester.tap(find.byTooltip('分享'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Markdown (.md)'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(exportService.exportedFormats, <ExportFormat>[
      ExportFormat.markdown,
    ]);
    expect(find.text('分享失败，请稍后重试'), findsNothing);
  });

  testWidgets('document preview side action exports pdf file', (tester) async {
    final exportService = _FakeExportService();
    addTearDown(exportService.dispose);
    mockShareChannel();
    await pumpDocumentPreviewPage(
      tester,
      size: const Size(1200, 900),
      exportService: exportService,
    );

    final exportButton = find.widgetWithText(OutlinedButton, '导出 / 分享');
    await tester.ensureVisible(exportButton);
    await tester.tap(exportButton);
    await tester.pumpAndSettle();
    await tester.tap(find.text('PDF 文档 (.pdf)'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(exportService.exportedFormats, <ExportFormat>[ExportFormat.pdf]);
    expect(find.text('分享失败，请稍后重试'), findsNothing);
  });
}
