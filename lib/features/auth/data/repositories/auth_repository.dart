import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lexcore/core/network/api_client.dart';
import 'package:lexcore/core/network/auth_token_store.dart';
import 'package:lexcore/core/network/dio_provider.dart';

class AuthUser {
  const AuthUser({
    required this.userId,
    required this.email,
    required this.role,
    required this.accountType,
  });

  final String userId;
  final String email;
  final String role;
  final String accountType;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      userId: json['user_id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'user',
      accountType: json['account_type'] as String? ?? 'customer',
    );
  }
}

class AuthToken {
  const AuthToken({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
  });

  final String accessToken;
  final String tokenType;
  final int expiresIn;

  factory AuthToken.fromJson(Map<String, dynamic> json) {
    return AuthToken(
      accessToken: json['access_token'] as String? ?? '',
      tokenType: json['token_type'] as String? ?? 'bearer',
      expiresIn: json['expires_in'] as int? ?? 0,
    );
  }
}

class AuthLoginResult {
  const AuthLoginResult({
    required this.user,
    required this.token,
    required this.mustResetPassword,
  });

  final AuthUser user;
  final AuthToken token;
  final bool mustResetPassword;

  factory AuthLoginResult.fromJson(Map<String, dynamic> json) {
    return AuthLoginResult(
      user: AuthUser.fromJson(
        (json['user'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
      token: AuthToken.fromJson(
        (json['token'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
      mustResetPassword: json['must_reset_password'] as bool? ?? false,
    );
  }
}

class AuthRepository {
  const AuthRepository(this._apiClient, this._tokenStore);

  final ApiClient _apiClient;
  final AuthTokenStore _tokenStore;

  Future<AuthLoginResult> submit({
    required String account,
    required String credential,
    required bool register,
  }) async {
    final email = account.trim().toLowerCase();
    final password = credential.trim();

    if (register) {
      await _apiClient.post<bool>(
        '/auth/register',
        data: {'email': email, 'password': password},
        decoder: (_) => true,
      );
    }

    final loginResult = await _apiClient.post<AuthLoginResult>(
      '/auth/login',
      data: {'email': email, 'password': password},
      decoder: (data) => AuthLoginResult.fromJson(
        (data as Map?)?.cast<String, dynamic>() ?? const {},
      ),
    );

    await _tokenStore.write(loginResult.token.accessToken);
    return loginResult;
  }

  Future<bool> refreshSession() async {
    final token = _tokenStore.read();
    if (token == null || token.trim().isEmpty) {
      return false;
    }

    try {
      final refreshedToken = await _apiClient.post<AuthToken>(
        '/auth/refresh',
        decoder: (data) => AuthToken.fromJson(
          (data as Map?)?.cast<String, dynamic>() ?? const {},
        ),
      );
      await _tokenStore.write(refreshedToken.accessToken);
      return true;
    } catch (_) {
      await _tokenStore.clear();
      return false;
    }
  }

  Future<void> clearAuth() async {
    await _tokenStore.clear();
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(apiClientProvider),
    ref.watch(authTokenStoreProvider),
  );
});
