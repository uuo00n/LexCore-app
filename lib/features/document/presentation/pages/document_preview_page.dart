import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import 'package:lexcore/app/adaptive/app_adaptive_split_view.dart';
import 'package:lexcore/app/adaptive/app_breakpoints.dart';
import 'package:lexcore/app/di/app_providers.dart';
import 'package:lexcore/app/motion/app_motion_widgets.dart';
import 'package:lexcore/app/router/route_names.dart';
import 'package:lexcore/core/export/app_export_service.dart';
import 'package:lexcore/core/network/dio_provider.dart';
import 'package:lexcore/core/utils/app_share.dart';
import 'package:lexcore/core/utils/feature_notice.dart';
import 'package:lexcore/features/document/application/document_providers.dart';
import 'package:lexcore/shared/components/app_surface_card.dart';
import 'package:lexcore/shared/models/legal_models.dart';
import 'package:lexcore/shared/widgets/app_export_sheet.dart';
import 'package:lexcore/shared/widgets/app_page_scaffold.dart';

class DocumentPreviewPage extends ConsumerWidget {
  const DocumentPreviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(generatedDraftProvider);
    final documentState = ref.watch(documentControllerProvider);
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
        if (format == ExportFormat.pdf) {
          final pdfResult = await ref
              .read(documentControllerProvider.notifier)
              .exportDraftPdf(draft);
          final downloadUrl = pdfResult?.downloadUrl;
          if (pdfResult != null &&
              pdfResult.completed &&
              downloadUrl != null &&
              downloadUrl.trim().isNotEmpty) {
            final directory = await getTemporaryDirectory();
            final displayName = '${exportPayload.suggestedFileName}.pdf';
            final filePath = '${directory.path}/$displayName';
            final outputFile = File(filePath);
            if (await outputFile.exists()) {
              await outputFile.delete();
            }
            await ref.read(dioProvider).download(downloadUrl, filePath);

            if (overlayVisible) {
              progressOverlay.remove();
              overlayVisible = false;
            }
            if (!context.mounted) return;
            await AppShare.shareFile(
              pageContext: context,
              anchorContext: anchorContext,
              filePath: filePath,
              fileName: displayName,
              mimeType: ExportFormat.pdf.mimeType,
              subject: draft.title,
              title: displayName,
            );
            return;
          }
        }

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

    Future<void> saveDraft() async {
      if (documentState.saving) {
        return;
      }

      try {
        final result = await ref
            .read(documentControllerProvider.notifier)
            .saveDraft(draft);
        if (!context.mounted) return;
        final documentId = result.documentId.trim();
        if (documentId.isEmpty) {
          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(const SnackBar(content: Text('保存失败，请稍后重试')));
          return;
        }
        context.pushNamed(
          RouteNames.savedDocumentDetail,
          pathParameters: {RouteNames.savedDocumentIdParam: documentId},
          queryParameters: const {'mode': 'view'},
        );
      } catch (_) {
        if (!context.mounted) return;
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(content: Text('保存失败，请稍后重试')));
      }
    }

    Future<void> editDraft() async {
      if (documentState.saving) {
        return;
      }

      try {
        final result = await ref
            .read(documentControllerProvider.notifier)
            .saveDraft(draft);
        if (!context.mounted) return;
        final documentId = result.documentId.trim();
        if (documentId.isEmpty) {
          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(const SnackBar(content: Text('进入编辑失败，请稍后重试')));
          return;
        }
        context.pushNamed(
          RouteNames.savedDocumentDetail,
          pathParameters: {RouteNames.savedDocumentIdParam: documentId},
          queryParameters: {
            'mode': result.status == 'completed' ? 'edit' : 'view',
          },
        );
      } catch (_) {
        if (!context.mounted) return;
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(content: Text('进入编辑失败，请稍后重试')));
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final viewport = AppBreakpoints.fromWidth(constraints.maxWidth);
        final splitLayout =
            viewport == AppViewportSize.expanded ||
            viewport == AppViewportSize.ultra;
        final showBottomActions = viewport == AppViewportSize.compact;

        return AppPageScaffold(
          title: '文档预览',
          actions: [
            Builder(
              builder: (buttonContext) => IconButton(
                onPressed: () => shareDraft(buttonContext),
                icon: const Icon(Icons.share_outlined),
                tooltip: '分享',
              ),
            ),
            IconButton(
              onPressed: () =>
                  showFeatureInProgressSnackBar(context, featureLabel: '更多操作'),
              icon: const Icon(Icons.more_vert_rounded),
              tooltip: '更多操作',
            ),
          ],
          bodyPadding: EdgeInsets.fromLTRB(16, 6, 16, 16),
          body: splitLayout
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
                    onEdit: editDraft,
                    onSave: saveDraft,
                    saving: documentState.saving,
                  ),
                )
              : _DocumentBody(title: draft.title, markdown: draft.markdown),
          bottomNavigationBar: showBottomActions
              ? Container(
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
                    onEdit: editDraft,
                    onSave: saveDraft,
                    saving: documentState.saving,
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final styleSheet = MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
      h1: textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        height: 1.3,
      ),
      h2: textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        height: 1.35,
      ),
      h3: textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w700,
        height: 1.4,
      ),
      p: textTheme.bodyMedium?.copyWith(height: 1.75),
      listBullet: textTheme.bodyMedium?.copyWith(height: 1.7),
      blockquote: textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurfaceVariant,
        height: 1.75,
      ),
      code: textTheme.bodySmall?.copyWith(
        color: colorScheme.primary,
        backgroundColor: colorScheme.primary.withValues(alpha: 0.08),
      ),
      blockquoteDecoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
        border: Border(left: BorderSide(color: colorScheme.primary, width: 3)),
      ),
      blockquotePadding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 10,
      ),
      listIndent: 22,
      horizontalRuleDecoration: BoxDecoration(
        border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
      ),
    );

    return ListView(
      children: [
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
                  '文档预览 · ${DateFormat('yyyy年M月d日').format(DateTime.now())}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                if (markdown.trim().isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '请在上一页填写内容后再生成文档。',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                else
                  MarkdownBody(
                    data: markdown,
                    styleSheet: styleSheet,
                    sizedImageBuilder: (config) {
                      if (_isEvidenceIllustrationPlaceholder(config.uri)) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: _EvidenceIllustrationCard(),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 280),
                            child: Image.network(
                              config.uri.toString(),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 16,
                                  ),
                                  color: colorScheme.surfaceContainerHigh,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.broken_image_outlined,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          config.alt?.trim().isNotEmpty == true
                                              ? config.alt!
                                              : '图片加载失败',
                                          style: textTheme.bodySmall?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

bool _isEvidenceIllustrationPlaceholder(Uri uri) {
  return uri.scheme == 'lexcore' && uri.host == 'evidence-info-card';
}

class _EvidenceIllustrationCard extends StatelessWidget {
  const _EvidenceIllustrationCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.inventory_2_outlined,
                color: colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '证据材料示意（非真实图片）',
                style: textTheme.titleSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '用于占位展示证据截图区域，导出前请替换为真实证据材料。',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 10),
          _EvidenceMetaRow(label: '建议材料', value: '劳动合同 / 工资流水 / 催告记录'),
          const SizedBox(height: 6),
          _EvidenceMetaRow(label: '材料要求', value: '可核验、可追溯、时间线清晰'),
        ],
      ),
    );
  }
}

