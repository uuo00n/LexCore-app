import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lexcore/features/consultation/application/consultation_controller.dart';
import 'package:lexcore/features/consultation/data/repositories/consultation_repository.dart';
import 'package:lexcore/features/consultation/domain/entities/consultation_thread.dart';
import 'package:lexcore/features/consultation/presentation/pages/consultation_page.dart';
import 'package:lexcore/shared/models/legal_models.dart';

class _SeededConsultationController extends ConsultationStateController {
  _SeededConsultationController({
    required ConsultationRepository repository,
    required String threadId,
    required List<ChatMessage> messages,
  }) : super(repository) {
    state = ConsultationState(
      sessions: [
        ConsultationSession(
          id: threadId,
          title: '演示会话',
          preview: messages.isEmpty ? '' : messages.last.content,
          updatedAt: DateTime(2026),
          isActive: true,
        ),
      ],
      threads: {
        threadId: ConsultationThread(
          id: threadId,
          title: '演示会话',
          messages: messages,
        ),
      },
      remoteConversationIds: const {'thread_ui': 'remote-thread-1'},
      pendingAssistantThreadIds: const <String>{},
    );
  }
}

class _PendingConsultationRepository extends ConsultationRepository {
  _PendingConsultationRepository() : super(null);

  final Completer<ConsultationSendResult?> sendCompleter =
      Completer<ConsultationSendResult?>();
  int sendCallCount = 0;

  @override
  Future<String?> createConversation({String? title}) async {
    return 'remote-thread-1';
  }

  @override
  Future<List<ChatMessage>?> listMessages(String conversationId) async {
    return const [];
  }

  @override
  Future<ConsultationSendResult?> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    sendCallCount += 1;
    return sendCompleter.future;
  }
}

List<ChatMessage> _buildLongConversation([int pairCount = 14]) {
  return List<ChatMessage>.generate(pairCount * 2, (index) {
    final isUser = index.isEven;
    final round = (index ~/ 2) + 1;
    return ChatMessage(
      id: '${isUser ? 'u' : 'a'}_$index',
      role: isUser ? ChatRole.user : ChatRole.assistant,
      content: isUser
          ? '第 $round 轮用户咨询内容，包含更多细节用于拉长列表。'
          : '第 $round 轮 AI 回复内容，继续补充更多说明以便制造滚动区域。',
    );
  });
}

Future<void> _setPhoneViewport(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
  addTearDown(() async {
    await tester.binding.setSurfaceSize(null);
  });
}

ScrollPosition _messageListPosition(WidgetTester tester) {
  final listView = tester.widget<ListView>(find.byType(ListView).first);
  return listView.controller!.position;
}

void main() {
  testWidgets('scrolls to the latest message when opening the page', (
    tester,
  ) async {
    await _setPhoneViewport(tester);
    final repository = _PendingConsultationRepository();
    final controller = _SeededConsultationController(
      repository: repository,
      threadId: 'thread_ui',
      messages: _buildLongConversation(),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          consultationRepositoryProvider.overrideWithValue(repository),
          consultationStateControllerProvider.overrideWith((ref) => controller),
        ],
        child: const MaterialApp(
          home: ConsultationPage(threadId: 'thread_ui', threadTitle: '演示会话'),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    final position = _messageListPosition(tester);
    expect(position.pixels, moreOrLessEquals(position.maxScrollExtent));
  });

  testWidgets(
    'auto scrolls to the latest ai state while waiting and after response',
    (tester) async {
      await _setPhoneViewport(tester);
      final repository = _PendingConsultationRepository();
      final controller = _SeededConsultationController(
        repository: repository,
        threadId: 'thread_ui',
        messages: _buildLongConversation(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            consultationRepositoryProvider.overrideWithValue(repository),
            consultationStateControllerProvider.overrideWith(
              (ref) => controller,
            ),
          ],
          child: const MaterialApp(
            home: ConsultationPage(threadId: 'thread_ui', threadTitle: '演示会话'),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));

      await tester.drag(find.byType(ListView).first, const Offset(0, 360));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(
        _messageListPosition(tester).pixels,
        lessThan(_messageListPosition(tester).maxScrollExtent),
      );

      await tester.enterText(find.byType(TextField), '请给我一个法律建议');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));

      expect(repository.sendCallCount, 1);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.tap(find.byType(FilledButton));
      await tester.pump();
      expect(repository.sendCallCount, 1);

      repository.sendCompleter.complete(
        const ConsultationSendResult(
          userMessage: ChatMessage(
            id: 'u_300',
            role: ChatRole.user,
            content: '请给我一个法律建议',
          ),
          assistantMessage: ChatMessage(
            id: 'a_400',
            role: ChatRole.assistant,
            content: '这里是 AI 的分析回复',
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));

      expect(
        find.byKey(const ValueKey('consultation_ai_thinking')),
        findsNothing,
      );
      expect(
        controller
            .state
            .threads['thread_ui']
            ?.messages
            .last
            .content,
        '这里是 AI 的分析回复',
      );
      expect(
        _messageListPosition(tester).pixels,
        moreOrLessEquals(_messageListPosition(tester).maxScrollExtent),
      );
    },
  );
}
