import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:lexcore/app/motion/app_motion_widgets.dart';
import 'package:lexcore/shared/widgets/app_mobile_canvas.dart';

class ConsultationStitchDetailPage extends StatelessWidget {
  const ConsultationStitchDetailPage({super.key, this.summary});

  final String? summary;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final displayFont = GoogleFonts.publicSansTextTheme(textTheme);

    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: displayFont,
        scaffoldBackgroundColor: Theme.of(context).colorScheme.surface,
      ),
      child: Scaffold(
        body: AppMobileCanvas(
          maxContentWidth: 520,
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                _DetailHeader(onBack: () => Navigator.of(context).maybePop()),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: [
                      const AppFadeSlideIn(
                        delay: Duration(milliseconds: 40),
                        child: _HeroCard(),
                      ),
                      const SizedBox(height: 16),
                      AppFadeSlideIn(
                        delay: const Duration(milliseconds: 80),
                        child: _SectionCard(
                          icon: Icons.psychology_alt_outlined,
                          title: '问题理解',
                          child: Text(
                            summary?.trim().isNotEmpty == true
                                ? summary!
                                : '根据您的描述，LexiAI 已识别出该法律问题的核心在于劳动合同纠纷中的加班费争议，涉及入职时间、劳动合同条款及考勤记录完整性。',
                            style: displayFont.bodyMedium?.copyWith(
                              height: 1.6,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const AppFadeSlideIn(
                        delay: Duration(milliseconds: 120),
                        child: _SectionCard(
                          icon: Icons.menu_book_outlined,
                          title: '法律依据',
                          child: Column(
                            children: [
                              _LawItem(
                                title: '《中华人民共和国劳动法》第四十四条',
                                content: '用人单位安排加班的，应当按照国家有关规定向劳动者支付加班费。',
                              ),
                              SizedBox(height: 10),
                              _LawItem(
                                title: '《劳动合同法》第三十一条',
                                content: '用人单位应当严格执行劳动定额标准，不得强迫或者变相强迫劳动者加班。',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const AppFadeSlideIn(
                        delay: Duration(milliseconds: 160),
                        child: _SectionCard(
                          icon: Icons.analytics_outlined,
                          title: '详细分析',
                          child: Column(
                            children: [
                              _AnalysisStep(
                                index: 1,
                                title: '考勤数据分析',
                                content:
                                    '您的打卡记录显示平均每周工作时长超过 50 小时，已明显高于法定工作时长上限。',
                              ),
                              SizedBox(height: 14),
                              _AnalysisStep(
                                index: 2,
                                title: '建议补救措施',
                                content: '建议优先与公司人力资源部门书面协商，并保留邮件、聊天记录和考勤导出文件。',
                              ),
                              SizedBox(height: 14),
                              _AnalysisStep(
                                index: 3,
                                title: '仲裁风险评估',
                                content:
                                    '若目前证据链完整，协商无果后申请劳动仲裁的可支持性较高，但仍需补强加班审批与薪资流水。',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      AppFadeSlideIn(
                        delay: const Duration(milliseconds: 220),
                        child: SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () {},
                            style: FilledButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              foregroundColor: Theme.of(
                                context,
                              ).colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: Text(
                              '获取更详细的法律意见书',
                              style: displayFont.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({required this.onBack});

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
              'LexiAI 解答详情',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.share_outlined)),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.secondaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(
              Icons.gavel_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: 34,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '专业法律智能分析',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            height: 1,
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _LawItem extends StatelessWidget {
  const _LawItem({required this.title, required this.content});

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 4,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalysisStep extends StatelessWidget {
  const _AnalysisStep({
    required this.index,
    required this.title,
    required this.content,
  });

  final int index;
  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
          ),
          child: Text(
            '$index',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.55,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
