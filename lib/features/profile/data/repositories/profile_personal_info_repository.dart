import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lexcore/core/network/api_client.dart';
import 'package:lexcore/core/network/dio_provider.dart';
import 'package:lexcore/features/profile/domain/entities/profile_personal_info.dart';

class ProfilePersonalInfoRepository {
  ProfilePersonalInfoRepository({
    required ApiClient apiClient,
    SharedPreferences? preferences,
  }) : _apiClient = apiClient,
       _preferences = preferences;

  static const _avatarPathKey = 'profile_avatar_local_path';
  static const _avatarFileIdKey = 'profile_avatar_local_file_id';

  final ApiClient _apiClient;
  final SharedPreferences? _preferences;

  Future<ProfilePersonalInfo> load() async {
    final result = await _apiClient.get<ProfilePersonalInfo>(
      '/users/me',
      decoder: _decodeMeInfo,
    );
    final effectiveAvatarPath = await _resolveCachedAvatarPath(
      result.avatarFileId,
    );
    return result.copyWith(avatarPath: effectiveAvatarPath);
  }

  Future<ProfilePersonalInfo> save(ProfilePersonalInfo info) async {
    final payload = {
      'name': info.name.trim(),
      'phone': _normalizePhoneForBackend(info.phone),
      'job_title': info.role.trim(),
      'organization': info.organization.trim(),
      'practice_areas': info.practiceAreas,
      'language': info.language.trim(),
      'notifications_enabled': info.notificationsEnabled,
      'avatar_file_id': info.avatarFileId,
    };
    final result = await _apiClient.patch<ProfilePersonalInfo>(
      '/users/me/profile',
      data: payload,
      decoder: _decodeProfileInfo,
    );
    final mergedFileId = result.avatarFileId ?? info.avatarFileId;
    await _persistAvatarCache(
      path: info.avatarPath,
      fileId: mergedFileId,
    );
    return result.copyWith(
      avatarPath: info.avatarPath,
      avatarFileId: mergedFileId,
    );
  }

  Future<String> uploadAvatar(String filePath) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
      'biz_type': 'avatar',
    });

    final fileId = await _apiClient.post<String>(
      '/files/upload',
      data: formData,
      decoder: (data) {
        final map = (data as Map?)?.cast<String, dynamic>() ?? const {};
        final file = (map['file'] as Map?)?.cast<String, dynamic>() ?? const {};
        return file['file_id'] as String? ?? '';
      },
    );
    return fileId;
  }

  /// 根据服务端返回的 [serverFileId] 决定本地缓存里那张图能不能继续用。
  ///
  /// - 服务端没有头像 → 清掉本地缓存，返回 null。
  /// - 服务端的 fileId 与本地缓存的 fileId 一致，且本地文件还在 → 复用本地路径。
  /// - 其他情况（fileId 不匹配 / 文件已被清理）→ 视为脏数据，清掉缓存返回 null。
  Future<String?> _resolveCachedAvatarPath(String? serverFileId) async {
    final cache = await _readAvatarCache();

    if (serverFileId == null || serverFileId.trim().isEmpty) {
      if (cache.path != null || cache.fileId != null) {
        await _writeAvatarCache(path: null, fileId: null);
      }
      return null;
    }

    final cachedPath = cache.path;
    final cachedFileId = cache.fileId;
    if (cachedFileId != null &&
        cachedFileId == serverFileId &&
        cachedPath != null &&
        cachedPath.isNotEmpty &&
        File(cachedPath).existsSync()) {
      return cachedPath;
    }

    if (cache.path != null || cache.fileId != null) {
      await _writeAvatarCache(path: null, fileId: null);
    }
    return null;
  }

  Future<void> _persistAvatarCache({
    required String? path,
    required String? fileId,
  }) async {
    final hasBoth =
        path != null &&
        path.isNotEmpty &&
        fileId != null &&
        fileId.isNotEmpty;
    if (hasBoth) {
      await _writeAvatarCache(path: path, fileId: fileId);
    } else {
      await _writeAvatarCache(path: null, fileId: null);
    }
  }

  Future<({String? path, String? fileId})> _readAvatarCache() async {
    final prefs = await _prefs();
    return (
      path: prefs.getString(_avatarPathKey),
      fileId: prefs.getString(_avatarFileIdKey),
    );
  }

  Future<void> _writeAvatarCache({
    required String? path,
    required String? fileId,
  }) async {
    final prefs = await _prefs();
    if (path == null || path.isEmpty || fileId == null || fileId.isEmpty) {
      await prefs.remove(_avatarPathKey);
      await prefs.remove(_avatarFileIdKey);
      return;
    }
    await prefs.setString(_avatarPathKey, path);
    await prefs.setString(_avatarFileIdKey, fileId);
  }

  Future<SharedPreferences> _prefs() async {
    return _preferences ?? SharedPreferences.getInstance();
  }

  static ProfilePersonalInfo _decodeMeInfo(Object? data) {
    final map = (data as Map?)?.cast<String, dynamic>() ?? const {};
    final profile =
        (map['profile'] as Map?)?.cast<String, dynamic>() ?? const {};
    return ProfilePersonalInfo(
      avatarPath: null,
      avatarFileId: profile['avatar_file_id'] as String?,
      name: profile['name'] as String? ?? '',
      phone: _normalizePhoneFromBackend(profile['phone'] as String?),
      email: profile['email'] as String? ?? map['email'] as String? ?? '',
      role: profile['job_title'] as String? ?? '',
      organization: profile['organization'] as String? ?? '',
      practiceAreas: ((profile['practice_areas'] as List?) ?? const [])
          .whereType<String>()
          .where((value) => value.trim().isNotEmpty)
          .toList(),
      language: profile['language'] as String? ?? '',
      notificationsEnabled: profile['notifications_enabled'] as bool? ?? true,
    );
  }

  static ProfilePersonalInfo _decodeProfileInfo(Object? data) {
    final map = (data as Map?)?.cast<String, dynamic>() ?? const {};
    return ProfilePersonalInfo(
      avatarPath: null,
      avatarFileId: map['avatar_file_id'] as String?,
      name: map['name'] as String? ?? '',
      phone: _normalizePhoneFromBackend(map['phone'] as String?),
      email: map['email'] as String? ?? '',
      role: map['job_title'] as String? ?? '',
      organization: map['organization'] as String? ?? '',
      practiceAreas: ((map['practice_areas'] as List?) ?? const [])
          .whereType<String>()
          .where((value) => value.trim().isNotEmpty)
          .toList(),
      language: map['language'] as String? ?? '',
      notificationsEnabled: map['notifications_enabled'] as bool? ?? true,
    );
  }

  static String _normalizePhoneFromBackend(String? value) {
    final phone = value?.trim() ?? '';
    if (phone.isEmpty) {
      return '';
    }
    return phone;
  }

  static String? _normalizePhoneForBackend(String value) {
    final phone = value.trim();
    if (phone.isEmpty) {
      return null;
    }
    return phone;
  }
}

final profilePersonalInfoRepositoryProvider =
    Provider<ProfilePersonalInfoRepository>((ref) {
      return ProfilePersonalInfoRepository(
        apiClient: ref.watch(apiClientProvider),
      );
    });
