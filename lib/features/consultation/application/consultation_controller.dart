import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lexcore/core/error/app_exception.dart';
import 'package:lexcore/features/consultation/data/repositories/consultation_repository.dart';
import 'package:lexcore/features/consultation/domain/entities/consultation_thread.dart';
import 'package:lexcore/features/history/data/repositories/history_repository.dart';
import 'package:lexcore/shared/models/legal_models.dart';

const _serviceUnavailableNotice = '智能咨询服务暂时不可用，请稍后重试。';
const _serviceFailedNotice = '咨询请求失败，请稍后重试。';

class ConsultationState {
  const ConsultationState({
    required this.sessions,
    required this.threads,
    required this.remoteConversationIds,
    required this.pendingAssistantThreadIds,
  });

  final List<ConsultationSession> sessions;
  final Map<String, ConsultationThread> threads;
  final Map<String, String> remoteConversationIds;
  final Set<String> pendingAssistantThreadIds;

  ConsultationState copyWith({
    List<ConsultationSession>? sessions,
    Map<String, ConsultationThread>? threads,
    Map<String, String>? remoteConversationIds,
    Set<String>? pendingAssistantThreadIds,
  }) {
    return ConsultationState(
      sessions: sessions ?? this.sessions,
      threads: threads ?? this.threads,
      remoteConversationIds:
          remoteConversationIds ?? this.remoteConversationIds,
      pendingAssistantThreadIds:
          pendingAssistantThreadIds ?? this.pendingAssistantThreadIds,
    );
  }
}

class ConsultationStateController extends StateNotifier<ConsultationState> {
  ConsultationStateController(this._repository, [this._historyRepository])
    : super(_buildInitialState(_repository));

  final ConsultationRepository _repository;
  final HistoryRepository? _historyRepository;
  Future<void> _persistQueue = Future<void>.value();

  static ConsultationState _buildInitialState(
    ConsultationRepository repository,
  ) {
    final localState = repository.loadLocalState();
    return ConsultationState(
      sessions: localState?.sessions ?? repository.loadSessions(),
      threads: localState?.threads ?? const {},
      remoteConversationIds: localState?.remoteConversationIds ?? const {},
      pendingAssistantThreadIds: const <String>{},
    );
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

    final resolvedTitle = trimmedTitle.isNotEmpty ? trimmedTitle : '新建咨询会话';
    final newThread = ConsultationThread(
      id: threadId,
      title: resolvedTitle,
      messages: const <ChatMessage>[],
    );
    _upsertThread(newThread, icon: 'smart_toy', markActive: true);
    return newThread;
  }

  void createThread({required String threadId, required String title}) {
    ensureThread(threadId, title: title);
    unawaited(_bindRemoteConversation(threadId, title: title));
  }

  void selectThread(String threadId) {
    final hasSession = state.sessions.any((session) => session.id == threadId);
    if (!hasSession) return;
    _commitState(
      state.copyWith(
        sessions: state.sessions
            .map(
              (session) => session.copyWith(isActive: session.id == threadId),
            )
            .toList(),
      ),
    );
  }

