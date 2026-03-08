import 'package:lexcore/features/home/domain/entities/home_entity.dart';
import 'package:lexcore/shared/services/mock/mock_legal_repository.dart';

class HomeRepository {
  const HomeRepository(this._mock);

  final MockLegalRepository _mock;

  HomeEntity fetchHomeData() {
    return HomeEntity(
      actions: _mock.quickActions(),
      activities: _mock.recentActivities(),
    );
  }
}
