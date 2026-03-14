import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:lexcore/app/motion/app_motion_widgets.dart';
import 'package:lexcore/app/router/route_names.dart';
import 'package:lexcore/core/extensions/context_extensions.dart';
import 'package:lexcore/shared/widgets/app_mobile_canvas.dart';

enum CaseDetailStatus { inProgress, closed, waiting }

enum CaseDocumentType { pdf, image, note }

@immutable
class CaseDetailData {
  const CaseDetailData({
    required this.status,
    required this.statusLabel,
    required this.lastUpdatedLabel,
    required this.title,
    required this.caseNumber,
    required this.dateLabel,
    required this.dateValue,
    required this.progress,
    required this.progressLabel,
    required this.activeStepIndex,
    required this.progressSteps,
    required this.summary,
    required this.plaintiffName,
    required this.plaintiffCounsel,
    required this.defendantName,
    required this.defendantCounsel,
    required this.documents,
  });

  factory CaseDetailData.demo() {
    return const CaseDetailData(
      status: CaseDetailStatus.inProgress,
      statusLabel: '进行中',
      lastUpdatedLabel: '更新于 2小时前',
      title: '张三与李四房屋所有权纠纷案',
      caseNumber: '(2023) 沪0115民初12345号',
      dateLabel: '立案日期',
      dateValue: '2023-10-15',
      progress: 0.65,
      progressLabel: '开庭中',
      activeStepIndex: 2,
      progressSteps: ['证据交换', '庭审准备', '开庭中', '判决'],
      summary:
          '原告张三与被告李四于 2022 年签订房屋买卖协议，原告已支付全部房款，但被告迟迟未办理房产过户手续。原告遂起诉要求被告履行合同义务并赔偿违约金。',
      plaintiffName: '张三',
      plaintiffCounsel: '代理律师：王律师',
      defendantName: '李四',
      defendantCounsel: '未指定代理',
      documents: [
        CaseDocumentData(
          type: CaseDocumentType.pdf,
          title: '起诉状_张三.pdf',
          meta: '1.2 MB · 2023-10-16',
        ),
        CaseDocumentData(
          type: CaseDocumentType.image,
          title: '房产证复印件.jpg',
          meta: '2.5 MB · 2023-10-18',
        ),
      ],
    );
  }

  final CaseDetailStatus status;
  final String statusLabel;
  final String lastUpdatedLabel;
  final String title;
  final String caseNumber;
  final String dateLabel;
  final String dateValue;
  final double progress;
  final String progressLabel;
  final int activeStepIndex;
  final List<String> progressSteps;
  final String summary;
  final String plaintiffName;
  final String plaintiffCounsel;
  final String defendantName;
  final String defendantCounsel;
  final List<CaseDocumentData> documents;
}

@immutable
class CaseDocumentData {
  const CaseDocumentData({
    required this.type,
    required this.title,
    required this.meta,
  });

  final CaseDocumentType type;
  final String title;
  final String meta;
}

class CaseDetailPage extends StatelessWidget {
  const CaseDetailPage({super.key, required this.detail});

  final CaseDetailData detail;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: AppMobileCanvas(
        maxContentWidth: 520,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _CaseDetailHeader(
                title: '案件详情',
                onBack: () => Navigator.of(context).maybePop(),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    AppFadeSlideIn(
                      delay: const Duration(milliseconds: 40),
                      child: _OverviewSection(detail: detail),
                    ),
                    const _SectionBreak(),
                    AppFadeSlideIn(
                      delay: const Duration(milliseconds: 80),
                      child: _AiAnalysisStrip(
                        onPressed: () =>
                            context.push(RouteNames.analysisDetailPath),
                      ),
                    ),
                    const _SectionBreak(),
                    AppFadeSlideIn(
                      delay: const Duration(milliseconds: 120),
                      child: _ProgressSection(detail: detail),
                    ),
                    const _SectionBreak(),
                    AppFadeSlideIn(
                      delay: const Duration(milliseconds: 160),
                      child: _PartySection(detail: detail),
                    ),
                    const _SectionBreak(),
                    AppFadeSlideIn(
                      delay: const Duration(milliseconds: 200),
                      child: _SummarySection(summary: detail.summary),
                    ),
                    const _SectionBreak(),
                    AppFadeSlideIn(
                      delay: const Duration(milliseconds: 240),
                      child: _DocumentsSection(documents: detail.documents),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CaseDetailHeader extends StatelessWidget {
  const _CaseDetailHeader({required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.share_outlined)),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert_rounded),
          ),
        ],
      ),
    );
  }
}

