import 'package:lexcore/shared/models/legal_models.dart';

class HomeEntity {
  const HomeEntity({required this.actions, required this.activities});

  final List<QuickAction> actions;
  final List<ActivityRecord> activities;
}
