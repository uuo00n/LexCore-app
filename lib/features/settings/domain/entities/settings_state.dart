enum SettingsNotificationPermission {
  unknown,
  granted,
  denied,
  permanentlyDenied,
  restricted,
}

class SettingsState {
  const SettingsState({
    required this.notificationsEnabled,
    required this.biometricEnabled,
    this.loading = false,
    this.cacheSizeBytes = 0,
    this.notificationPermissionStatus = SettingsNotificationPermission.unknown,
    this.biometricAvailable = false,
    this.feedbackMessage,
  });

  final bool notificationsEnabled;
  final bool biometricEnabled;
  final bool loading;
  final int cacheSizeBytes;
  final SettingsNotificationPermission notificationPermissionStatus;
  final bool biometricAvailable;
  final String? feedbackMessage;

  SettingsState copyWith({
    bool? notificationsEnabled,
    bool? biometricEnabled,
    bool? loading,
    int? cacheSizeBytes,
    SettingsNotificationPermission? notificationPermissionStatus,
    bool? biometricAvailable,
    String? feedbackMessage,
    bool clearFeedbackMessage = false,
  }) {
    return SettingsState(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      loading: loading ?? this.loading,
      cacheSizeBytes: cacheSizeBytes ?? this.cacheSizeBytes,
      notificationPermissionStatus:
          notificationPermissionStatus ?? this.notificationPermissionStatus,
      biometricAvailable: biometricAvailable ?? this.biometricAvailable,
      feedbackMessage: clearFeedbackMessage
          ? null
          : feedbackMessage ?? this.feedbackMessage,
    );
  }
}
