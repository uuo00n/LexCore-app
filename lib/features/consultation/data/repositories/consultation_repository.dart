import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lexcore/core/error/app_exception.dart';
import 'package:lexcore/core/network/api_client.dart';
import 'package:lexcore/core/network/dio_provider.dart';
import 'package:lexcore/shared/models/legal_models.dart';

class ConsultationRepository {
  const ConsultationRepository(this._apiClient);

  final ApiClient? _apiClient;
  static const _agentTimeout = Duration(minutes: 4);
  static final _agentRequestOptions = Options(
    sendTimeout: _agentTimeout,
    receiveTimeout: _agentTimeout,
  );

  static const _localIdSuffix = '_local_';

  List<ConsultationSession> loadSessions() {
    return const [];
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

final consultationRepositoryProvider = Provider<ConsultationRepository>((ref) {
  ApiClient? apiClient;
  try {
    apiClient = ref.watch(apiClientProvider);
  } catch (_) {
    apiClient = null;
  }
  return ConsultationRepository(apiClient);
});
