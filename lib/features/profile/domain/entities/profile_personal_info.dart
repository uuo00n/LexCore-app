const String defaultProfileAvatarUrl =
    'https://lh3.googleusercontent.com/aida-public/AB6AXuDyKmFYBVM8oWRTG0Q8u1PW6_yLs5OrUx9YcDTUE651ZM3gwL1vh6qDY74nxbnATNwug0EcyB4yxsZZf5hZzkAtzEWWTmi9RMWEwqvnOmCR2o8SSyppIMtMtGwgh7SD8zXR7UNgGbl6pC2uIDAKlarIwpWZzitR8U56VPDkYEVRYaIRxP5YuRRimg6EQR_LQwtIUJMTIn2wAR8OAY9pRFtf5PFzzjChKCEz3C59Awsc46Ogpqh1151wB6-_XMqlnQnTaiogvTX0DOWj';

class ProfilePersonalInfo {
  const ProfilePersonalInfo({
    this.avatarPath,
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
      name: 'LexCore 用户',
      phone: '138****2601',
      email: 'lexcore_user@example.com',
      role: '个人法律顾问',
      organization: '独立执业',
      practiceAreas: ['民商事纠纷', '劳动争议'],
      language: '简体中文',
      notificationsEnabled: true,
    );
  }

  final String? avatarPath;
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
      defaultProfileAvatarUrl.isNotEmpty;

  ProfilePersonalInfo copyWith({
    Object? avatarPath = _copyWithSentinel,
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
      name: (json['name'] as String?)?.trim().isNotEmpty == true
          ? json['name'] as String
          : 'LexCore 用户',
      phone: _normalizePhone((json['phone'] as String?) ?? ''),
      email: (json['email'] as String?)?.trim().isNotEmpty == true
          ? json['email'] as String
          : 'lexcore_user@example.com',
      role: (json['role'] as String?)?.trim().isNotEmpty == true
          ? json['role'] as String
          : '个人法律顾问',
      organization: (json['organization'] as String?)?.trim().isNotEmpty == true
          ? json['organization'] as String
          : '独立执业',
      practiceAreas: _parsePracticeAreas(json['practiceAreas']),
      language: (json['language'] as String?)?.trim().isNotEmpty == true
          ? json['language'] as String
          : '简体中文',
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
    );
  }

  static List<String> _parsePracticeAreas(Object? source) {
    if (source is! List) {
      return const ['民商事纠纷', '劳动争议'];
    }
    final values = source
        .whereType<String>()
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList();
    if (values.isEmpty) {
      return const ['民商事纠纷', '劳动争议'];
    }
    return values;
  }

  static String _normalizePhone(String source) {
    final value = source.trim();
    if (value.isEmpty) {
      return '138****2601';
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
