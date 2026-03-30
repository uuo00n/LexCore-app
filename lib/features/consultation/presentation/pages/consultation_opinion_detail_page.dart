import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lexcore/core/utils/app_share.dart';
import 'package:lexcore/features/document/application/document_providers.dart';
import 'package:lexcore/shared/components/app_surface_card.dart';
import 'package:lexcore/shared/models/legal_models.dart';
import 'package:lexcore/shared/widgets/app_page_scaffold.dart';

const _defaultConsultationOpinionSummary =
    '基于现有咨询记录，案件争议焦点集中在劳动报酬支付与加班费举证。建议先完善证据链，再按协商、投诉、仲裁的顺序推进。';

class ConsultationOpinionDetailPage extends ConsumerWidget {
  const ConsultationOpinionDetailPage({super.key, this.summary});

  final String? summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messenger = ScaffoldMessenger.of(context);
    final resolvedSummary = summary?.trim().isNotEmpty == true
        ? summary!.trim()
        : _defaultConsultationOpinionSummary;
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
                result == DocumentSaveResult.created ? '意见书已保存' : '意见书已更新',
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
      subtitle: '咨询深度分析',
      actions: [
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
            backgroundColor: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.08),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('核心结论', style: Theme.of(context).textTheme.titleSmall),
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
          const SizedBox(height: 12),
          const _OpinionSection(
            icon: Icons.fact_check_outlined,
            title: '一、事实要点',
            lines: [
              '已识别主要争议为工资拖欠及加班费认定。',
              '当前事实基础可支持先行协商和投诉流程。',
              '建议补充完整时间线与在岗证明材料。',
            ],
          ),
          const SizedBox(height: 12),
          const _OpinionSection(
            icon: Icons.menu_book_outlined,
            title: '二、法律依据',
            lines: [
              '《劳动合同法》第三十条：及时足额支付劳动报酬。',
              '《劳动法》第四十四条：加班工资支付标准。',
              '《劳动争议调解仲裁法》第二条：劳动争议适用范围。',
            ],
          ),
          const SizedBox(height: 12),
          const _OpinionSection(
            icon: Icons.warning_amber_outlined,
            title: '三、风险提示',
            lines: ['证据链不完整会影响加班事实认定。', '沟通记录缺失会降低主张可信度。', '超过仲裁时效将显著提高维权成本。'],
          ),
          const SizedBox(height: 12),
          const _OpinionSection(
            icon: Icons.assignment_turned_in_outlined,
            title: '四、行动清单',
            lines: [
              '1）整理劳动合同、工资流水、考勤截图。',
              '2）向单位发起书面催告并保留回执。',
              '3）协商无果后准备仲裁申请材料。',
            ],
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: saveOpinion,
            icon: const Icon(Icons.save_outlined),
            label: const Text('保存意见书'),
          ),
        ],
      ),
    );
  }
}

class _OpinionSection extends StatelessWidget {
  const _OpinionSection({
    required this.icon,
    required this.title,
    required this.lines,
  });

  final IconData icon;
  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(title, style: Theme.of(context).textTheme.titleSmall),
            ],
          ),
          const SizedBox(height: 10),
          ...lines.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                line,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(height: 1.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _buildOpinionMarkdown(String summary) {
  return [
    '# 法律意见书（咨询版）',
    '',
    '## 核心结论',
    summary,
    '',
    '## 一、事实要点',
    '- 已识别主要争议为工资拖欠及加班费认定。',
    '- 当前事实基础可支持先行协商和投诉流程。',
    '- 建议补充完整时间线与在岗证明材料。',
    '',
    '## 二、法律依据',
    '- 《劳动合同法》第三十条：及时足额支付劳动报酬。',
    '- 《劳动法》第四十四条：加班工资支付标准。',
    '- 《劳动争议调解仲裁法》第二条：劳动争议适用范围。',
    '',
    '## 三、风险提示',
    '- 证据链不完整会影响加班事实认定。',
    '- 沟通记录缺失会降低主张可信度。',
    '- 超过仲裁时效将显著提高维权成本。',
    '',
    '## 四、行动清单',
    '1. 整理劳动合同、工资流水、考勤截图。',
    '2. 向单位发起书面催告并保留回执。',
    '3. 协商无果后准备仲裁申请材料。',
  ].join('\n');
}
