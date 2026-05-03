import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import 'package:lexcore/features/document/application/document_providers.dart';
import 'package:lexcore/shared/components/app_surface_card.dart';
import 'package:lexcore/shared/models/legal_models.dart';
import 'package:lexcore/shared/widgets/app_page_scaffold.dart';

class SavedDocumentDetailPage extends ConsumerStatefulWidget {
  const SavedDocumentDetailPage({
    super.key,
    required this.documentId,
    this.startInEditMode = false,
  });

  final String documentId;
  final bool startInEditMode;

  @override
  ConsumerState<SavedDocumentDetailPage> createState() =>
      _SavedDocumentDetailPageState();
}

class _SavedDocumentDetailPageState
    extends ConsumerState<SavedDocumentDetailPage> {
  static const Duration _pollInterval = Duration(seconds: 2);
  static const int _maxPollAttempts = 60;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _markdownController = TextEditingController();

  bool _editMode = false;
  bool _boundDocument = false;
  bool _polling = false;
  bool _pollTimedOut = false;
  int _pollAttempts = 0;
  DateTime? _lastPolledAt;
  Future<void>? _pollTask;

  @override
  void initState() {
    super.initState();
    _editMode = widget.startInEditMode;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(documentControllerProvider.notifier)
          .loadDetail(widget.documentId);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _markdownController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<String?>(
      documentControllerProvider.select((state) => state.feedbackMessage),
      (previous, message) {
        if (message == null || message.isEmpty || !mounted) {
          return;
        }
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
        ref.read(documentControllerProvider.notifier).clearFeedbackMessage();
      },
    );

    ref.listen<DocumentItem?>(documentByIdProvider(widget.documentId), (
      previous,
      next,
    ) {
      if (!mounted || next == null) {
        return;
      }
      if (next.status != 'completed' && _editMode) {
        setState(() {
          _editMode = false;
        });
      }
      _syncPollingState(next);
    });

    final documentState = ref.watch(documentControllerProvider);
    final document = ref.watch(documentByIdProvider(widget.documentId));
    final canEdit = document?.status == 'completed';

    if (document != null && !_boundDocument) {
      _titleController.text = document.name;
      _markdownController.text = document.markdown;
      _boundDocument = true;
    }

    return AppPageScaffold(
      title: _editMode ? '编辑文档' : '文档详情',
      actions: [
        IconButton(
          onPressed: () => _refreshDetail(),
          tooltip: '刷新状态',
          icon: const Icon(Icons.refresh),
        ),
        IconButton(
          onPressed: canEdit
              ? () {
                  setState(() {
                    _editMode = !_editMode;
                  });
                }
              : null,
          tooltip: canEdit ? (_editMode ? '切换查看' : '进入编辑') : '文档生成完成后可编辑',
          icon: Icon(_editMode ? Icons.remove_red_eye_outlined : Icons.edit),
        ),
      ],
      body: document == null
          ? _DetailPlaceholder(
              loading: documentState.detailLoading,
              onRetry: _refreshDetail,
            )
          : ListView(
              children: [
                AppSurfaceCard(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.08),
                  child: Row(
                    children: [
                      Icon(
                        Icons.description_outlined,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          document.type,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                      _StatusChip(status: document.status),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _editMode
                              ? Theme.of(context).colorScheme.tertiaryContainer
                              : Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          _editMode ? '编辑模式' : '查看模式',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: _editMode
                                    ? Theme.of(
                                        context,
                                      ).colorScheme.onTertiaryContainer
                                    : Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (document.status == 'queued' ||
                    document.status == 'processing')
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: _GeneratingStateCard(
                      polling: _polling,
                      pollTimedOut: _pollTimedOut,
                      pollAttempts: _pollAttempts,
                      lastPolledAt: _lastPolledAt,
                      onRetry: _refreshDetail,
                    ),
                  ),
                if (document.status == 'failed')
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: _FailedStateCard(
                      errorMessage: document.errorMessage,
                      onRetry: _refreshDetail,
                    ),
                  ),
                const SizedBox(height: 12),
                if (_editMode && canEdit)
                  _EditForm(
                    titleController: _titleController,
                    markdownController: _markdownController,
                    saving: documentState.saving,
                    onCancel: () {
                      _titleController.text = document.name;
                      _markdownController.text = document.markdown;
                      setState(() {
                        _editMode = false;
                      });
                    },
                    onSave: () => _saveDocument(document.id),
                  )
                else
                  _ReadOnlyDocument(
                    title: document.name,
                    markdown: document.markdown,
                  ),
              ],
            ),
    );
  }

  Future<void> _refreshDetail() async {
    final item = await ref
        .read(documentControllerProvider.notifier)
        .loadDetail(widget.documentId);
    if (!mounted || item == null) {
      return;
    }
    _syncPollingState(item);
  }

  void _syncPollingState(DocumentItem document) {
    final isPending =
        document.status == 'queued' || document.status == 'processing';
    final isTerminal =
        document.status == 'completed' || document.status == 'failed';

    if (isTerminal && _polling) {
      setState(() {
        _polling = false;
        _pollTimedOut = false;
      });
    }

    if (!isPending || _pollTask != null) {
      return;
    }

    _pollTask = _runAutoPolling();
  }

  Future<void> _runAutoPolling() async {
    if (!mounted) {
      _pollTask = null;
      return;
    }

    setState(() {
      _polling = true;
      _pollTimedOut = false;
      _pollAttempts = 0;
    });

    for (var i = 0; i < _maxPollAttempts; i++) {
      await Future<void>.delayed(_pollInterval);
      if (!mounted) {
        _pollTask = null;
        return;
      }

      final item = await ref
          .read(documentControllerProvider.notifier)
          .loadDetail(widget.documentId);
      if (!mounted) {
        _pollTask = null;
        return;
      }

      setState(() {
        _pollAttempts = i + 1;
        _lastPolledAt = DateTime.now();
      });

      if (item == null) {
        continue;
      }
      if (item.status == 'completed' || item.status == 'failed') {
        setState(() {
          _polling = false;
          _pollTimedOut = false;
        });
        _pollTask = null;
        return;
      }
    }

    if (mounted) {
      setState(() {
        _polling = false;
        _pollTimedOut = true;
      });
    }
    _pollTask = null;
  }

  Future<void> _saveDocument(String documentId) async {
    final updated = await ref
        .read(documentControllerProvider.notifier)
        .updateDocument(
          id: documentId,
          title: _titleController.text,
          markdown: _markdownController.text,
        );
    if (!mounted || updated == null) {
      return;
    }
    _titleController.text = updated.name;
    _markdownController.text = updated.markdown;
    setState(() {
      _editMode = false;
    });
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final (label, bgColor, textColor) = switch (status) {
      'completed' => (
        '已完成',
        Theme.of(context).colorScheme.primary,
        Theme.of(context).colorScheme.onPrimary,
      ),
      'failed' => (
        '失败',
        Theme.of(context).colorScheme.error,
        Theme.of(context).colorScheme.onError,
      ),
      'processing' => (
        '处理中',
        Theme.of(context).colorScheme.tertiary,
        Theme.of(context).colorScheme.onTertiary,
      ),
      _ => (
        '排队中',
        Theme.of(context).colorScheme.onSurfaceVariant,
        Theme.of(context).colorScheme.surface,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _GeneratingStateCard extends StatelessWidget {
  const _GeneratingStateCard({
    required this.polling,
    required this.pollTimedOut,
    required this.pollAttempts,
    required this.lastPolledAt,
    required this.onRetry,
  });

  final bool polling;
  final bool pollTimedOut;
  final int pollAttempts;
  final DateTime? lastPolledAt;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final lastCheckedText = lastPolledAt == null
        ? '尚未刷新'
        : '最近刷新：${lastPolledAt!.hour.toString().padLeft(2, '0')}:${lastPolledAt!.minute.toString().padLeft(2, '0')}:${lastPolledAt!.second.toString().padLeft(2, '0')}';
    final stageText = _resolveStageText(
      pollTimedOut: pollTimedOut,
      pollAttempts: pollAttempts,
    );
    final colorScheme = Theme.of(context).colorScheme;

    return AppSurfaceCard(
      backgroundColor: colorScheme.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _GeneratingPulseIcon(active: polling),
              const SizedBox(width: 8),
              Text(
                pollTimedOut ? '文书生成耗时较长' : '文书生成中',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(stageText, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 10),
          if (!pollTimedOut)
            Shimmer.fromColors(
              baseColor: colorScheme.surfaceContainerHighest,
              highlightColor: colorScheme.surfaceContainerLow,
              child: Column(
                children: const [
                  _SkeletonLine(widthFactor: 0.92),
                  SizedBox(height: 8),
                  _SkeletonLine(widthFactor: 0.78),
                  SizedBox(height: 8),
                  _SkeletonLine(widthFactor: 0.86),
                ],
              ),
            )
          else
            Text(
              '自动刷新已超时，请手动刷新继续查看最新状态。',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          const SizedBox(height: 6),
          Text(
            '已刷新 $pollAttempts 次 · $lastCheckedText',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('手动刷新状态'),
          ),
        ],
      ),
    );
  }

  String _resolveStageText({
    required bool pollTimedOut,
    required int pollAttempts,
  }) {
    if (pollTimedOut) {
      return '系统仍在排队或生成中，生成时间超过预期。';
    }
    if (pollAttempts < 4) {
      return '正在整理案件要点并匹配文书结构...';
    }
    if (pollAttempts < 12) {
      return '正在生成文书主体内容并补全关键条款...';
    }
    return '正在校验格式与段落完整性，请稍候...';
  }
}

class _GeneratingPulseIcon extends StatefulWidget {
  const _GeneratingPulseIcon({required this.active});

  final bool active;

  @override
  State<_GeneratingPulseIcon> createState() => _GeneratingPulseIconState();
}

class _GeneratingPulseIconState extends State<_GeneratingPulseIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );
    if (widget.active) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant _GeneratingPulseIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active == widget.active) {
      return;
    }
    if (widget.active) {
      _controller.repeat();
    } else {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = _controller.value;
        final scale = widget.active ? 0.9 + (progress * 0.2) : 1.0;
        final turns = widget.active ? progress : 0.0;
        return Transform.rotate(
          angle: turns * 6.283185307179586,
          child: Transform.scale(scale: scale, child: child),
        );
      },
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.14),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.auto_awesome,
          size: 14,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  const _SkeletonLine({required this.widthFactor});

  final double widthFactor;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      alignment: Alignment.centerLeft,
      child: Container(
        height: 12,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}

class _FailedStateCard extends StatelessWidget {
  const _FailedStateCard({required this.errorMessage, required this.onRetry});

  final String? errorMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      backgroundColor: Theme.of(context).colorScheme.errorContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
              const SizedBox(width: 8),
              Text(
                '文书生成失败',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage?.trim().isNotEmpty == true
                ? errorMessage!.trim()
                : '生成失败，请稍后重试',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('重试刷新'),
          ),
        ],
      ),
    );
  }
}

