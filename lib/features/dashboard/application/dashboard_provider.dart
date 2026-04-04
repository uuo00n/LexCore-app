import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lexcore/features/dashboard/data/repositories/dashboard_repository.dart';
import 'package:lexcore/features/dashboard/domain/entities/dashboard_entity.dart';

final dashboardProvider = Provider<DashboardEntity?>((ref) {
  return const DashboardRepository().load();
});
