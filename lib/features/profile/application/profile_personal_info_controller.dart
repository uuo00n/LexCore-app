import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'package:lexcore/features/profile/data/repositories/profile_personal_info_repository.dart';
import 'package:lexcore/features/profile/domain/entities/profile_personal_info.dart';

class ProfilePersonalInfoState {
  const ProfilePersonalInfoState({
    required this.info,
    required this.completionPercent,
    required this.missingPriorityFields,
    required this.loading,
    this.feedbackMessage,
  });

  factory ProfilePersonalInfoState.initial() {
    final defaultInfo = ProfilePersonalInfo.defaults();
    return ProfilePersonalInfoState(
      info: defaultInfo,
      completionPercent: 0,
      missingPriorityFields: const [],
      loading: true,
    );
  }

  final ProfilePersonalInfo info;
  final int completionPercent;
  final List<String> missingPriorityFields;
  final bool loading;
  final String? feedbackMessage;

  ProfilePersonalInfoState copyWith({
    ProfilePersonalInfo? info,
    int? completionPercent,
    List<String>? missingPriorityFields,
    bool? loading,
    String? feedbackMessage,
    bool clearFeedbackMessage = false,
  }) {
    return ProfilePersonalInfoState(
      info: info ?? this.info,
      completionPercent: completionPercent ?? this.completionPercent,
      missingPriorityFields:
          missingPriorityFields ?? this.missingPriorityFields,
      loading: loading ?? this.loading,
      feedbackMessage: clearFeedbackMessage
          ? null
          : feedbackMessage ?? this.feedbackMessage,
    );
  }
}

enum _ProfileWeightField {
  avatar,
  name,
  phone,
  email,
  role,
  organization,
  practiceAreas,
  language,
}