class _ReadOnlyDocument extends StatelessWidget {
  const _ReadOnlyDocument({required this.title, required this.markdown});

  final String title;
  final String markdown;

  @override
  Widget build(BuildContext context) {
    final styleSheet = MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
      h1: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        height: 1.3,
      ),
      h2: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        height: 1.35,
      ),
      p: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.75),
      blockquote: Theme.of(
        context,
      ).textTheme.bodyMedium?.copyWith(height: 1.75),
      listBullet: Theme.of(context).textTheme.bodyMedium,
    );

    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          MarkdownBody(data: markdown, styleSheet: styleSheet),
        ],
      ),
    );
  }
}

class _EditForm extends StatelessWidget {
  const _EditForm({
    required this.titleController,
    required this.markdownController,
    required this.saving,
    required this.onCancel,
    required this.onSave,
  });

  final TextEditingController titleController;
  final TextEditingController markdownController;
  final bool saving;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: titleController,
            decoration: const InputDecoration(
              labelText: '文档标题',
              prefixIcon: Icon(Icons.title_outlined),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: markdownController,
            minLines: 14,
            maxLines: 18,
            decoration: const InputDecoration(
              labelText: '文档内容（Markdown）',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: saving ? null : onCancel,
                  child: const Text('取消'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: saving ? null : onSave,
                  icon: saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(saving ? '保存中...' : '保存'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailPlaceholder extends StatelessWidget {
  const _DetailPlaceholder({required this.loading, required this.onRetry});

  final bool loading;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: AppSurfaceCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.description_outlined,
                size: 36,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 10),
              Text('未找到文档', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),
              Text(
                '文档可能已被删除或尚未同步。',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('重新加载'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
