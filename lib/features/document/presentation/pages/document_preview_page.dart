import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lexcore/app/motion/app_motion_widgets.dart';
import 'package:lexcore/app/theme/app_colors.dart';
import 'package:lexcore/features/document/application/document_providers.dart';
import 'package:lexcore/shared/widgets/app_mobile_canvas.dart';

class DocumentPreviewPage extends ConsumerWidget {
  const DocumentPreviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(generatedDraftProvider);

    return Scaffold(
      body: AppMobileCanvas(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 6),
                child: AppFadeSlideIn(
                  delay: const Duration(milliseconds: 20),
                  beginOffset: const Offset(0, -0.02),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      Text(
                        '文档预览',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.share_outlined),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.more_vert),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 110),
                  children: [
                    AppFadeSlideIn(
                      delay: const Duration(milliseconds: 70),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          height: 170,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF0B50DA), Color(0xFF1D3DBA)],
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
                                    color: Colors.white.withValues(alpha: 0.14),
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
                                    color: Colors.white.withValues(alpha: 0.2),
                                  ),
                                  child: Text(
                                    'AI 智能分析',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium
                                        ?.copyWith(
                                          color: Colors.white,
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
                      child: Card(
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                draft.title,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '由 LexiAI 生成 · 2024年5月20日',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                    ),
                              ),
                              const SizedBox(height: 12),
                              MarkdownBody(data: draft.markdown),
                            ],
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
      bottomNavigationBar: AppMobileCanvas(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border(
              top: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
          child: Row(
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
                  onPressed: () {},
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  label: const Text('下载 PDF'),
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
          ),
        ),
      ),
    );
  }
}
