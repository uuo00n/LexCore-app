import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lexcore/app/motion/app_motion_widgets.dart';
import 'package:lexcore/app/theme/app_colors.dart';
import 'package:lexcore/core/extensions/context_extensions.dart';
import 'package:lexcore/features/consultation/application/consultation_controller.dart';
import 'package:lexcore/shared/models/legal_models.dart';
import 'package:lexcore/shared/widgets/app_mobile_canvas.dart';

class ConsultationPage extends ConsumerStatefulWidget {
  const ConsultationPage({super.key});

  @override
  ConsumerState<ConsultationPage> createState() => _ConsultationPageState();
}

class _ConsultationPageState extends ConsumerState<ConsultationPage> {
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(consultationControllerProvider);

    return Scaffold(
      body: AppMobileCanvas(
        child: SafeArea(
          child: Column(
            children: [
              Container(
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back),
                    ),
                    const SizedBox(width: 4),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'LexiAI 智能咨询',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Text(
                          '在线咨询中',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.more_vert),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                  itemCount: messages.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = messages[index];
                    final isUser = item.role == ChatRole.user;
                    return AppFadeSlideIn(
                      key: ValueKey('${item.role.name}-$index-${item.content}'),
                      delay: Duration(milliseconds: 20 + (index * 35)),
                      beginOffset: const Offset(0, 0.02),
                      child: Row(
                        mainAxisAlignment: isUser
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!isUser) ...[
                            const CircleAvatar(
                              radius: 18,
                              backgroundColor: AppColors.primaryContainer,
                              child: Icon(Icons.smart_toy_outlined, size: 18),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Flexible(
                            child: Column(
                              crossAxisAlignment: isUser
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                Container(
                                  constraints: const BoxConstraints(
                                    maxWidth: 300,
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isUser
                                        ? context.tokens.chatUserBubble
                                        : context.tokens.chatAiBubble,
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(16),
                                      topRight: const Radius.circular(16),
                                      bottomLeft: Radius.circular(
                                        isUser ? 16 : 4,
                                      ),
                                      bottomRight: Radius.circular(
                                        isUser ? 4 : 16,
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.content,
                                        style: TextStyle(
                                          color: isUser
                                              ? Colors.white
                                              : AppColors.onSurface,
                                        ),
                                      ),
                                      if (item.references.isNotEmpty) ...[
                                        const SizedBox(height: 10),
                                        Wrap(
                                          spacing: 6,
                                          runSpacing: 6,
                                          children: item.references
                                              .map(
                                                (reference) => Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: isUser
                                                        ? Colors.white
                                                              .withValues(
                                                                alpha: 0.2,
                                                              )
                                                        : Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          999,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    reference,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .labelMedium
                                                        ?.copyWith(
                                                          color: isUser
                                                              ? Colors.white
                                                              : AppColors
                                                                    .onSurfaceVariant,
                                                        ),
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isUser) ...[
                            const SizedBox(width: 8),
                            const CircleAvatar(
                              radius: 18,
                              backgroundColor: Color(0x220B50DA),
                              child: Icon(Icons.person, size: 18),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                child: Row(
                  children: [
                    IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        decoration: const InputDecoration(
                          hintText: '请输入您的问题...',
                          suffixIcon: Icon(Icons.mic_none),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(12),
                        minimumSize: const Size(46, 46),
                      ),
                      onPressed: () {
                        ref
                            .read(consultationControllerProvider.notifier)
                            .send(_textController.text);
                        _textController.clear();
                      },
                      child: const Icon(Icons.send),
                    ),
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
