import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lexcore/core/storage/local_storage.dart';

class AuthTokenStore {
  AuthTokenStore(this._localStorage);

  final LocalStorage _localStorage;

  String? read() => _localStorage.token;

  Future<void> write(String token) => _localStorage.setToken(token);

  Future<void> clear() => _localStorage.clearAuth();
}

final authTokenStoreProvider = Provider<AuthTokenStore>((ref) {
  return AuthTokenStore(ref.watch(localStorageProvider));
});