  Future<void> send(String threadId, String content) async {
    final normalized = content.trim();
    if (normalized.isEmpty || _isThreadPending(threadId)) return;

    final thread = ensureThread(threadId);
    final localUserMessageId = _newLocalMessageId(role: ChatRole.user);
    final userMessage = ChatMessage(
      id: localUserMessageId,
      role: ChatRole.user,
      content: normalized,
    );
    _upsertThread(
      thread.copyWith(messages: [...thread.messages, userMessage]),
      markActive: true,
    );
    await _recordConsultationHistory(threadId: threadId, content: normalized);
    _setThreadPending(threadId, pending: true);

    try {
      final remoteConversationId = await _resolveRemoteConversationId(
        threadId,
        fallbackTitle: thread.title,
      );
      if (remoteConversationId == null) {
        _appendAssistantMessage(
          threadId,
          ChatMessage(
            id: _newLocalMessageId(role: ChatRole.assistant),
            role: ChatRole.assistant,
            content: _serviceUnavailableNotice,
          ),
        );
        return;
      }

      final assistantMessage = await _repository.sendMessage(
        conversationId: remoteConversationId,
        content: normalized,
      );
      if (assistantMessage == null) {
        _appendAssistantMessage(
          threadId,
          ChatMessage(
            id: _newLocalMessageId(role: ChatRole.assistant),
            role: ChatRole.assistant,
            content: _serviceFailedNotice,
          ),
        );
        return;
      }

      _replaceLocalUserMessage(
        threadId,
        localMessageId: localUserMessageId,
        remoteMessage: assistantMessage.userMessage,
      );
      _appendAssistantMessage(threadId, assistantMessage.assistantMessage);
    } on AppException catch (error) {
      final lowered = error.message.toLowerCase();
      if (lowered.contains('upstream unavailable') ||
          lowered.contains('503') ||
          lowered.contains('yuanqi')) {
        _appendAssistantMessage(
          threadId,
          ChatMessage(
            id: _newLocalMessageId(role: ChatRole.assistant),
            role: ChatRole.assistant,
            content: _serviceUnavailableNotice,
          ),
        );
        return;
      }

      _appendAssistantMessage(
        threadId,
        ChatMessage(
          id: _newLocalMessageId(role: ChatRole.assistant),
          role: ChatRole.assistant,
          content: _serviceFailedNotice,
        ),
      );
    } catch (_) {
      _appendAssistantMessage(
        threadId,
        ChatMessage(
          id: _newLocalMessageId(role: ChatRole.assistant),
          role: ChatRole.assistant,
          content: _serviceFailedNotice,
        ),
      );
    } finally {
      _setThreadPending(threadId, pending: false);
    }
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
      thread.copyWith(messages: const <ChatMessage>[]),
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

    final remoteIds = <String, String>{...state.remoteConversationIds}
      ..remove(threadId);
    final pendingThreads = {...state.pendingAssistantThreadIds}
      ..remove(threadId);

    _commitState(
      state.copyWith(
        threads: threads,
        sessions: sessions,
        remoteConversationIds: remoteIds,
        pendingAssistantThreadIds: pendingThreads,
      ),
    );
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

  Future<void> _bindRemoteConversation(
    String threadId, {
    required String title,
  }) async {
    if (state.remoteConversationIds.containsKey(threadId)) {
      return;
    }
    final remoteId = await _repository.createConversation(title: title);
    if (remoteId == null || remoteId.trim().isEmpty) {
      return;
    }
    _setRemoteConversationId(threadId, remoteId);
  }

  Future<void> _syncRemoteMessages(String threadId) async {
    final remoteId = state.remoteConversationIds[threadId];
    if (remoteId == null || remoteId.trim().isEmpty) {
      return;
    }
    final remoteMessages = await _repository.listMessages(remoteId);
    if (remoteMessages == null || remoteMessages.isEmpty) {
      return;
    }
    final thread = state.threads[threadId];
    if (thread == null) {
      return;
    }
    final merged = _mergeRemoteAndLocalMessages(
      remoteMessages: remoteMessages,
      localMessages: thread.messages,
    );
    _upsertThread(thread.copyWith(messages: merged), markActive: false);
  }

  Future<String?> _resolveRemoteConversationId(
    String threadId, {
    required String fallbackTitle,
  }) async {
    final existing = state.remoteConversationIds[threadId];
    if (existing != null && existing.trim().isNotEmpty) {
      return existing;
    }

    final created = await _repository.createConversation(title: fallbackTitle);
    if (created == null || created.trim().isEmpty) {
      return null;
    }
    _setRemoteConversationId(threadId, created);
    return created;
  }

  void _setRemoteConversationId(String threadId, String remoteId) {
    _commitState(
      state.copyWith(
        remoteConversationIds: {
          ...state.remoteConversationIds,
          threadId: remoteId,
        },
      ),
    );
  }

  void _appendAssistantMessage(String threadId, ChatMessage message) {
    final thread = state.threads[threadId] ?? ensureThread(threadId);
    if (thread.messages.any((item) => item.id == message.id)) {
      return;
    }
    final updated = thread.copyWith(messages: [...thread.messages, message]);
    _upsertThread(updated, markActive: true);
  }

  void _replaceLocalUserMessage(
    String threadId, {
    required String localMessageId,
    required ChatMessage remoteMessage,
  }) {
    final thread = state.threads[threadId] ?? ensureThread(threadId);
    final messages = [...thread.messages];
    final index = messages.indexWhere((item) => item.id == localMessageId);
    if (index >= 0) {
      messages[index] = remoteMessage;
    } else if (!messages.any((item) => item.id == remoteMessage.id)) {
      messages.add(remoteMessage);
    }
    _upsertThread(thread.copyWith(messages: messages), markActive: true);
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

    _commitState(state.copyWith(threads: nextThreads, sessions: sessions));
  }

  String _previewFromMessages(List<ChatMessage> messages) {
    for (var i = messages.length - 1; i >= 0; i--) {
      final message = messages[i];
      if (message.role != ChatRole.assistant) {
        continue;
      }
      final text = _compactPreviewText(message.content);
      if (text.isNotEmpty) {
        return text;
      }
    }
    for (var i = messages.length - 1; i >= 0; i--) {
      final text = _compactPreviewText(messages[i].content);
      if (text.isNotEmpty) return text;
    }
    return '开始新的法律咨询对话';
  }

  String _compactPreviewText(String content) {
    return content
        .replaceAll(RegExp(r'[\r\n]+'), '')
        .replaceAll(RegExp(r'[ \t\f\v]+'), ' ')
        .trim();
  }

  bool _isThreadPending(String threadId) {
    return state.pendingAssistantThreadIds.contains(threadId);
  }

  void _setThreadPending(String threadId, {required bool pending}) {
    final next = {...state.pendingAssistantThreadIds};
    final changed = pending ? next.add(threadId) : next.remove(threadId);
    if (!changed) return;
    _commitState(
      state.copyWith(pendingAssistantThreadIds: next),
      persistLocalState: false,
    );
  }

  void _commitState(
    ConsultationState nextState, {
    bool persistLocalState = true,
  }) {
    state = nextState;
    if (!persistLocalState) {
      return;
    }
    _enqueuePersistLocalState();
  }

  void _enqueuePersistLocalState() {
    final snapshot = ConsultationLocalState(
      sessions: state.sessions,
      threads: state.threads,
      remoteConversationIds: state.remoteConversationIds,
    );
    _persistQueue = _persistQueue
        .then((_) => _repository.persistLocalState(snapshot))
        .catchError((_) {
          // Keep chat flow resilient when local persistence is unavailable.
        });
  }

  String _newLocalMessageId({required ChatRole role}) {
    final prefix = role == ChatRole.user ? 'u' : 'a';
    return '${prefix}_local_${DateTime.now().microsecondsSinceEpoch}';
  }

  List<ChatMessage> _mergeRemoteAndLocalMessages({
    required List<ChatMessage> remoteMessages,
    required List<ChatMessage> localMessages,
  }) {
    final merged = [...remoteMessages];
    final existingIds = remoteMessages.map((message) => message.id).toSet();
    for (final message in localMessages) {
      if (!ConsultationRepository.isLocalOnlyMessageId(message.id)) {
        continue;
      }
      if (existingIds.add(message.id)) {
        merged.add(message);
      }
    }
    return merged;
  }

  Future<void> syncRemoteMessages(String threadId) async {
    await _syncRemoteMessages(threadId);
  }

  Future<void> _recordConsultationHistory({
    required String threadId,
    required String content,
  }) async {
    final historyRepository = _historyRepository;
    if (historyRepository == null) {
      return;
    }
    try {
      await historyRepository.recordConsultationQuery(
        question: content,
        threadId: threadId,
      );
    } catch (_) {
      // Keep chat flow resilient when history persistence is unavailable.
    }
  }
}

final consultationStateControllerProvider =
    StateNotifierProvider<ConsultationStateController, ConsultationState>((
      ref,
    ) {
      return ConsultationStateController(
        ref.watch(consultationRepositoryProvider),
        ref.watch(historyRepositoryProvider),
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
      ConsultationThread(id: threadId, title: '新建咨询会话', messages: const []);
});

final consultationMessagesProvider = Provider.family<List<ChatMessage>, String>(
  (ref, threadId) {
    return ref.watch(consultationThreadProvider(threadId)).messages;
  },
);

final consultationIsAiThinkingProvider = Provider.family<bool, String>((
  ref,
  threadId,
) {
  return ref
      .watch(consultationStateControllerProvider)
      .pendingAssistantThreadIds
      .contains(threadId);
});
