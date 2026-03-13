import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lexcore/features/profile/application/profile_personal_info_controller.dart';
import 'package:lexcore/features/profile/data/repositories/profile_personal_info_repository.dart';
import 'package:lexcore/features/profile/data/repositories/profile_repository.dart';
import 'package:lexcore/features/profile/domain/entities/profile_summary.dart';
import 'package:lexcore/shared/models/legal_models.dart';
import 'package:lexcore/shared/services/mock/mock_providers.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.watch(mockLegalRepositoryProvider));
});

final profileSummaryProvider = Provider<ProfileSummary>((ref) {
  return ref.watch(profileRepositoryProvider).summary();
});

final profileMenusProvider = Provider<List<ProfileMenuItem>>((ref) {
  return ref.watch(profileRepositoryProvider).menus();
});

final profilePersonalInfoRepositoryProvider =
    Provider<ProfilePersonalInfoRepository>((ref) {
      return const ProfilePersonalInfoRepository();
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
