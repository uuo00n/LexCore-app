import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lexcore/app/adaptive/app_adaptive_split_view.dart';
import 'package:lexcore/app/adaptive/app_breakpoints.dart';
import 'package:lexcore/app/motion/app_motion_widgets.dart';
import 'package:lexcore/app/router/route_names.dart';
import 'package:lexcore/core/extensions/context_extensions.dart';
import 'package:lexcore/core/utils/app_share.dart';
import 'package:lexcore/core/utils/feature_notice.dart';
import 'package:lexcore/features/consultation/application/consultation_controller.dart';
import 'package:lexcore/shared/components/app_surface_card.dart';
import 'package:lexcore/shared/models/legal_models.dart';
import 'package:lexcore/shared/widgets/app_page_scaffold.dart';

class ConsultationPage extends ConsumerStatefulWidget {
  const ConsultationPage({super.key, required this.threadId, this.threadTitle});

  final String threadId;
  final String? threadTitle;

  @override
  ConsumerState<ConsultationPage> createState() => _ConsultationPageState();
}

class _ConsultationPageState extends ConsumerState<ConsultationPage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _messageScrollController = ScrollController();

  bool _hasHandledInitialScroll = false;
  bool _hasScheduledScroll = false;
  bool _scheduledScrollAnimated = false;
  int _lastMessageCount = 0;
  bool _lastIsAiThinking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final controller = ref.read(consultationStateControllerProvider.notifier);
      controller.ensureThread(widget.threadId, title: widget.threadTitle);
      controller.selectThread(widget.threadId);
      unawaited(controller.syncRemoteMessages(widget.threadId));
      _scheduleScrollToBottom(animated: false);
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _messageScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final thread = ref.watch(consultationThreadProvider(widget.threadId));
    final messages = ref.watch(consultationMessagesProvider(widget.threadId));
    final isAiThinking = ref.watch(
      consultationIsAiThinkingProvider(widget.threadId),
    );
    _handleAutoScroll(
      messageCount: messages.length,
      isAiThinking: isAiThinking,
    );

    return AppPageScaffold(
      title: thread.title,
      bodyPadding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      actions: [
        IconButton(
          key: const ValueKey('consultation_more_button'),
          onPressed: _openThreadMenu,
          icon: const Icon(Icons.more_horiz_rounded),
          tooltip: '更多操作',
        ),
      ],
      body: LayoutBuilder(
        builder: (context, constraints) {
          final viewport = AppBreakpoints.fromWidth(constraints.maxWidth);
          final splitLayout =
              viewport == AppViewportSize.expanded ||
              viewport == AppViewportSize.ultra;
          final bubbleMaxWidth = splitLayout ? 420.0 : 300.0;

          if (splitLayout) {
            return AppAdaptiveSplitView(
              splitMinWidth: 980,
              secondaryMaxWidth: 340,
              primary: _ConversationPane(
                messages: messages,
                isAiThinking: isAiThinking,
                bubbleMaxWidth: bubbleMaxWidth,
                scrollController: _messageScrollController,
                textController: _textController,
                onSend: _sendMessage,
              ),
              secondary: _ConsultationSidePanel(messages: messages),
            );
          }

          return _ConversationPane(
            messages: messages,
            isAiThinking: isAiThinking,
            bubbleMaxWidth: bubbleMaxWidth,
            scrollController: _messageScrollController,
            textController: _textController,
            onSend: _sendMessage,
          );
        },
      ),
    );
  }

  void _sendMessage() {
    final text = _textController.text;
    if (text.trim().isEmpty) {
      return;
    }
    unawaited(
      ref
          .read(consultationStateControllerProvider.notifier)
          .send(widget.threadId, text),
    );
    _textController.clear();
  }

  void _handleAutoScroll({
    required int messageCount,
    required bool isAiThinking,
  }) {
    if (!_hasHandledInitialScroll) {
      _hasHandledInitialScroll = true;
      _scheduleScrollToBottom(animated: false);
    } else {
      final didMessageCountIncrease = messageCount > _lastMessageCount;
      final didThinkingStateChange = isAiThinking != _lastIsAiThinking;
      final shouldScrollForMessages =
          didMessageCountIncrease && (!isAiThinking || _lastIsAiThinking);

      if (didThinkingStateChange || shouldScrollForMessages) {
        _scheduleScrollToBottom();
      }
    }

    _lastMessageCount = messageCount;
    _lastIsAiThinking = isAiThinking;
  }

  void _scheduleScrollToBottom({bool animated = true}) {
    if (_hasScheduledScroll) {
      _scheduledScrollAnimated = _scheduledScrollAnimated || animated;
      return;
    }

    _hasScheduledScroll = true;
    _scheduledScrollAnimated = animated;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _hasScheduledScroll = false;
      final shouldAnimate = _scheduledScrollAnimated;
      _scheduledScrollAnimated = false;
      _scrollToBottom(shouldAnimate, attempt: 0);
    });
  }

  void _scrollToBottom(bool animated, {required int attempt}) {
    if (!mounted || !_messageScrollController.hasClients) {
      return;
    }

    final position = _messageScrollController.position;
    final targetOffset = position.maxScrollExtent;
    if (!position.hasContentDimensions || targetOffset <= 0) {
      _messageScrollController.jumpTo(0);
      return;
    }

    final currentOffset = position.pixels;
    if ((currentOffset - targetOffset).abs() < 1) {
      return;
    }

    if (animated) {
      unawaited(
        _messageScrollController
            .animateTo(
              targetOffset,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
            )
            .whenComplete(() => _scheduleScrollCorrection(attempt + 1)),
      );
      return;
    }

    _messageScrollController.jumpTo(targetOffset);
    _scheduleScrollCorrection(attempt + 1);
  }

  void _scheduleScrollCorrection(int attempt) {
    if (attempt > 3) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_messageScrollController.hasClients) {
        return;
      }
      final position = _messageScrollController.position;
      if ((position.maxScrollExtent - position.pixels).abs() >= 1) {
        _scrollToBottom(false, attempt: attempt);
      }
      _scheduleScrollCorrection(attempt + 1);
    });
  }

  Future<void> _openThreadMenu() async {
    final colorScheme = Theme.of(context).colorScheme;
    final action = await showGeneralDialog<_ThreadMenuAction>(
      context: context,
      barrierDismissible: true,
      barrierLabel: '关闭菜单',
      barrierColor: colorScheme.scrim.withValues(alpha: 0.32),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        final screenWidth = MediaQuery.of(dialogContext).size.width;
        final panelWidth = screenWidth > 540 ? 340.0 : screenWidth * 0.82;

        return SafeArea(
          child: Align(
            alignment: Alignment.centerRight,
            child: Material(
              color: colorScheme.surface,
              elevation: 6,
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(24),
              ),
              child: SizedBox(
                width: panelWidth,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 8, 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '对话操作',
                              style: Theme.of(dialogContext)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          IconButton(
                            tooltip: '关闭',
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.edit_outlined),
                      title: const Text('重命名对话'),
                      onTap: () => Navigator.of(
                        dialogContext,
                      ).pop(_ThreadMenuAction.rename),
                    ),
                    ListTile(
                      leading: const Icon(Icons.share_outlined),
                      title: const Text('分享对话'),
                      onTap: () => Navigator.of(
                        dialogContext,
                      ).pop(_ThreadMenuAction.share),
                    ),
                    ListTile(
                      leading: const Icon(Icons.cleaning_services_outlined),
                      title: const Text('清空当前对话'),
                      onTap: () => Navigator.of(
                        dialogContext,
                      ).pop(_ThreadMenuAction.clear),
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.delete_outline_rounded,
                        color: colorScheme.error,
                      ),
                      title: Text(
                        '删除对话',
                        style: Theme.of(dialogContext).textTheme.bodyLarge
                            ?.copyWith(color: colorScheme.error),
                      ),
                      onTap: () => Navigator.of(
                        dialogContext,
                      ).pop(_ThreadMenuAction.delete),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (dialogContext, animation, secondaryAnimation, child) {
        final curve = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curve,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.12, 0),
              end: Offset.zero,
            ).animate(curve),
            child: child,
          ),
        );
      },
    );
    if (!mounted || action == null) return;

    switch (action) {
      case _ThreadMenuAction.rename:
        await _renameThread();
        break;
      case _ThreadMenuAction.share:
        await _shareThread();
        break;
      case _ThreadMenuAction.clear:
        await _clearThread();
        break;
      case _ThreadMenuAction.delete:
        await _deleteThread();
        break;
    }
  }

  Future<void> _renameThread() async {
    final currentTitle = ref
        .read(consultationThreadProvider(widget.threadId))
        .title;
    final controller = TextEditingController(text: currentTitle);
    final renamed = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('重命名对话'),
          content: TextField(
            key: const ValueKey('consultation_rename_input'),
            controller: controller,
            autofocus: true,
            maxLength: 30,
            decoration: const InputDecoration(hintText: '请输入新标题'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('取消'),
            ),
            FilledButton(
              key: const ValueKey('consultation_rename_confirm'),
              onPressed: () => Navigator.of(dialogContext).pop(controller.text),
              child: const Text('保存'),
            ),
          ],
        );
      },
    );
    if (!mounted || renamed == null) return;

    final normalized = renamed.trim();
    if (normalized.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('标题不能为空')));
      return;
    }

    ref
        .read(consultationStateControllerProvider.notifier)
        .renameThread(widget.threadId, normalized);
  }

  Future<void> _shareThread() async {
    final thread = ref.read(consultationThreadProvider(widget.threadId));
    final text = ref
        .read(consultationStateControllerProvider.notifier)
        .buildShareText(widget.threadId);
    try {
      await AppShare.shareText(
        pageContext: context,
        text: text,
        subject: thread.title,
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('分享失败，请稍后重试')));
    }
  }

  Future<void> _clearThread() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('清空当前对话'),
          content: const Text('清空后将移除当前会话全部消息，是否继续？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('取消'),
            ),
            FilledButton(
              key: const ValueKey('consultation_clear_confirm'),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('确认清空'),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) return;
    ref
        .read(consultationStateControllerProvider.notifier)
        .clearThread(widget.threadId);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('已清空当前对话')));
  }

  Future<void> _deleteThread() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('删除对话'),
          content: const Text('删除后不可恢复，是否继续？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('取消'),
            ),
            FilledButton(
              key: const ValueKey('consultation_delete_confirm'),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('确认删除'),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) return;
    final deleted = ref
        .read(consultationStateControllerProvider.notifier)
        .deleteThread(widget.threadId);
    if (!deleted || !mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('对话已删除')));
    context.pop();
  }
}

