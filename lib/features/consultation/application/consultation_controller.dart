import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lexcore/features/consultation/data/repositories/consultation_repository.dart';
import 'package:lexcore/features/consultation/domain/entities/consultation_thread.dart';
import 'package:lexcore/shared/models/legal_models.dart';
import 'package:lexcore/shared/services/mock/mock_providers.dart';

const ChatMessage _defaultWelcomeMessage = ChatMessage(
  id: 'new_thread_welcome',
  role: ChatRole.assistant,
  content: '您好，我是 LexCore 法律助手。请告诉我您的法律问题，我会给出分步骤建议。',
);

final consultationRepositoryProvider = Provider<ConsultationRepository>((ref) {
  return ConsultationRepository(ref.watch(mockLegalRepositoryProvider));
});

class ConsultationState {
  const ConsultationState({required this.sessions, required this.threads});

  final List<ConsultationSession> sessions;
  final Map<String, ConsultationThread> threads;

  ConsultationState copyWith({
    List<ConsultationSession>? sessions,
    Map<String, ConsultationThread>? threads,
  }) {
    return ConsultationState(
      sessions: sessions ?? this.sessions,
      threads: threads ?? this.threads,
    );
  }
}

class ConsultationStateController extends StateNotifier<ConsultationState> {
  ConsultationStateController(this._repository)
    : super(_buildInitialState(_repository));

  final ConsultationRepository _repository;

  static ConsultationState _buildInitialState(
    ConsultationRepository repository,
  ) {
    final sessions = repository.loadSessions();
    final threads = <String, ConsultationThread>{};
    for (final session in sessions) {
      threads[session.id] = repository.loadThreadById(session.id);
    }
    return ConsultationState(sessions: sessions, threads: threads);
  }

  ConsultationThread ensureThread(String threadId, {String? title}) {
    final existing = state.threads[threadId];
    final trimmedTitle = title?.trim() ?? '';
    if (existing != null) {
      if (trimmedTitle.isNotEmpty && existing.title != trimmedTitle) {
        renameThread(threadId, trimmedTitle);
        return state.threads[threadId]!;
      }
      return existing;
    }

    final seedThread = _repository.loadThreadById(threadId);
    final resolvedTitle = trimmedTitle.isNotEmpty
        ? trimmedTitle
        : seedThread.title;
    final messages = seedThread.messages.isEmpty
        ? const <ChatMessage>[_defaultWelcomeMessage]
        : seedThread.messages;
    final newThread = ConsultationThread(
      id: threadId,
      title: resolvedTitle,
      messages: messages,
    );
    _upsertThread(newThread, icon: 'smart_toy', markActive: true);
    return newThread;
  }

  void createThread({required String threadId, required String title}) {
    ensureThread(threadId, title: title);
  }

  void selectThread(String threadId) {
    final hasSession = state.sessions.any((session) => session.id == threadId);
    if (!hasSession) return;
    state = state.copyWith(
      sessions: state.sessions
          .map((session) => session.copyWith(isActive: session.id == threadId))
          .toList(),
    );
  }

  void send(String threadId, String content) {
    final normalized = content.trim();
    if (normalized.isEmpty) return;

    final thread = ensureThread(threadId);
    final userMessage = ChatMessage(
      id: 'u_${DateTime.now().millisecondsSinceEpoch}',
      role: ChatRole.user,
      content: normalized,
    );
    final aiMessage = ChatMessage(
      id: 'a_${DateTime.now().millisecondsSinceEpoch}',
      role: ChatRole.assistant,
      content: '已收到你的问题，我将基于法规要点给出分步骤建议。',
      references: const ['民法典 总则编', '劳动合同法 第三十条'],
    );
    final updatedThread = thread.copyWith(
      messages: [...thread.messages, userMessage, aiMessage],
    );
    _upsertThread(updatedThread, markActive: true);
  }

  void renameThread(String threadId, String title) {
    final normalized = title.trim();
    if (normalized.isEmpty) return;
    final thread = ensureThread(threadId);
    _upsertThread(thread.copyWith(title: normalized), markActive: true);
  }

