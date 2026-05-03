import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lexcore/features/search/application/voice_search_controller.dart';

/// 弹出语音搜索 BottomSheet。
///
/// 返回识别完成后的文本；用户取消或异常返回 null。
Future<String?> showVoiceSearchSheet(BuildContext context) {
  return showModalBottomSheet<String?>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      return const _VoiceSearchSheet();
    },
  );
}

class _VoiceSearchSheet extends ConsumerStatefulWidget {
  const _VoiceSearchSheet();

  @override
  ConsumerState<_VoiceSearchSheet> createState() => _VoiceSearchSheetState();
}

class _VoiceSearchSheetState extends ConsumerState<_VoiceSearchSheet> {
  bool _autoStartTriggered = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _autoStartTriggered) {
        return;
      }
      _autoStartTriggered = true;
      ref.read(voiceSearchControllerProvider.notifier).start();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(voiceSearchControllerProvider);
    final controller = ref.read(voiceSearchControllerProvider.notifier);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SheetHandle(color: colorScheme.outlineVariant),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '语音搜索',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: '关闭',
                    onPressed: () => _handleCancel(context, controller),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '说出您想检索的法律关键词，识别完成后将自动写入搜索框。',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: _MicVisual(state: state, colorScheme: colorScheme),
              ),
              const SizedBox(height: 18),
              _StatusBlock(state: state),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      key: const ValueKey<String>('voice_search_cancel_button'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => _handleCancel(context, controller),
                      child: const Text('取消'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PrimaryAction(state: state, controller: controller),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleCancel(
    BuildContext context,
    VoiceSearchController controller,
  ) async {
    await controller.cancel();
    if (!context.mounted) {
      return;
    }
    Navigator.of(context).pop();
  }
}

class _PrimaryAction extends StatelessWidget {
  const _PrimaryAction({required this.state, required this.controller});

  final VoiceSearchState state;
  final VoiceSearchController controller;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    );
    final size = const Size.fromHeight(48);

    if (state.status == VoiceSearchStatus.error) {
      if (state.permissionPermanentlyDenied) {
        return FilledButton.icon(
          key: const ValueKey<String>('voice_search_open_settings_button'),
          style: FilledButton.styleFrom(minimumSize: size, shape: shape),
          onPressed: () => controller.openSystemSettings(),
          icon: const Icon(Icons.settings_outlined),
          label: const Text('去设置'),
        );
      }
      return FilledButton.icon(
        key: const ValueKey<String>('voice_search_retry_button'),
        style: FilledButton.styleFrom(minimumSize: size, shape: shape),
        onPressed: state.status == VoiceSearchStatus.error
            ? () => controller.start()
            : null,
        icon: const Icon(Icons.refresh_rounded),
        label: const Text('重试'),
      );
    }

    if (state.status == VoiceSearchStatus.unsupported) {
      return FilledButton(
        style: FilledButton.styleFrom(minimumSize: size, shape: shape),
        onPressed: null,
        child: const Text('暂不可用'),
      );
    }

    final canFinish = state.hasAnyText;
    final inProgress =
        state.status == VoiceSearchStatus.listening ||
        state.status == VoiceSearchStatus.processing;

    return FilledButton.icon(
      key: const ValueKey<String>('voice_search_finish_button'),
      style: FilledButton.styleFrom(
        minimumSize: size,
        shape: shape,
        backgroundColor: canFinish
            ? colorScheme.primary
            : colorScheme.surfaceContainerHigh,
        foregroundColor: canFinish
            ? colorScheme.onPrimary
            : colorScheme.onSurfaceVariant,
      ),
      onPressed: canFinish ? () => _finish(context, controller, state) : null,
      icon: inProgress
          ? const Icon(Icons.stop_rounded)
          : const Icon(Icons.check_rounded),
      label: Text(inProgress ? '完成' : '使用此结果'),
    );
  }

  Future<void> _finish(
    BuildContext context,
    VoiceSearchController controller,
    VoiceSearchState state,
  ) async {
    // 先保存一份用户已经看到的文本，再尝试 stop 让平台收尾。
    // 即使 stop 后 finalResult 改写了状态，对用户而言这就是他点击瞬间的内容，
    // 体验上反而更稳定。
    final snapshot = state.effectiveText;
    if (state.status == VoiceSearchStatus.listening ||
        state.status == VoiceSearchStatus.processing) {
      await controller.stop();
    }
    if (!context.mounted || snapshot.isEmpty) {
      return;
    }
    Navigator.of(context).pop(snapshot);
  }
}

class _StatusBlock extends StatelessWidget {
  const _StatusBlock({required this.state});

  final VoiceSearchState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final hint = _hintText(state);
    final transcript = state.partialText.isNotEmpty
        ? state.partialText
        : state.finalText;
    final hasError = state.status == VoiceSearchStatus.error;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 96),
      child: Column(
        children: [
          Text(
            hint,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: hasError
                  ? colorScheme.error
                  : colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
          if (transcript.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              key: const ValueKey<String>('voice_search_transcript'),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Text(
                transcript,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _hintText(VoiceSearchState state) {
    switch (state.status) {
      case VoiceSearchStatus.idle:
        return '准备就绪，点击下方按钮开始';
      case VoiceSearchStatus.initializing:
        return '正在准备麦克风...';
      case VoiceSearchStatus.listening:
        return state.partialText.trim().isEmpty
            ? '正在聆听，请说话...'
            : '继续说，或点击「完成」结束';
      case VoiceSearchStatus.processing:
        return '正在识别...';
      case VoiceSearchStatus.done:
        return '识别完成，确认后写入搜索框';
      case VoiceSearchStatus.error:
        return state.errorMessage ?? '语音识别失败';
      case VoiceSearchStatus.unsupported:
        return state.errorMessage ?? '当前设备不支持语音识别';
    }
  }
}

class _MicVisual extends StatelessWidget {
  const _MicVisual({required this.state, required this.colorScheme});

  final VoiceSearchState state;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final isActive = state.status == VoiceSearchStatus.listening;
    // sound level 在 iOS 是 -2..10 dB；Android 因机型差异更宽。
    // 这里粗暴 clamp 后归一化为 0..1，仅用于视觉反馈。
    final normalized = ((state.soundLevel.clamp(-2, 10) + 2) / 12).toDouble();
    final pulseScale = isActive ? 1 + (normalized * 0.45) : 1.0;
    final ringAlpha = isActive
        ? (0.18 + 0.4 * normalized).clamp(0.18, 0.6)
        : 0.18;

    final baseColor = state.status == VoiceSearchStatus.error
        ? colorScheme.error
        : colorScheme.primary;
    final onBase = state.status == VoiceSearchStatus.error
        ? colorScheme.onError
        : colorScheme.onPrimary;

    return SizedBox(
      width: 140,
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOutCubic,
            width: 96 * pulseScale,
            height: 96 * pulseScale,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: baseColor.withValues(alpha: ringAlpha.toDouble()),
            ),
          ),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(shape: BoxShape.circle, color: baseColor),
            alignment: Alignment.center,
            child: Icon(
              state.status == VoiceSearchStatus.error
                  ? Icons.mic_off_rounded
                  : Icons.mic_rounded,
              color: onBase,
              size: 40,
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 42,
        height: 4,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}
