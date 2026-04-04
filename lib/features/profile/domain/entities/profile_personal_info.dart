class ProfilePersonalInfo {
  const ProfilePersonalInfo({
    this.avatarPath,
    this.avatarFileId,
    required this.name,
    required this.phone,
    required this.email,
    required this.role,
    required this.organization,
    required this.practiceAreas,
    required this.language,
    required this.notificationsEnabled,
  });

  factory ProfilePersonalInfo.defaults() {
    return const ProfilePersonalInfo(
      avatarPath: null,
      avatarFileId: null,
      name: '',
      phone: '',
      email: '',
      role: '',
      organization: '',
      practiceAreas: [],
      language: '',
      notificationsEnabled: true,
    );
  }

  final String? avatarPath;
  final String? avatarFileId;
  final String name;
  final String phone;
  final String email;
  final String role;
  final String organization;
  final List<String> practiceAreas;
  final String language;
  final bool notificationsEnabled;

  static final _e164PhoneRegExp = RegExp(r'^\+[1-9]\d{5,14}$');
  static final _legacyCnPhoneRegExp = RegExp(r'^1\d{10}$');

  static bool isValidE164Phone(String value) {
    return _e164PhoneRegExp.hasMatch(value.trim());
  }

  bool get hasAvatar =>
      (avatarPath?.trim().isNotEmpty ?? false) ||
      (avatarFileId?.trim().isNotEmpty ?? false);

  ProfilePersonalInfo copyWith({
    Object? avatarPath = _copyWithSentinel,
    Object? avatarFileId = _copyWithSentinel,
    String? name,
    String? phone,
    String? email,
    String? role,
    String? organization,
    List<String>? practiceAreas,
    String? language,
    bool? notificationsEnabled,
  }) {
    return ProfilePersonalInfo(
      avatarPath: avatarPath == _copyWithSentinel
          ? this.avatarPath
          : avatarPath as String?,
      avatarFileId: avatarFileId == _copyWithSentinel
          ? this.avatarFileId
          : avatarFileId as String?,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      role: role ?? this.role,
      organization: organization ?? this.organization,
      practiceAreas: practiceAreas ?? this.practiceAreas,
      language: language ?? this.language,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'avatarPath': avatarPath,
      'avatarFileId': avatarFileId,
      'name': name,
      'phone': phone,
      'email': email,
      'role': role,
      'organization': organization,
      'practiceAreas': practiceAreas,
      'language': language,
      'notificationsEnabled': notificationsEnabled,
    };
  }

  factory ProfilePersonalInfo.fromJson(Map<String, dynamic> json) {
    return ProfilePersonalInfo(
      avatarPath: json['avatarPath'] as String?,
      avatarFileId: json['avatarFileId'] as String?,
      name: (json['name'] as String?)?.trim().isNotEmpty == true
          ? json['name'] as String
          : '',
      phone: _normalizePhone((json['phone'] as String?) ?? ''),
      email: (json['email'] as String?)?.trim().isNotEmpty == true
          ? json['email'] as String
          : '',
      role: (json['role'] as String?)?.trim().isNotEmpty == true
          ? json['role'] as String
          : '',
      organization: (json['organization'] as String?)?.trim().isNotEmpty == true
          ? json['organization'] as String
          : '',
      practiceAreas: _parsePracticeAreas(json['practiceAreas']),
      language: (json['language'] as String?)?.trim().isNotEmpty == true
          ? json['language'] as String
          : '',
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
    );
  }

  static List<String> _parsePracticeAreas(Object? source) {
    if (source is! List) {
      return const [];
    }
    final values = source
        .whereType<String>()
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList();
    return values;
  }

  static String _normalizePhone(String source) {
    final value = source.trim();
    if (value.isEmpty) {
      return '';
    }
    if (_e164PhoneRegExp.hasMatch(value)) {
      return value;
    }
    if (_legacyCnPhoneRegExp.hasMatch(value)) {
      return '+86$value';
    }
    return value;
  }
}

const _copyWithSentinel = Object();
