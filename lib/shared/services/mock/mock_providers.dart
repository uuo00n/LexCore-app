import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'mock_legal_repository.dart';

final mockLegalRepositoryProvider = Provider<MockLegalRepository>((ref) {
  return const MockLegalRepository();
});
