import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lexcore/app/adaptive/app_adaptive_split_view.dart';
import 'package:lexcore/app/adaptive/app_breakpoints.dart';
import 'package:lexcore/app/di/app_providers.dart';
import 'package:lexcore/app/motion/app_motion_widgets.dart';
import 'package:lexcore/core/export/app_export_service.dart';
import 'package:lexcore/core/utils/app_share.dart';
import 'package:lexcore/features/document/application/document_providers.dart';
import 'package:lexcore/shared/components/app_surface_card.dart';
import 'package:lexcore/shared/models/legal_models.dart';
import 'package:lexcore/shared/widgets/app_export_sheet.dart';
import 'package:lexcore/shared/widgets/app_mobile_canvas.dart';
import 'package:lexcore/shared/widgets/app_shell_top_bar.dart';

class DocumentPreviewPage extends ConsumerWidget {
  const DocumentPreviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(generatedDraftProvider);
    final exportService = ref.read(appExportServiceProvider);
    final exportPayload = _buildDocumentExportPayload(draft);
    final messenger = ScaffoldMessenger.of(context);

    Future<void> shareDraft(BuildContext anchorContext) async {
      final format = await showAppExportSheet(
        context: context,
        title: '导出文档',
        subtitle: '选择要生成并分享的文件格式',
      );
      if (format == null || !context.mounted) return;

      final progressOverlay = showAppExportProgressOverlay(
        context: context,
        label: format.label,
      );
      var overlayVisible = true;

      try {
        final artifact = await exportService.export(
          payload: exportPayload,
          format: format,
        );
        if (overlayVisible) {
          progressOverlay.remove();
          overlayVisible = false;
        }
        if (!context.mounted) return;
        await AppShare.shareFile(
          pageContext: context,
          anchorContext: anchorContext,
          filePath: artifact.filePath,
          fileName: artifact.displayName,
          mimeType: artifact.mimeType,
          subject: draft.title,
          title: artifact.displayName,
        );
      } catch (_) {
        if (overlayVisible) {
          progressOverlay.remove();
        }
        messenger.showSnackBar(const SnackBar(content: Text('分享失败，请稍后重试')));
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final viewport = AppBreakpoints.fromWidth(constraints.maxWidth);
        final splitLayout =
            viewport == AppViewportSize.expanded ||
            viewport == AppViewportSize.ultra;
        final showBottomActions = viewport == AppViewportSize.compact;

        return Scaffold(
          body: AppMobileCanvas(
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  AppFadeSlideIn(
                    delay: const Duration(milliseconds: 20),
                    beginOffset: const Offset(0, -0.02),
                    child: AppShellTopBar(
                      title: '文档预览',
                      leading: IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.arrow_back_rounded),
                        tooltip: '返回',
                      ),
                      actions: [
                        Builder(
                          builder: (buttonContext) => IconButton(
                            onPressed: () => shareDraft(buttonContext),
                            icon: const Icon(Icons.share_outlined),
                            tooltip: '分享',
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.more_vert_rounded),
                          tooltip: '更多操作',
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        16,
                        6,
                        16,
                        showBottomActions ? 110 : 16,
                      ),
                      child: splitLayout
                          ? AppAdaptiveSplitView(
                              splitMinWidth: 980,
                              secondaryMaxWidth: 360,
                              primary: _DocumentBody(
                                title: draft.title,
                                markdown: draft.markdown,
                              ),
                              secondary: _DocumentSidePanel(
                                title: draft.title,
                                onExport: shareDraft,
                              ),
                            )
                          : _DocumentBody(
                              title: draft.title,
                              markdown: draft.markdown,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: showBottomActions
              ? AppMobileCanvas(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      border: Border(
                        top: BorderSide(color: Theme.of(context).dividerColor),
                      ),
                    ),
                    child: _ActionButtons(
                      isCompact: true,
                      onExport: shareDraft,
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }
}

class _DocumentBody extends StatelessWidget {
  const _DocumentBody({required this.title, required this.markdown});

  final String title;
  final String markdown;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        AppFadeSlideIn(
          delay: const Duration(milliseconds: 70),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 170,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -30,
                    right: -20,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.onPrimary.withValues(alpha: 0.14),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 14,
                    bottom: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: Theme.of(
                          context,
                        ).colorScheme.onPrimary.withValues(alpha: 0.2),
                      ),
                      child: Text(
                        '智能分析',
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        AppFadeSlideIn(
          delay: const Duration(milliseconds: 120),
          child: AppSurfaceCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(
                  '由 LexCore 智能引擎生成 · 2024年5月20日',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                MarkdownBody(data: markdown),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DocumentSidePanel extends StatelessWidget {
  const _DocumentSidePanel({required this.title, required this.onExport});

  final String title;
  final Future<void> Function(BuildContext anchorContext) onExport;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        AppFadeSlideIn(
          delay: const Duration(milliseconds: 120),
          child: AppSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('文档信息', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 10),
                _InfoRow(label: '标题', value: title),
                const SizedBox(height: 8),
                const _InfoRow(label: '版本', value: 'v1.0 草稿'),
                const SizedBox(height: 8),
                const _InfoRow(label: '来源', value: 'LexCore 智能引擎'),
                const SizedBox(height: 8),
                const _InfoRow(label: '更新时间', value: '2024-05-20 14:08'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        AppFadeSlideIn(
          delay: const Duration(milliseconds: 160),
          child: AppSurfaceCard(
            child: _ActionButtons(isCompact: false, onExport: onExport),
          ),
        ),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.isCompact, this.onExport});

  final bool isCompact;
  final Future<void> Function(BuildContext anchorContext)? onExport;

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.edit_outlined),
              label: const Text('编辑'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(44),
                shape: const StadiumBorder(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: FilledButton.tonalIcon(
              onPressed: onExport == null ? null : () => onExport!(context),
              icon: const Icon(Icons.ios_share_outlined),
              label: const Text('导出文件'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(44),
                shape: const StadiumBorder(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.save_outlined),
              label: const Text('保存'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(44),
                shape: const StadiumBorder(),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.save_outlined),
          label: const Text('保存文档'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.edit_outlined),
          label: const Text('编辑内容'),
        ),
        const SizedBox(height: 8),
        Builder(
          builder: (buttonContext) => OutlinedButton.icon(
            onPressed: onExport == null ? null : () => onExport!(buttonContext),
            icon: const Icon(Icons.ios_share_outlined),
            label: const Text('导出 / 分享'),
          ),
        ),
      ],
    );
  }
}

ExportPayload _buildDocumentExportPayload(DocumentDraft draft) {
  return ExportPayload(
    title: draft.title,
    markdown: draft.markdown,
    suggestedFileName: draft.title,
  );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 64,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}
