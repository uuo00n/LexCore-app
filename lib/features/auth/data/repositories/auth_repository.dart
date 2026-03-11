class AuthRepository {
  const AuthRepository();

  Future<void> submit({
    required String account,
    required String credential,
    required bool register,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }
}