class _OverviewSection extends StatelessWidget {
  const _OverviewSection({required this.detail});

  final CaseDetailData detail;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final statusStyle = _StatusStyle.resolve(context, detail.status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: statusStyle.background,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                child: Text(
                  detail.statusLabel,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: statusStyle.foreground,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const Spacer(),
            Text(
              detail.lastUpdatedLabel,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          detail.title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 14),
        _InfoLine(
          icon: Icons.fingerprint_rounded,
          label: '案号：${detail.caseNumber}',
        ),
        const SizedBox(height: 8),
        _InfoLine(
          icon: Icons.calendar_today_outlined,
          label: '${detail.dateLabel}：${detail.dateValue}',
        ),
      ],
    );
  }
}

class _AiAnalysisStrip extends StatelessWidget {
  const _AiAnalysisStrip({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.46),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.10)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  size: 18,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'AI 案件深度分析',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '基于大数据研判和法律大模型，对案件胜诉率、证据链完整度及诉讼风险给出结构化建议。',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              key: const ValueKey<String>('case_detail_analysis_button'),
              onPressed: onPressed,
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                minimumSize: const Size(0, 40),
              ),
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: const Text('开始分析'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressSection extends StatelessWidget {
  const _ProgressSection({required this.detail});

  final CaseDetailData detail;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final progressValue = detail.progress.clamp(0.0, 1.0).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '当前进度 (${(progressValue * 100).round()}%)',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 68,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Stack(
              children: [
                Positioned(
                  left: 14,
                  right: 14,
                  top: 16,
                  child: Container(
                    height: 2,
                    color: colorScheme.surfaceContainerHighest,
                  ),
                ),
                Positioned(
                  left: 14,
                  right: 14,
                  top: 16,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: progressValue,
                      child: Container(height: 2, color: colorScheme.primary),
                    ),
                  ),
                ),
                Row(
                  children: detail.progressSteps
                      .asMap()
                      .entries
                      .map((entry) {
                        final index = entry.key;
                        return Expanded(
                          child: _ProgressStep(
                            label: entry.value,
                            state: _resolveProgressStepState(
                              index: index,
                              activeIndex: detail.activeStepIndex,
                            ),
                            highlightColor: colorScheme.primary,
                          ),
                        );
                      })
                      .toList(growable: false),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '当前节点：${detail.progressLabel}',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _ProgressStep extends StatelessWidget {
  const _ProgressStep({
    required this.label,
    required this.state,
    required this.highlightColor,
  });

  final String label;
  final _ProgressStepState state;
  final Color highlightColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final bool isActive = state == _ProgressStepState.active;
    final bool isDone = state == _ProgressStepState.complete;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 32,
          child: Center(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone ? highlightColor : colorScheme.surface,
                border: Border.all(
                  color: isActive || isDone
                      ? highlightColor
                      : colorScheme.outline.withValues(alpha: 0.28),
                  width: isActive ? 2 : 1.4,
                ),
              ),
              child: SizedBox(
                width: 26,
                height: 26,
                child: Center(
                  child: isDone
                      ? Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: colorScheme.onPrimary,
                        )
                      : isActive
                      ? Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: highlightColor,
                          ),
                        )
                      : Icon(
                          Icons.gavel_rounded,
                          size: 14,
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.75,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: isActive
                ? highlightColor
                : colorScheme.onSurfaceVariant.withValues(
                    alpha: state == _ProgressStepState.pending ? 0.72 : 0.88,
                  ),
            fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _PartySection extends StatelessWidget {
  const _PartySection({required this.detail});

  final CaseDetailData detail;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(title: '当事人信息'),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _PartyColumn(
                role: '原告',
                name: detail.plaintiffName,
                counsel: detail.plaintiffCounsel,
              ),
            ),
            Container(
              width: 1,
              height: 60,
              color: colorScheme.outline.withValues(alpha: 0.14),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _PartyColumn(
                role: '被告',
                name: detail.defendantName,
                counsel: detail.defendantCounsel,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SummarySection extends StatelessWidget {
  const _SummarySection({required this.summary});

  final String summary;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(title: '案情摘要'),
        const SizedBox(height: 14),
        Text(
          summary,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            height: 1.75,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _DocumentsSection extends StatelessWidget {
  const _DocumentsSection({required this.documents});

  final List<CaseDocumentData> documents;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          title: '关联文档',
          trailing: TextButton(onPressed: () {}, child: const Text('上传文档')),
        ),
        const SizedBox(height: 8),
        ...documents.asMap().entries.map((entry) {
          return _DocumentRow(
            document: entry.value,
            showDivider: entry.key != documents.length - 1,
          );
        }),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        ...switch (trailing) {
          null => const <Widget>[],
          final trailing => <Widget>[trailing],
        },
      ],
    );
  }
}

class _PartyColumn extends StatelessWidget {
  const _PartyColumn({
    required this.role,
    required this.name,
    required this.counsel,
  });

  final String role;
  final String name;
  final String counsel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          role,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 6),
        Text(
          name,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          counsel,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _DocumentRow extends StatelessWidget {
  const _DocumentRow({required this.document, required this.showDivider});

  final CaseDocumentData document;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final tokens = context.tokens;
    final (icon, accent) = switch (document.type) {
      CaseDocumentType.pdf => (Icons.picture_as_pdf_rounded, tokens.danger),
      CaseDocumentType.image => (Icons.image_outlined, tokens.info),
      CaseDocumentType.note => (Icons.note_alt_outlined, tokens.warning),
    };

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      document.meta,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.download_rounded,
                size: 18,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
        if (showDivider)
          Container(
            height: 1,
            color: colorScheme.outline.withValues(alpha: 0.10),
          ),
      ],
    );
  }
}

class _SectionBreak extends StatelessWidget {
  const _SectionBreak();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Container(
        height: 1,
        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.10),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Row(
      children: [
        Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusStyle {
  const _StatusStyle({required this.background, required this.foreground});

  final Color background;
  final Color foreground;

  factory _StatusStyle.resolve(BuildContext context, CaseDetailStatus status) {
    final colorScheme = context.colorScheme;
    return switch (status) {
      CaseDetailStatus.inProgress => _StatusStyle(
        background: colorScheme.primaryContainer.withValues(alpha: 0.72),
        foreground: colorScheme.primary,
      ),
      CaseDetailStatus.closed => _StatusStyle(
        background: colorScheme.secondaryContainer.withValues(alpha: 0.72),
        foreground: colorScheme.secondary,
      ),
      CaseDetailStatus.waiting => _StatusStyle(
        background: colorScheme.tertiaryContainer.withValues(alpha: 0.72),
        foreground: colorScheme.tertiary,
      ),
    };
  }
}

enum _ProgressStepState { complete, active, pending }

_ProgressStepState _resolveProgressStepState({
  required int index,
  required int activeIndex,
}) {
  if (index < activeIndex) return _ProgressStepState.complete;
  if (index == activeIndex) return _ProgressStepState.active;
  return _ProgressStepState.pending;
}
