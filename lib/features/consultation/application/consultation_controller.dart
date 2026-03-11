import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lexcore/features/consultation/data/repositories/consultation_repository.dart';
import 'package:lexcore/shared/models/legal_models.dart';
import 'package:lexcore/shared/services/mock/mock_providers.dart';

final consultationRepositoryProvider = Provider<ConsultationRepository>((ref) {
  return ConsultationRepository(ref.watch(mockLegalRepositoryProvider));
});

class ConsultationController extends StateNotifier<List<ChatMessage>> {
  ConsultationController(ConsultationRepository repository)
    : super(repository.loadThread().messages);

  void send(String content) {
    if (content.trim().isEmpty) return;
    final userMessage = ChatMessage(
      id: 'u_${DateTime.now().millisecondsSinceEpoch}',
      role: ChatRole.user,
      content: content.trim(),
    );
    final aiMessage = ChatMessage(
      id: 'a_${DateTime.now().millisecondsSinceEpoch}',
      role: ChatRole.assistant,
      content: '已收到你的问题，我将基于法规要点给出分步骤建议。',
      references: const ['民法典 总则编', '劳动合同法 第三十条'],
    );
    state = [...state, userMessage, aiMessage];
  }
}

final consultationControllerProvider =
    StateNotifierProvider<ConsultationController, List<ChatMessage>>((ref) {
      return ConsultationController(ref.watch(consultationRepositoryProvider));
    });
