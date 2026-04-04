import 'package:lexcore/core/constants/app_constants.dart';
import 'package:lexcore/shared/config/static_ui_config.dart';
import 'package:lexcore/shared/models/legal_models.dart';

class SettingsRepository {
  const SettingsRepository();

  List<SettingItem> items() => StaticUiConfig.settingsItems;

  String version() =>
      'LexCore 版本 ${AppConstants.appVersion} (${AppConstants.copyrightYear})';
}
