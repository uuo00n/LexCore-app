import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lexcore/core/error/app_exception.dart';
import 'package:lexcore/features/auth/data/repositories/auth_repository.dart';
import 'package:lexcore/features/auth/domain/entities/auth_mode.dart';

class AuthViewState {
  const AuthViewState({
    this.mode = AuthMode.login,
    this.agreeTerms = false,
    this.loading = false,
    this.authenticated = false,
    this.errorMessage,
    this.bootstrapped = false,
  });

  final AuthMode mode;
  final bool agreeTerms;
  final bool loading;
  final bool authenticated;
  final String? errorMessage;
  final bool bootstrapped;

  AuthViewState copyWith({
    AuthMode? mode,
    bool? agreeTerms,
    bool? loading,
    bool? authenticated,
    String? errorMessage,
    bool clearErrorMessage = false,
    bool? bootstrapped,
  }) {
    return AuthViewState(
      mode: mode ?? this.mode,
      agreeTerms: agreeTerms ?? this.agreeTerms,
      loading: loading ?? this.loading,
      authenticated: authenticated ?? this.authenticated,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      bootstrapped: bootstrapped ?? this.bootstrapped,
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

  Future<void> bootstrapSession() async {
    if (state.bootstrapped || state.loading) {
      return;
    }

    state = state.copyWith(loading: true, clearErrorMessage: true);
    try {
      final ok = await _repository.refreshSession();
      state = state.copyWith(
        loading: false,
        authenticated: ok,
        bootstrapped: true,
        clearErrorMessage: true,
      );
    } catch (_) {
      state = state.copyWith(
        loading: false,
        authenticated: false,
        bootstrapped: true,
      );
    }
  }

  Future<bool> submit({
    required String account,
    required String credential,
  }) async {
    if (!state.agreeTerms) return false;

    state = state.copyWith(loading: true, clearErrorMessage: true);
    try {
      await _repository.submit(
        account: account,
        credential: credential,
        register: state.mode == AuthMode.register,
      );
      state = state.copyWith(
        loading: false,
        authenticated: true,
        clearErrorMessage: true,
      );
      return true;
    } on AppException catch (error) {
      state = state.copyWith(
        loading: false,
        authenticated: false,
        errorMessage: error.message,
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        loading: false,
        authenticated: false,
        errorMessage: '请求失败，请稍后重试',
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _repository.clearAuth();
    state = state.copyWith(authenticated: false);
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthViewState>((ref) {
      return AuthController(ref.watch(authRepositoryProvider));
    });