  void clearThread(String threadId) {
    final thread = ensureThread(threadId);
    _upsertThread(
      thread.copyWith(messages: const <ChatMessage>[_defaultWelcomeMessage]),
      markActive: true,
    );
  }

  bool deleteThread(String threadId) {
    if (!state.threads.containsKey(threadId)) return false;

    final threads = <String, ConsultationThread>{...state.threads}
      ..remove(threadId);
    var sessions = state.sessions
        .where((session) => session.id != threadId)
        .toList(growable: false);

    if (sessions.isNotEmpty && !sessions.any((session) => session.isActive)) {
      final first = sessions.first.copyWith(isActive: true);
      sessions = [first, ...sessions.skip(1)];
    }

    state = state.copyWith(threads: threads, sessions: sessions);
    return true;
  }

  String buildShareText(String threadId) {
    final thread = state.threads[threadId] ?? ensureThread(threadId);
    final messages = thread.messages;
    final start = messages.length > 8 ? messages.length - 8 : 0;

    final lines = <String>[thread.title, '', '由 LexCore 导出', ''];

    for (var i = start; i < messages.length; i++) {
      final message = messages[i];
      final role = message.role == ChatRole.user ? '我' : 'LexCore';
      lines.add('[$role] ${message.content}');
      if (message.references.isNotEmpty) {
        lines.add('参考：${message.references.join('、')}');
      }
      lines.add('');
    }

    if (messages.isEmpty) {
      lines.add('（暂无对话内容）');
    }

    return lines.join('\n').trimRight();
  }

  void _upsertThread(
    ConsultationThread thread, {
    String? icon,
    required bool markActive,
  }) {
    final now = DateTime.now();
    final preview = _previewFromMessages(thread.messages);
    final nextThreads = <String, ConsultationThread>{
      ...state.threads,
      thread.id: thread,
    };

    final existingIndex = state.sessions.indexWhere(
      (session) => session.id == thread.id,
    );

    ConsultationSession updatedSession;
    final remaining = [...state.sessions];
    if (existingIndex >= 0) {
      final existing = remaining.removeAt(existingIndex);
      updatedSession = existing.copyWith(
        title: thread.title,
        preview: preview,
        updatedAt: now,
        isActive: markActive ? true : existing.isActive,
      );
    } else {
      updatedSession = ConsultationSession(
        id: thread.id,
        title: thread.title,
        preview: preview,
        updatedAt: now,
        icon: icon ?? 'smart_toy',
        isActive: markActive,
      );
    }

    var sessions = [updatedSession, ...remaining];
    if (markActive) {
      sessions = sessions
          .map((session) => session.copyWith(isActive: session.id == thread.id))
          .toList(growable: false);
    }

    state = state.copyWith(threads: nextThreads, sessions: sessions);
  }

  String _previewFromMessages(List<ChatMessage> messages) {
    for (var i = messages.length - 1; i >= 0; i--) {
      final text = messages[i].content.trim();
      if (text.isNotEmpty) return text;
    }
    return '开始新的法律咨询对话';
  }
}

final consultationStateControllerProvider =
    StateNotifierProvider<ConsultationStateController, ConsultationState>((
      ref,
    ) {
      return ConsultationStateController(
        ref.watch(consultationRepositoryProvider),
      );
    });

final consultationSessionsProvider = Provider<List<ConsultationSession>>((ref) {
  return ref.watch(consultationStateControllerProvider).sessions;
});

final consultationThreadProvider = Provider.family<ConsultationThread, String>((
  ref,
  threadId,
) {
  return ref.watch(consultationStateControllerProvider).threads[threadId] ??
      ConsultationThread(
        id: threadId,
        title: '新建咨询会话',
        messages: const [_defaultWelcomeMessage],
      );
});

final consultationMessagesProvider = Provider.family<List<ChatMessage>, String>(
  (ref, threadId) {
    return ref.watch(consultationThreadProvider(threadId)).messages;
  },
);
