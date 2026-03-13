import 'package:lexcore/features/settings/domain/entities/settings_profile.dart';
import 'package:lexcore/shared/models/legal_models.dart';
import 'package:lexcore/shared/services/mock/mock_legal_repository.dart';

class SettingsRepository {
  const SettingsRepository(this._mock);

  final MockLegalRepository _mock;

  List<SettingItem> items() => _mock.settings();

  SettingsProfile profile() {
    return const SettingsProfile(name: 'LexCore 用户', membership: 'PRO 会员');
  }

  String version() => 'LexCore 版本 2.4.0 (2024)';
}
