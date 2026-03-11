import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lexcore/features/home/data/repositories/home_repository.dart';
import 'package:lexcore/features/home/domain/entities/home_entity.dart';
import 'package:lexcore/shared/services/mock/mock_providers.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepository(ref.watch(mockLegalRepositoryProvider));
});

final homeDataProvider = Provider<HomeEntity>((ref) {
  return ref.watch(homeRepositoryProvider).fetchHomeData();
});
