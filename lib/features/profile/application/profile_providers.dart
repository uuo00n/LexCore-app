import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lexcore/core/network/dio_provider.dart';
import 'package:lexcore/features/profile/application/profile_personal_info_controller.dart';
import 'package:lexcore/features/profile/data/repositories/profile_personal_info_repository.dart';
import 'package:lexcore/features/profile/data/repositories/profile_repository.dart';
import 'package:lexcore/features/profile/domain/entities/profile_summary.dart';
import 'package:lexcore/shared/models/legal_models.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.watch(apiClientProvider));
});

final profileSummaryProvider = FutureProvider<ProfileSummary>((ref) async {
  return ref.watch(profileRepositoryProvider).summary();
});

final profileSubscriptionSnapshotProvider =
    FutureProvider<ProfileSubscriptionSnapshot>((ref) async {
      return ref.watch(profileRepositoryProvider).subscriptionSnapshot();
    });

final profileMenusProvider = Provider<List<ProfileMenuItem>>((ref) {
  return ref.watch(profileRepositoryProvider).menus();
});

final profilePersonalInfoControllerProvider =
    StateNotifierProvider<
      ProfilePersonalInfoController,
      ProfilePersonalInfoState
    >((ref) {
      return ProfilePersonalInfoController(
        repository: ref.watch(profilePersonalInfoRepositoryProvider),
      );
    });