class _EvidenceMetaRow extends StatelessWidget {
  const _EvidenceMetaRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

class _DocumentSidePanel extends StatelessWidget {
  const _DocumentSidePanel({
    required this.title,
    required this.onExport,
    required this.onEdit,
    required this.onSave,
    required this.saving,
  });

  final String title;
  final Future<void> Function(BuildContext anchorContext) onExport;
  final Future<void> Function() onEdit;
  final Future<void> Function() onSave;
  final bool saving;

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
                const _InfoRow(label: '版本', value: '未保存'),
                const SizedBox(height: 8),
                const _InfoRow(label: '来源', value: '用户输入'),
                const SizedBox(height: 8),
                _InfoRow(
                  label: '更新时间',
                  value: DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        AppFadeSlideIn(
          delay: const Duration(milliseconds: 160),
          child: AppSurfaceCard(
            child: _ActionButtons(
              isCompact: false,
              onExport: onExport,
              onEdit: onEdit,
              onSave: onSave,
              saving: saving,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.isCompact,
    required this.onExport,
    required this.onEdit,
    required this.onSave,
    required this.saving,
  });

  final bool isCompact;
  final Future<void> Function(BuildContext anchorContext) onExport;
  final Future<void> Function() onEdit;
  final Future<void> Function() onSave;
  final bool saving;

  @override
  Widget build(BuildContext context) {
    final saveIcon = saving
        ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2.2),
          )
        : const Icon(Icons.save_outlined);
    final saveLabel = saving ? '保存中...' : (isCompact ? '保存' : '保存文档');
    final compactTextStyle = Theme.of(context).textTheme.labelMedium?.copyWith(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      height: 1.1,
    );

    if (isCompact) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: saving ? null : onEdit,
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text(
                '编辑',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textScaler: TextScaler.linear(1),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(42),
                textStyle: compactTextStyle,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                shape: const StadiumBorder(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: FilledButton.tonalIcon(
              onPressed: () => onExport(context),
              icon: const Icon(Icons.ios_share_outlined, size: 18),
              label: const Text(
                '导出文件',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textScaler: TextScaler.linear(1),
              ),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(42),
                textStyle: compactTextStyle,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                shape: const StadiumBorder(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: FilledButton.icon(
              onPressed: saving ? null : onSave,
              icon: saveIcon,
              label: Text(
                saveLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textScaler: const TextScaler.linear(1),
              ),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(42),
                textStyle: compactTextStyle,
                padding: const EdgeInsets.symmetric(horizontal: 8),
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
          onPressed: saving ? null : onSave,
          icon: saveIcon,
          label: Text(saveLabel),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: saving ? null : onEdit,
          icon: const Icon(Icons.edit_outlined),
          label: const Text('编辑内容'),
        ),
        const SizedBox(height: 8),
        Builder(
          builder: (buttonContext) => OutlinedButton.icon(
            onPressed: () => onExport(buttonContext),
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
