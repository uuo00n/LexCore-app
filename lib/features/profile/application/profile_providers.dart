import 'package:flutter_riverpod/flutter_riverpod.dart';

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
