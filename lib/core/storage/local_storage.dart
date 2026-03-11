import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  LocalStorage(this._prefs);

  final SharedPreferences _prefs;

  Future<void> setToken(String token) => _prefs.setString('auth_token', token);

  String? get token => _prefs.getString('auth_token');

  Future<void> clearAuth() async {
    await _prefs.remove('auth_token');
  }
}
