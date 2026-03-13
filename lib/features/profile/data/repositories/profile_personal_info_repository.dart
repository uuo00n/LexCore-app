import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:lexcore/features/profile/domain/entities/profile_personal_info.dart';

class ProfilePersonalInfoRepository {
  const ProfilePersonalInfoRepository();

  static const _storageKey = 'profile_personal_info_v1';

  Future<ProfilePersonalInfo> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);

    if (raw == null || raw.isEmpty) {
      return ProfilePersonalInfo.defaults();
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return ProfilePersonalInfo.defaults();
      }
      return ProfilePersonalInfo.fromJson(Map<String, dynamic>.from(decoded));
    } catch (_) {
      return ProfilePersonalInfo.defaults();
    }
  }

  Future<void> save(ProfilePersonalInfo info) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(info.toJson()));
  }
}
