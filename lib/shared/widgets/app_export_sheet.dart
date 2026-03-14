import 'package:flutter/material.dart';

import 'package:lexcore/core/export/app_export_service.dart';

Future<ExportFormat?> showAppExportSheet({
  required BuildContext context,
  required String title,
  String? subtitle,
}) {
  return showModalBottomSheet<ExportFormat>(
    context: context,
    useSafeArea: true,
    builder: (sheetContext) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const _ExportSheetOption(
              format: ExportFormat.markdown,
              title: 'Markdown (.md)',
              subtitle: '保留结构化标题与列表，适合继续编辑',
              icon: Icons.article_outlined,
            ),
            const _ExportSheetOption(
              format: ExportFormat.text,
              title: '文本文件 (.txt)',
              subtitle: '纯文本内容，适合通用查看和复制',
              icon: Icons.notes_outlined,
            ),
            const _ExportSheetOption(
              format: ExportFormat.pdf,
              title: 'PDF 文档 (.pdf)',
              subtitle: '固定版式文件，适合归档和发送',
              icon: Icons.picture_as_pdf_outlined,
            ),
            const SizedBox(height: 10),
          ],
        ),
      );
    },
  );
}

OverlayEntry showAppExportProgressOverlay({
  required BuildContext context,
  required String label,
}) {
  final overlayEntry = OverlayEntry(
    builder: (_) => _AppExportProgressOverlay(label: label),
  );
  Overlay.of(context, rootOverlay: true).insert(overlayEntry);
  return overlayEntry;
}

class _AppExportProgressOverlay extends StatelessWidget {
  const _AppExportProgressOverlay({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.scrim.withValues(alpha: 0.26),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 260),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.4),
                  ),
                  const SizedBox(width: 16),
                  Expanded(child: Text('正在生成$label文件...')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ExportSheetOption extends StatelessWidget {
  const _ExportSheetOption({
    required this.format,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final ExportFormat format;
  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () => Navigator.of(context).pop(format),
    );
  }
}
