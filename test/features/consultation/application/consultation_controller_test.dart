import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lexcore/core/error/app_exception.dart';
import 'package:lexcore/core/network/api_client.dart';
import 'package:lexcore/features/consultation/application/consultation_controller.dart';
import 'package:lexcore/features/consultation/data/repositories/consultation_repository.dart';
import 'package:lexcore/features/history/data/repositories/history_repository.dart';
import 'package:lexcore/shared/models/legal_models.dart';

class _FakeConsultationRepository extends ConsultationRepository {
  _FakeConsultationRepository([SharedPreferences? preferences])
    : super(null, preferences);

  String? createConversationResult = 'remote-conversation-1';
  List<ChatMessage>? listedMessages;
  ConsultationSendResult? sendResult;
  AppException? sendAppException;
  Exception? sendException;
  Completer<ConsultationSendResult?>? sendCompleter;
  int sendCallCount = 0;
  String? lastSendConversationId;
  String? lastSendContent;

  @override
  Future<String?> createConversation({String? title}) async {
    return createConversationResult;
  }

  @override
  Future<List<ChatMessage>?> listMessages(String conversationId) async {
    return listedMessages;
  }

  @override
  Future<ConsultationSendResult?> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    sendCallCount += 1;
    lastSendConversationId = conversationId;
    lastSendContent = content;
    final completer = sendCompleter;
    if (completer != null) {
      return completer.future;
    }
    final appException = sendAppException;
    if (appException != null) {
      throw appException;
    }
    final genericException = sendException;
    if (genericException != null) {
      throw genericException;
    }
    return sendResult;
  }
}

class _HistoryApiClient extends ApiClient {
  _HistoryApiClient() : super(Dio());

