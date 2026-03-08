import 'package:lexcore/features/consultation/domain/entities/consultation_thread.dart';
import 'package:lexcore/shared/services/mock/mock_legal_repository.dart';

class ConsultationRepository {
  const ConsultationRepository(this._mock);

  final MockLegalRepository _mock;

  ConsultationThread loadThread() {
    return ConsultationThread(messages: _mock.consultationMessages());
  }
}
