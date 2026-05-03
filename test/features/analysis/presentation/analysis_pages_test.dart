import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lexcore/app/di/app_providers.dart';
import 'package:lexcore/core/export/app_export_service.dart';
import 'package:lexcore/features/analysis/presentation/pages/analysis_detail_page.dart';
import 'package:lexcore/features/analysis/presentation/pages/analysis_result_page.dart';
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
      'analysis_result_page_test',
    );
    createdDirectories.add(directory);

    final displayName = 'analysis_export.${format.extension}';
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
  Future<void> pumpPage(
    WidgetTester tester,
    Widget page, {
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
        child: MaterialApp(home: page),
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

  testWidgets('analysis detail uses unified top bar', (tester) async {
    await pumpPage(tester, const AnalysisDetailPage());

    expect(find.byType(AppShellTopBar), findsOneWidget);
    expect(find.text('分析详情'), findsOneWidget);
    expect(find.text('暂无分析数据'), findsNothing);
    expect(find.text('案件分析摘要'), findsOneWidget);
    expect(find.text('关键法条匹配'), findsOneWidget);
  });

  testWidgets('analysis result uses unified top bar', (tester) async {
    await pumpPage(tester, const AnalysisResultPage());

    expect(find.byType(AppShellTopBar), findsOneWidget);
    expect(find.text('案件分析结果'), findsOneWidget);
    expect(find.text('暂无分析结果'), findsNothing);
    expect(find.text('LexCore 案件分析报告'), findsOneWidget);
    expect(find.text('风险指标评估'), findsOneWidget);
  });

  testWidgets('analysis result top action exports pdf file', (tester) async {
    final exportService = _FakeExportService();
    addTearDown(exportService.dispose);
    mockShareChannel();
    await pumpPage(
      tester,
      const AnalysisResultPage(),
      size: const Size(1200, 900),
      exportService: exportService,
    );

    await tester.tap(find.byTooltip('分享'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('PDF 文档 (.pdf)'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(exportService.exportedFormats, <ExportFormat>[ExportFormat.pdf]);
    expect(find.text('分享失败，请稍后重试'), findsNothing);
  });

  testWidgets('analysis result side action exports markdown file', (
    tester,
  ) async {
    final exportService = _FakeExportService();
    addTearDown(exportService.dispose);
    mockShareChannel();
    await pumpPage(
      tester,
      const AnalysisResultPage(),
      size: const Size(1200, 900),
      exportService: exportService,
    );

    final exportButton = find.widgetWithText(OutlinedButton, '导出 / 分享');
    await tester.ensureVisible(exportButton);
    await tester.tap(exportButton);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Markdown (.md)'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(exportService.exportedFormats, <ExportFormat>[
      ExportFormat.markdown,
    ]);
    expect(find.text('分享失败，请稍后重试'), findsNothing);
  });
}
