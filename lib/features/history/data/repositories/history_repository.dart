import 'package:lexcore/shared/models/legal_models.dart';
import 'package:lexcore/shared/services/mock/mock_legal_repository.dart';

class HistoryRepository {
  const HistoryRepository(this._mock);

  final MockLegalRepository _mock;

  List<HistoryItem> loadAll() => _mock.historyItems();
}
