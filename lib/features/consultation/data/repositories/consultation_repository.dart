import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lexcore/core/error/app_exception.dart';
import 'package:lexcore/core/network/api_client.dart';
import 'package:lexcore/core/network/dio_provider.dart';
import 'package:lexcore/core/storage/local_storage.dart';
import 'package:lexcore/features/consultation/domain/entities/consultation_thread.dart';
import 'package:lexcore/shared/models/legal_models.dart';

class ConsultationRepository {
  const ConsultationRepository(this._apiClient, [this._preferences]);

  final ApiClient? _apiClient;
  final SharedPreferences? _preferences;
  static const _agentTimeout = Duration(minutes: 4);
  static final _agentRequestOptions = Options(
    sendTimeout: _agentTimeout,
    receiveTimeout: _agentTimeout,
  );

  static const _localIdSuffix = '_local_';
  static const _localStateStorageKey = 'consultation_state_local_v1';

  ConsultationLocalState? loadLocalState() {
    final preferences = _preferences;
    if (preferences == null) {
      return null;
    }
    final raw = preferences.getString(_localStateStorageKey);
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return null;
      }
      return ConsultationLocalState.fromJson(decoded.cast<String, dynamic>());
    } catch (_) {
      return null;
    }
  }

  Future<void> persistLocalState(ConsultationLocalState state) async {
    final preferences = _preferences;
    if (preferences == null) {
      return;
    }
    try {
      await preferences.setString(_localStateStorageKey, jsonEncode(state));
    } catch (_) {
      // Keep chat flow resilient when local persistence is unavailable.
    }
  }

  List<ConsultationSession> loadSessions() {
    return loadLocalState()?.sessions ?? const [];
  }

  Future<String?> createConversation({String? title}) async {
    final apiClient = _apiClient;
    if (apiClient == null) {
      return null;
    }
    try {
      final result = await apiClient.post<Map<String, dynamic>>(
        '/agent/conversations',
        data: {
          if (title != null && title.trim().isNotEmpty) 'title': title.trim(),
        },
        options: _agentRequestOptions,
        decoder: (data) => (data as Map?)?.cast<String, dynamic>() ?? const {},
      );
      return result['conversation_id'] as String?;
    } on AppException {
      return null;
    }
  }

  Future<List<ChatMessage>?> listMessages(String conversationId) async {
    final apiClient = _apiClient;
    if (apiClient == null) {
      return null;
    }
    try {
      final result = await apiClient.get<Map<String, dynamic>>(
        '/agent/conversations/$conversationId/messages',
        queryParameters: const {'offset': 0, 'limit': 100},
        options: _agentRequestOptions,
        decoder: (data) => (data as Map?)?.cast<String, dynamic>() ?? const {},
      );
      final items = (result['items'] as List?) ?? const [];
      return items.whereType<Map>().map((item) {
        final map = item.cast<String, dynamic>();
        final roleRaw = map['role'] as String? ?? 'assistant';
        final role = roleRaw == 'user' ? ChatRole.user : ChatRole.assistant;
        final messageId =
            '${map['message_id'] ?? DateTime.now().millisecondsSinceEpoch}';
        return ChatMessage(
          id: _remoteMessageId(role, messageId),
          role: role,
          content: map['content'] as String? ?? '',
        );
      }).toList();
    } on AppException {
      return null;
    }
  }

  Future<ConsultationSendResult?> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    final apiClient = _apiClient;
    if (apiClient == null) {
      return null;
    }
    final result = await apiClient.post<Map<String, dynamic>>(
      '/agent/conversations/$conversationId/messages',
      data: {'content': content},
      options: _agentRequestOptions,
      decoder: (data) => (data as Map?)?.cast<String, dynamic>() ?? const {},
    );
    final user =
        (result['user_message'] as Map?)?.cast<String, dynamic>() ?? const {};
    final assistant =
        (result['assistant_message'] as Map?)?.cast<String, dynamic>() ??
        const {};
    final userContent = user['content'] as String? ?? content;
    final assistantContent = assistant['content'] as String? ?? '';
    final userMessageId =
        '${user['message_id'] ?? DateTime.now().millisecondsSinceEpoch}';
    final assistantMessageId =
        '${assistant['message_id'] ?? DateTime.now().millisecondsSinceEpoch}';
    if (assistantContent.trim().isEmpty) {
      return null;
    }
    final traceId = result['trace_id'] as String?;
    return ConsultationSendResult(
      userMessage: ChatMessage(
        id: _remoteMessageId(ChatRole.user, userMessageId),
        role: ChatRole.user,
        content: userContent,
      ),
      assistantMessage: ChatMessage(
        id: _remoteMessageId(ChatRole.assistant, assistantMessageId),
        role: ChatRole.assistant,
        content: assistantContent,
        references: [
          if (traceId != null && traceId.trim().isNotEmpty)
            'trace_id: $traceId',
        ],
      ),
      traceId: traceId,
    );
  }

  static bool isLocalOnlyMessageId(String id) {
    return id.contains(_localIdSuffix);
  }

  static String _remoteMessageId(ChatRole role, String rawMessageId) {
    final normalizedRaw = rawMessageId.trim().isEmpty
        ? DateTime.now().millisecondsSinceEpoch.toString()
        : rawMessageId.trim();
    return role == ChatRole.user ? 'u_$normalizedRaw' : 'a_$normalizedRaw';
  }
}