class ProfilePersonalInfoController
    extends StateNotifier<ProfilePersonalInfoState> {
  ProfilePersonalInfoController({
    required ProfilePersonalInfoRepository repository,
    ImagePicker? imagePicker,
  }) : _repository = repository,
       _imagePicker = imagePicker ?? ImagePicker(),
       super(ProfilePersonalInfoState.initial()) {
    _loadPersonalInfo();
  }

  final ProfilePersonalInfoRepository _repository;
  final ImagePicker _imagePicker;

  static final _legacyCnPhoneRegExp = RegExp(r'^1\d{10}$');
  static final _emailRegExp = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static const _weights = <_ProfileWeightField, int>{
    _ProfileWeightField.name: 20,
    _ProfileWeightField.phone: 20,
    _ProfileWeightField.email: 20,
    _ProfileWeightField.avatar: 10,
    _ProfileWeightField.role: 12,
    _ProfileWeightField.organization: 10,
    _ProfileWeightField.practiceAreas: 6,
    _ProfileWeightField.language: 2,
  };

  static const _fieldLabels = <_ProfileWeightField, String>{
    _ProfileWeightField.name: '姓名',
    _ProfileWeightField.phone: '手机号',
    _ProfileWeightField.email: '邮箱',
    _ProfileWeightField.avatar: '头像',
    _ProfileWeightField.role: '职位角色',
    _ProfileWeightField.organization: '所属机构',
    _ProfileWeightField.practiceAreas: '业务领域',
    _ProfileWeightField.language: '语言偏好',
  };

  Future<void> _loadPersonalInfo() async {
    try {
      final info = await _repository.load();
      _applyInfo(info, loading: false, clearFeedbackMessage: true);
    } catch (_) {
      _applyInfo(
        ProfilePersonalInfo.defaults(),
        loading: false,
        feedbackMessage: '个人信息加载失败，已切换为空白资料',
      );
    }
  }

  Future<void> updateName(String value) async {
    await _saveInfo(state.info.copyWith(name: value.trim()));
  }

  Future<void> updatePhone(String value) async {
    await _saveInfo(state.info.copyWith(phone: _normalizePhone(value)));
  }

  Future<void> updateEmail(String value) async {
    await _saveInfo(state.info.copyWith(email: value.trim()));
  }

  Future<void> updateRole(String value) async {
    await _saveInfo(state.info.copyWith(role: value.trim()));
  }

  Future<void> updateOrganization(String value) async {
    await _saveInfo(state.info.copyWith(organization: value.trim()));
  }

  Future<void> updatePracticeAreas(List<String> values) async {
    final areas = values
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList();
    await _saveInfo(state.info.copyWith(practiceAreas: areas));
  }

  Future<void> updateLanguage(String value) async {
    await _saveInfo(state.info.copyWith(language: value.trim()));
  }

  Future<void> updateNotifications(bool enabled) async {
    await _saveInfo(state.info.copyWith(notificationsEnabled: enabled));
  }

  Future<void> pickAvatarFromGallery() async {
    if (kIsWeb) {
      state = state.copyWith(feedbackMessage: '当前平台暂不支持相册选择');
      return;
    }

    try {
      final selectedImage = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
        maxWidth: 1600,
      );
      if (selectedImage == null) {
        return;
      }

      final directory = await getApplicationDocumentsDirectory();
      final extension = _extractExtension(selectedImage);
      final savedPath =
          '${directory.path}/profile_avatar_${DateTime.now().millisecondsSinceEpoch}$extension';
      await selectedImage.saveTo(savedPath);

      final avatarFileId = await _repository.uploadAvatar(savedPath);
      await _saveInfo(
        state.info.copyWith(avatarPath: savedPath, avatarFileId: avatarFileId),
      );
    } catch (_) {
      state = state.copyWith(feedbackMessage: '头像更新失败，请稍后重试');
    }
  }

  Future<void> resetAvatar() async {
    await _saveInfo(state.info.copyWith(avatarPath: null, avatarFileId: null));
  }

  void clearFeedbackMessage() {
    state = state.copyWith(clearFeedbackMessage: true);
  }

  Future<void> _saveInfo(ProfilePersonalInfo info) async {
    _applyInfo(info, clearFeedbackMessage: true);
    try {
      final saved = await _repository.save(info);
      _applyInfo(
        saved.copyWith(avatarPath: info.avatarPath),
        clearFeedbackMessage: true,
      );
    } catch (_) {
      state = state.copyWith(feedbackMessage: '保存失败，请稍后重试');
    }
  }

  void _applyInfo(
    ProfilePersonalInfo info, {
    bool? loading,
    String? feedbackMessage,
    bool clearFeedbackMessage = false,
  }) {
    final metrics = _calculateCompletionMetrics(info);
    state = state.copyWith(
      info: info,
      completionPercent: metrics.completionPercent,
      missingPriorityFields: metrics.missingPriorityFields,
      loading: loading ?? state.loading,
      feedbackMessage: feedbackMessage,
      clearFeedbackMessage: clearFeedbackMessage,
    );
  }

  ({int completionPercent, List<String> missingPriorityFields})
  _calculateCompletionMetrics(ProfilePersonalInfo info) {
    final totalWeight = _weights.values.fold<int>(
      0,
      (sum, value) => sum + value,
    );
    var completedWeight = 0;
    final missingPriority = <String>[];

    for (final entry in _weights.entries) {
      final complete = _isFieldComplete(entry.key, info);
      if (complete) {
        completedWeight += entry.value;
      } else if (entry.value >= 10) {
        missingPriority.add(_fieldLabels[entry.key] ?? '');
      }
    }

    final percent = ((completedWeight / totalWeight) * 100).round();
    return (
      completionPercent: percent,
      missingPriorityFields: missingPriority
          .where((item) => item.isNotEmpty)
          .toList(),
    );
  }

  bool _isFieldComplete(_ProfileWeightField field, ProfilePersonalInfo info) {
    switch (field) {
      case _ProfileWeightField.avatar:
        return info.hasAvatar;
      case _ProfileWeightField.name:
        return info.name.trim().isNotEmpty;
      case _ProfileWeightField.phone:
        return ProfilePersonalInfo.isValidE164Phone(info.phone);
      case _ProfileWeightField.email:
        return _emailRegExp.hasMatch(info.email.trim());
      case _ProfileWeightField.role:
        return info.role.trim().isNotEmpty;
      case _ProfileWeightField.organization:
        return info.organization.trim().isNotEmpty;
      case _ProfileWeightField.practiceAreas:
        return info.practiceAreas.any((item) => item.trim().isNotEmpty);
      case _ProfileWeightField.language:
        return info.language.trim().isNotEmpty;
    }
  }

  String _extractExtension(XFile file) {
    final source = file.name.isNotEmpty ? file.name : file.path;
    final index = source.lastIndexOf('.');
    if (index <= -1 || index == source.length - 1) {
      return '.jpg';
    }
    return source.substring(index);
  }

  String _normalizePhone(String value) {
    final trimmed = value.trim();
    if (ProfilePersonalInfo.isValidE164Phone(trimmed)) {
      return trimmed;
    }
    if (_legacyCnPhoneRegExp.hasMatch(trimmed)) {
      return '+86$trimmed';
    }
    return trimmed;
  }
}
