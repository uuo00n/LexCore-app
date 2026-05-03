import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lexcore/core/utils/app_share.dart';
import 'package:lexcore/features/document/application/document_providers.dart';
import 'package:lexcore/shared/components/app_surface_card.dart';
import 'package:lexcore/shared/models/legal_models.dart';
import 'package:lexcore/shared/widgets/app_page_scaffold.dart';

class ConsultationOpinionDetailPage extends ConsumerWidget {
  const ConsultationOpinionDetailPage({super.key, this.summary});

  final String? summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messenger = ScaffoldMessenger.of(context);
    final resolvedSummary = summary?.trim() ?? '';
    final opinionMarkdown = _buildOpinionMarkdown(resolvedSummary);

    Future<void> shareOpinion(BuildContext anchorContext) async {
      try {
        await AppShare.shareText(
          pageContext: context,
          anchorContext: anchorContext,
          text: opinionMarkdown,
          subject: '法律意见书',
        );
      } catch (_) {
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(content: Text('分享失败，请稍后重试')));
      }
    }

    Future<void> saveOpinion() async {
      try {
        final result = await ref
            .read(documentControllerProvider.notifier)
            .saveDraft(
              DocumentDraft(title: '法律意见书（咨询版）', markdown: opinionMarkdown),
            );
        if (!context.mounted) {
          return;
        }
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                result.result == DocumentSaveResult.created
                    ? '意见书已保存'
                    : '意见书已更新',
              ),
            ),
          );
      } catch (_) {
        if (!context.mounted) {
          return;
        }
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(content: Text('保存失败，请稍后重试')));
      }
    }

    return AppPageScaffold(
      title: '法律意见书',
      actions: [
        if (resolvedSummary.isNotEmpty)
          Builder(
            builder: (buttonContext) => IconButton(
              onPressed: () => shareOpinion(buttonContext),
              tooltip: '分享',
              icon: const Icon(Icons.share_outlined),
            ),
          ),
      ],
      body: ListView(
        children: [
          AppSurfaceCard(
            child: resolvedSummary.isEmpty
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.note_alt_outlined,
                        size: 36,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '暂无可生成内容',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '请先返回咨询会话获取回复内容。',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '核心结论',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        resolvedSummary,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(height: 1.6),
                      ),
                    ],
                  ),
          ),
          if (resolvedSummary.isNotEmpty) ...[
            const SizedBox(height: 12),
            AppSurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('导出预览', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Text(
                    opinionMarkdown,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: saveOpinion,
              icon: const Icon(Icons.save_outlined),
              label: const Text('保存意见书'),
            ),
          ],
        ],
      ),
    );
  }
}

String _buildOpinionMarkdown(String summary) {
  if (summary.trim().isEmpty) {
    return '# 法律意见书（咨询版）\n\n暂无可用咨询内容。';
  }
  return [
    '# 法律意见书（咨询版）',
    '',
    '## 核心结论',
    summary,
    '',
    '## 说明',
    '本意见书由咨询会话内容整理生成，请结合实际证据进一步核验。',
  ].join('\n');
}
