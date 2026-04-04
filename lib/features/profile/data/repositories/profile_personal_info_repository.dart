import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lexcore/core/network/api_client.dart';
import 'package:lexcore/core/network/dio_provider.dart';
import 'package:lexcore/features/profile/domain/entities/profile_personal_info.dart';

class ProfilePersonalInfoRepository {
  const ProfilePersonalInfoRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<ProfilePersonalInfo> load() async {
    final result = await _apiClient.get<ProfilePersonalInfo>(
      '/users/me',
      decoder: _decodeMeInfo,
    );
    return result;
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
    return result.copyWith(
      avatarPath: info.avatarPath,
      avatarFileId: result.avatarFileId ?? info.avatarFileId,
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
      return ProfilePersonalInfoRepository(ref.watch(apiClientProvider));
    });