  @override
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    required T Function(Object? data) decoder,
  }) async {
    if (path == '/history') {
      return decoder({'items': const []});
    }
    throw UnimplementedError('Unhandled GET path: $path');
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test(
    'send keeps pending state, blocks duplicate submit and appends response',
    () async {
      final repository = _FakeConsultationRepository();
      final sendCompleter = Completer<ConsultationSendResult?>();
      repository.sendCompleter = sendCompleter;
      final controller = ConsultationStateController(repository);
      addTearDown(controller.dispose);

      controller.ensureThread('thread_a', title: '测试会话');
      final sending = controller.send('thread_a', '第一条问题');

      await _waitUntil(() {
        final messages =
            controller.state.threads['thread_a']?.messages ?? const [];
        return controller.state.pendingAssistantThreadIds.contains(
              'thread_a',
            ) &&
            messages.length == 1;
      });

      final pendingMessages = controller.state.threads['thread_a']!.messages;
      expect(pendingMessages.single.role, ChatRole.user);
      expect(pendingMessages.single.id, contains('_local_'));

      await controller.send('thread_a', '第二条问题');
      expect(repository.sendCallCount, 1);

      sendCompleter.complete(
        const ConsultationSendResult(
          userMessage: ChatMessage(
            id: 'u_101',
            role: ChatRole.user,
            content: '第一条问题',
          ),
          assistantMessage: ChatMessage(
            id: 'a_201',
            role: ChatRole.assistant,
            content: '这是 AI 回复',
          ),
        ),
      );
      await sending;

      final finalMessages = controller.state.threads['thread_a']!.messages;
      expect(
        controller.state.pendingAssistantThreadIds.contains('thread_a'),
        isFalse,
      );
      expect(finalMessages.length, 2);
      expect(finalMessages[0].id, 'u_101');
      expect(finalMessages[0].content, '第一条问题');
      expect(finalMessages[1].id, 'a_201');
      expect(finalMessages[1].content, '这是 AI 回复');
      expect(controller.state.sessions.first.preview, '这是 AI 回复');
    },
  );

  test(
    'syncRemoteMessages merges remote history without dropping local optimistic bubble',
    () async {
      final repository = _FakeConsultationRepository();
      final sendCompleter = Completer<ConsultationSendResult?>();
      repository.sendCompleter = sendCompleter;
      repository.listedMessages = const [
        ChatMessage(
          id: 'a_remote_history',
          role: ChatRole.assistant,
          content: '远端历史消息',
        ),
      ];
      final controller = ConsultationStateController(repository);
      addTearDown(controller.dispose);

      controller.ensureThread('thread_b', title: '同步场景');
      final sending = controller.send('thread_b', '正在等待回复');

      await _waitUntil(() {
        final messages =
            controller.state.threads['thread_b']?.messages ?? const [];
        return controller.state.pendingAssistantThreadIds.contains(
              'thread_b',
            ) &&
            messages.any((item) => item.id.contains('_local_'));
      });

      await controller.syncRemoteMessages('thread_b');

      final mergedMessages = controller.state.threads['thread_b']!.messages;
      expect(
        mergedMessages.any((item) => item.id == 'a_remote_history'),
        isTrue,
      );
      expect(mergedMessages.any((item) => item.id.contains('_local_')), isTrue);

      sendCompleter.complete(
        const ConsultationSendResult(
          userMessage: ChatMessage(
            id: 'u_102',
            role: ChatRole.user,
            content: '正在等待回复',
          ),
          assistantMessage: ChatMessage(
            id: 'a_202',
            role: ChatRole.assistant,
            content: '最终回复',
          ),
        ),
      );
      await sending;
    },
  );

  test(
    'preview keeps latest assistant reply while next question is pending',
    () async {
      final repository = _FakeConsultationRepository()
        ..sendResult = const ConsultationSendResult(
          userMessage: ChatMessage(
            id: 'u_301',
            role: ChatRole.user,
            content: '第一个问题',
          ),
          assistantMessage: ChatMessage(
            id: 'a_401',
            role: ChatRole.assistant,
            content: '\n综合分析如下：\n第一，先核验合同。\n',
          ),
        );
      final controller = ConsultationStateController(repository);
      addTearDown(controller.dispose);

      controller.ensureThread('thread_preview', title: '预览场景');
      await controller.send('thread_preview', '第一个问题');

      expect(
        controller.state.sessions
            .firstWhere((session) => session.id == 'thread_preview')
            .preview,
        '综合分析如下：第一，先核验合同。',
      );

      final nextSendCompleter = Completer<ConsultationSendResult?>();
      repository
        ..sendResult = null
        ..sendCompleter = nextSendCompleter;
      final pendingSend = controller.send('thread_preview', '我再补充一个问题');

      await _waitUntil(() {
        return controller.state.pendingAssistantThreadIds.contains(
              'thread_preview',
            ) &&
            controller.state.threads['thread_preview']!.messages.last.role ==
                ChatRole.user;
      });

      expect(
        controller.state.sessions
            .firstWhere((session) => session.id == 'thread_preview')
            .preview,
        '综合分析如下：第一，先核验合同。',
      );

      nextSendCompleter.complete(
        const ConsultationSendResult(
          userMessage: ChatMessage(
            id: 'u_302',
            role: ChatRole.user,
            content: '我再补充一个问题',
          ),
          assistantMessage: ChatMessage(
            id: 'a_402',
            role: ChatRole.assistant,
            content: '新的答复',
          ),
        ),
      );
      await pendingSend;
    },
  );

  test(
    'send shows service unavailable notice on upstream unavailable error',
    () async {
      final repository = _FakeConsultationRepository()
        ..sendAppException = AppException(
          '503 upstream unavailable from yuanqi',
        );
      final controller = ConsultationStateController(repository);
      addTearDown(controller.dispose);

      controller.ensureThread('thread_c', title: '异常场景');
      await controller.send('thread_c', '测试异常');

      final messages = controller.state.threads['thread_c']!.messages;
      expect(
        controller.state.pendingAssistantThreadIds.contains('thread_c'),
        isFalse,
      );
      expect(messages.length, 2);
      expect(messages.last.role, ChatRole.assistant);
      expect(messages.last.content, '智能咨询服务暂时不可用，请稍后重试。');
    },
  );

  test(
    'send records consultation history even when remote reply fails',
    () async {
      final preferences = await SharedPreferences.getInstance();
      final historyRepository = HistoryRepository(
        _HistoryApiClient(),
        preferences,
      );
      final repository = _FakeConsultationRepository()..sendResult = null;
      final controller = ConsultationStateController(
        repository,
        historyRepository,
      );
      addTearDown(controller.dispose);

      controller.ensureThread('thread_history', title: '历史场景');
      await controller.send('thread_history', '房屋租赁纠纷怎么处理');

      final historyItems = await historyRepository.loadAll();

      expect(historyItems, hasLength(1));
      expect(historyItems.single.category, HistoryCategory.consultation);
      expect(historyItems.single.title, contains('房屋租赁纠纷怎么处理'));
    },
  );

  test(
    'controller restores persisted threads, messages and remote ids',
    () async {
      final preferences = await SharedPreferences.getInstance();
      final repository = _FakeConsultationRepository(preferences)
        ..createConversationResult = 'remote-conversation-restore'
        ..sendResult = const ConsultationSendResult(
          userMessage: ChatMessage(
            id: 'u_501',
            role: ChatRole.user,
            content: '恢复前的问题',
          ),
          assistantMessage: ChatMessage(
            id: 'a_601',
            role: ChatRole.assistant,
            content: '恢复前的回复',
          ),
        );

      final controller = ConsultationStateController(repository);
      addTearDown(controller.dispose);

      controller.ensureThread('thread_restore', title: '恢复测试');
      await controller.send('thread_restore', '恢复前的问题');

      await _waitUntilPersisted(repository, (snapshot) {
        final restoredThread = snapshot.threads['thread_restore'];
        return restoredThread != null &&
            restoredThread.messages.length == 2 &&
            snapshot.remoteConversationIds['thread_restore'] ==
                'remote-conversation-restore';
      });

      final restoredController = ConsultationStateController(repository);
      addTearDown(restoredController.dispose);

      final restoredThread = restoredController.state.threads['thread_restore'];
      expect(restoredThread, isNotNull);
      expect(restoredThread!.title, '恢复测试');
      expect(restoredThread.messages.map((message) => message.id), [
        'u_501',
        'a_601',
      ]);
      expect(
        restoredController.state.remoteConversationIds['thread_restore'],
        'remote-conversation-restore',
      );
      expect(restoredController.state.pendingAssistantThreadIds, isEmpty);
    },
  );

  test('controller persists rename clear and delete operations', () async {
    final preferences = await SharedPreferences.getInstance();
    final repository = _FakeConsultationRepository(preferences)
      ..createConversationResult = 'remote-conversation-edit'
      ..sendResult = const ConsultationSendResult(
        userMessage: ChatMessage(
          id: 'u_701',
          role: ChatRole.user,
          content: '需要清空的问题',
        ),
        assistantMessage: ChatMessage(
          id: 'a_801',
          role: ChatRole.assistant,
          content: '会被清空的回复',
        ),
      );

    final controller = ConsultationStateController(repository);
    addTearDown(controller.dispose);

    controller.ensureThread('thread_edit', title: '原始标题');
    await controller.send('thread_edit', '需要清空的问题');
    controller.renameThread('thread_edit', '重命名后的标题');
    controller.clearThread('thread_edit');

    controller.ensureThread('thread_remove', title: '待删除');
    controller.deleteThread('thread_remove');

    await _waitUntilPersisted(repository, (snapshot) {
      final editThread = snapshot.threads['thread_edit'];
      return editThread != null &&
          editThread.title == '重命名后的标题' &&
          editThread.messages.isEmpty &&
          !snapshot.threads.containsKey('thread_remove');
    });

    final restoredController = ConsultationStateController(repository);
    addTearDown(restoredController.dispose);

    final restoredThread = restoredController.state.threads['thread_edit'];
    expect(restoredThread, isNotNull);
    expect(restoredThread!.title, '重命名后的标题');
    expect(restoredThread.messages, isEmpty);
    expect(
      restoredController.state.threads.containsKey('thread_remove'),
      isFalse,
    );
    expect(
      restoredController.state.sessions.any(
        (session) => session.id == 'thread_remove',
      ),
      isFalse,
    );
  });
}

Future<void> _waitUntil(bool Function() predicate) async {
  for (var i = 0; i < 60; i++) {
    if (predicate()) return;
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  fail('condition not met in time');
}

Future<void> _waitUntilPersisted(
  ConsultationRepository repository,
  bool Function(ConsultationLocalState snapshot) predicate,
) async {
  await _waitUntil(() {
    final snapshot = repository.loadLocalState();
    return snapshot != null && predicate(snapshot);
  });
}
