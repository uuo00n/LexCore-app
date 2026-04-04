import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lexcore/core/network/dio_provider.dart';
import 'package:lexcore/features/history/data/repositories/history_repository.dart';
import 'package:lexcore/features/home/data/repositories/home_repository.dart';
import 'package:lexcore/features/home/domain/entities/home_entity.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepository(
    ref.watch(apiClientProvider),
    ref.watch(historyRepositoryProvider),
  );
});

final homeDataProvider = FutureProvider<HomeEntity>((ref) async {
  return ref.watch(homeRepositoryProvider).fetchHomeData();
});