enum _ThreadMenuAction { rename, share, clear, delete }

class _ConversationPane extends StatelessWidget {
  const _ConversationPane({
    required this.messages,
    required this.isAiThinking,
    required this.bubbleMaxWidth,
    required this.scrollController,
    required this.textController,
    required this.onSend,
  });

  final List<ChatMessage> messages;
  final bool isAiThinking;
  final double bubbleMaxWidth;
  final ScrollController scrollController;
  final TextEditingController textController;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final conversationItems = _buildConversationItems(context);

    return Column(
      children: [
        Expanded(
          child: messages.isEmpty && !isAiThinking
              ? Center(
                  child: Text(
                    '发送消息开始咨询',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              : ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(4, 2, 4, 8),
                  children: conversationItems,
                ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
          child: Row(
            children: [
              IconButton(
                onPressed: () => showFeatureInProgressSnackBar(
                  context,
                  featureLabel: '附件上传',
                ),
                icon: const Icon(Icons.add),
              ),
              Expanded(
                child: TextField(
                  controller: textController,
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
                onPressed: isAiThinking ? null : onSend,
                child: isAiThinking
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildConversationItems(BuildContext context) {
    final totalCount = messages.length + (isAiThinking ? 1 : 0);
    final items = <Widget>[];

    for (var index = 0; index < totalCount; index++) {
      if (index == messages.length && isAiThinking) {
        items.add(
          AppFadeSlideIn(
            key: const ValueKey<String>('consultation_ai_thinking'),
            delay: Duration(milliseconds: 20 + (index * 35)),
            beginOffset: const Offset(0, 0.02),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  child: const Icon(Icons.smart_toy_outlined, size: 18),
                ),
                const SizedBox(width: 8),
                Flexible(child: _AiThinkingBubble(maxWidth: bubbleMaxWidth)),
              ],
            ),
          ),
        );
      } else {
        final item = messages[index];
        final isUser = item.role == ChatRole.user;
        items.add(
          AppFadeSlideIn(
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
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
                    child: const Icon(Icons.smart_toy_outlined, size: 18),
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
                        constraints: BoxConstraints(maxWidth: bubbleMaxWidth),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isUser
                              ? context.tokens.chatUserBubble
                              : context.tokens.chatAiBubble,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(isUser ? 16 : 4),
                            bottomRight: Radius.circular(isUser ? 4 : 16),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.content,
                              style: TextStyle(
                                color: isUser
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            if (!isUser && item.content.trim().isNotEmpty) ...[
                              const SizedBox(height: 8),
                              TextButton.icon(
                                onPressed: () => context.pushNamed(
                                  RouteNames.consultationStitchDetail,
                                  extra: item.content,
                                ),
                                icon: const Icon(
                                  Icons.open_in_new_rounded,
                                  size: 14,
                                ),
                                label: const Text('查看结果详情'),
                                style: TextButton.styleFrom(
                                  foregroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primary.withValues(alpha: 0.08),
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .labelMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                  minimumSize: const Size(0, 32),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: const VisualDensity(
                                    horizontal: -2,
                                    vertical: -2,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                              ),
                            ],
                            if (item.references.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: item.references
                                    .map(
                                      (reference) => Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isUser
                                              ? Theme.of(context)
                                                    .colorScheme
                                                    .onPrimary
                                                    .withValues(alpha: 0.2)
                                              : Theme.of(context)
                                                    .colorScheme
                                                    .surfaceContainerLowest,
                                          borderRadius: BorderRadius.circular(
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
                                                    ? Theme.of(
                                                        context,
                                                      ).colorScheme.onPrimary
                                                    : Theme.of(context)
                                                          .colorScheme
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
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.13),
                    child: const Icon(Icons.person, size: 18),
                  ),
                ],
              ],
            ),
          ),
        );
      }

      if (index != totalCount - 1) {
        items.add(const SizedBox(height: 12));
      }
    }

    return items;
  }
}

class _AiThinkingBubble extends StatefulWidget {
  const _AiThinkingBubble({required this.maxWidth});

  final double maxWidth;

  @override
  State<_AiThinkingBubble> createState() => _AiThinkingBubbleState();
}

class _AiThinkingBubbleState extends State<_AiThinkingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: widget.maxWidth),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: context.tokens.chatAiBubble,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
          bottomLeft: Radius.circular(4),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'LexCore 正在思考',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 8),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Row(
                children: List.generate(3, (index) {
                  final value = _controller.value;
                  final phase = ((value + index * 0.2) % 1.0) * 2 * math.pi;
                  final pulse = (math.sin(phase - math.pi / 2) + 1) / 2;
                  final opacity = 0.25 + pulse * 0.75;
                  final scale = 0.75 + pulse * 0.35;

                  return Padding(
                    padding: EdgeInsets.only(right: index == 2 ? 0 : 4),
                    child: Opacity(
                      opacity: opacity.clamp(0, 1).toDouble(),
                      child: Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ConsultationSidePanel extends StatelessWidget {
  const _ConsultationSidePanel({required this.messages});

  final List<ChatMessage> messages;

  @override
  Widget build(BuildContext context) {
    final references = <String>{};
    for (final message in messages) {
      references.addAll(message.references);
    }

    return ListView(
      children: [
        AppFadeSlideIn(
          delay: const Duration(milliseconds: 80),
          child: AppSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('咨询摘要', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Text(
                  '共 ${messages.length} 条对话，建议优先补充关键事实、时间线与证据来源。',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        AppFadeSlideIn(
          delay: const Duration(milliseconds: 120),
          child: AppSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('参考法条', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                if (references.isEmpty)
                  Text(
                    '暂无引用，继续提问可自动补全参考法条。',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: references
                        .map(
                          (reference) => Chip(
                            label: Text(reference),
                            visualDensity: const VisualDensity(
                              horizontal: -2,
                              vertical: -2,
                            ),
                          ),
                        )
                        .toList(),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