class ConsultationSendResult {
  const ConsultationSendResult({
    required this.userMessage,
    required this.assistantMessage,
    this.traceId,
  });

  final ChatMessage userMessage;
  final ChatMessage assistantMessage;
  final String? traceId;
}

class ConsultationLocalState {
  const ConsultationLocalState({
    required this.sessions,
    required this.threads,
    required this.remoteConversationIds,
  });

  final List<ConsultationSession> sessions;
  final Map<String, ConsultationThread> threads;
  final Map<String, String> remoteConversationIds;

  Map<String, Object?> toJson() {
    return {
      'schemaVersion': 1,
      'sessions': sessions
          .map(
            (session) => {
              'id': session.id,
              'title': session.title,
              'preview': session.preview,
              'updatedAt': session.updatedAt.toIso8601String(),
              'icon': session.icon,
              'isActive': session.isActive,
            },
          )
          .toList(growable: false),
      'threads': threads.map(
        (threadId, thread) => MapEntry(threadId, {
          'id': thread.id,
          'title': thread.title,
          'messages': thread.messages
              .map(
                (message) => {
                  'id': message.id,
                  'role': message.role.name,
                  'content': message.content,
                  'references': message.references,
                },
              )
              .toList(growable: false),
        }),
      ),
      'remoteConversationIds': remoteConversationIds,
    };
  }

  factory ConsultationLocalState.fromJson(Map<String, dynamic> json) {
    final threads = <String, ConsultationThread>{};
    final rawThreads = json['threads'];
    if (rawThreads is Map) {
      rawThreads.forEach((key, value) {
        if (key is! String || key.trim().isEmpty || value is! Map) {
          return;
        }
        final map = value.cast<String, dynamic>();
        final threadId = (map['id'] as String?)?.trim();
        final resolvedThreadId = (threadId == null || threadId.isEmpty)
            ? key.trim()
            : threadId;
        if (resolvedThreadId.isEmpty) {
          return;
        }
        final messageList = map['messages'];
        final messages = messageList is List
            ? messageList
                  .whereType<Map>()
                  .map((item) => item.cast<String, dynamic>())
                  .map((item) {
                    final roleName = item['role'] as String? ?? '';
                    return ChatMessage(
                      id: item['id'] as String? ?? '',
                      role: roleName == ChatRole.user.name
                          ? ChatRole.user
                          : ChatRole.assistant,
                      content: item['content'] as String? ?? '',
                      references: ((item['references'] as List?) ?? const [])
                          .whereType<String>()
                          .toList(growable: false),
                    );
                  })
                  .where((message) => message.id.trim().isNotEmpty)
                  .toList(growable: false)
            : const <ChatMessage>[];

        threads[resolvedThreadId] = ConsultationThread(
          id: resolvedThreadId,
          title: (map['title'] as String?)?.trim().isNotEmpty == true
              ? (map['title'] as String).trim()
              : '新建咨询会话',
          messages: messages,
        );
      });
    }

    final sessions = <ConsultationSession>[];
    final seenSessionIds = <String>{};
    final rawSessions = json['sessions'];
    if (rawSessions is List) {
      for (final entry in rawSessions.whereType<Map>()) {
        final item = entry.cast<String, dynamic>();
        final id = (item['id'] as String? ?? '').trim();
        if (id.isEmpty || !seenSessionIds.add(id)) {
          continue;
        }
        final titleRaw = (item['title'] as String? ?? '').trim();
        final title = titleRaw.isEmpty ? '新建咨询会话' : titleRaw;
        sessions.add(
          ConsultationSession(
            id: id,
            title: title,
            preview: item['preview'] as String? ?? '',
            updatedAt:
                DateTime.tryParse(item['updatedAt'] as String? ?? '') ??
                DateTime.fromMillisecondsSinceEpoch(0),
            icon: item['icon'] as String? ?? 'smart_toy',
            isActive: item['isActive'] as bool? ?? false,
          ),
        );
        threads.putIfAbsent(
          id,
          () => ConsultationThread(id: id, title: title, messages: const []),
        );
      }
    }

    final remoteConversationIds = <String, String>{};
    final rawRemoteIds = json['remoteConversationIds'];
    if (rawRemoteIds is Map) {
      rawRemoteIds.forEach((key, value) {
        if (key is! String || value is! String) {
          return;
        }
        final threadId = key.trim();
        final remoteId = value.trim();
        if (threadId.isEmpty || remoteId.isEmpty) {
          return;
        }
        remoteConversationIds[threadId] = remoteId;
      });
    }

    return ConsultationLocalState(
      sessions: sessions,
      threads: threads,
      remoteConversationIds: remoteConversationIds,
    );
  }
}

final consultationRepositoryProvider = Provider<ConsultationRepository>((ref) {
  ApiClient? apiClient;
  try {
    apiClient = ref.watch(apiClientProvider);
  } catch (_) {
    apiClient = null;
  }
  SharedPreferences? preferences;
  try {
    preferences = ref.watch(sharedPreferencesProvider);
  } catch (_) {
    preferences = null;
  }
  return ConsultationRepository(apiClient, preferences);
});
