import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lexcore/features/auth/data/repositories/auth_repository.dart';
import 'package:lexcore/features/auth/domain/entities/auth_mode.dart';

class AuthViewState {
  const AuthViewState({
    this.mode = AuthMode.login,
    this.agreeTerms = false,
    this.loading = false,
  });

  final AuthMode mode;
  final bool agreeTerms;
  final bool loading;

  AuthViewState copyWith({AuthMode? mode, bool? agreeTerms, bool? loading}) {
    return AuthViewState(
      mode: mode ?? this.mode,
      agreeTerms: agreeTerms ?? this.agreeTerms,
      loading: loading ?? this.loading,
    );
  }
}

class AuthController extends StateNotifier<AuthViewState> {
  AuthController(this._repository) : super(const AuthViewState());

  final AuthRepository _repository;

  void setMode(AuthMode mode) {
    state = state.copyWith(mode: mode);
  }

  void toggleAgreement(bool value) {
    state = state.copyWith(agreeTerms: value);
  }

  Future<bool> submit({
    required String account,
    required String credential,
  }) async {
    if (!state.agreeTerms) return false;

    state = state.copyWith(loading: true);
    await _repository.submit(
      account: account,
      credential: credential,
      register: state.mode == AuthMode.register,
    );
    state = state.copyWith(loading: false);
    return true;
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return const AuthRepository();
});

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthViewState>((ref) {
      return AuthController(ref.watch(authRepositoryProvider));
    });
