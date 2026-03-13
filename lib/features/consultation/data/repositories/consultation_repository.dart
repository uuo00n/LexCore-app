import 'package:lexcore/features/consultation/domain/entities/consultation_thread.dart';
import 'package:lexcore/shared/models/legal_models.dart';
import 'package:lexcore/shared/services/mock/mock_legal_repository.dart';

class ConsultationRepository {
  const ConsultationRepository(this._mock);

  final MockLegalRepository _mock;

  List<ConsultationSession> loadSessions() {
    return _mock.consultationSessions();
  }

  ConsultationThread loadThreadById(String threadId) {
    var threadTitle = '新建咨询会话';
    final sessions = _mock.consultationSessions();
    for (final session in sessions) {
      if (session.id == threadId) {
        threadTitle = session.title;
        break;
      }
    }
    return ConsultationThread(
      id: threadId,
      title: threadTitle,
      messages: _mock.consultationMessagesByThread(threadId),
    );
  }
}
