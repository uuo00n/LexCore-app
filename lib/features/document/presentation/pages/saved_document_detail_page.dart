import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lexcore/features/document/application/document_providers.dart';
import 'package:lexcore/shared/components/app_surface_card.dart';
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
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _markdownController = TextEditingController();
  bool _editMode = false;
  bool _boundDocument = false;

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

    final documentState = ref.watch(documentControllerProvider);
    final document = ref.watch(documentByIdProvider(widget.documentId));

    if (document != null && !_boundDocument) {
      _titleController.text = document.name;
      _markdownController.text = document.markdown;
      _boundDocument = true;
    }

    return AppPageScaffold(
      title: _editMode ? '编辑文档' : '文档详情',
      actions: [
        IconButton(
          onPressed: () {
            setState(() {
              _editMode = !_editMode;
            });
          },
          tooltip: _editMode ? '切换查看' : '进入编辑',
          icon: Icon(_editMode ? Icons.remove_red_eye_outlined : Icons.edit),
        ),
      ],
      body: document == null
          ? _DetailPlaceholder(
              loading: documentState.detailLoading,
              onRetry: () => ref
                  .read(documentControllerProvider.notifier)
                  .loadDetail(widget.documentId),
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
                const SizedBox(height: 12),
                if (_editMode)
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
