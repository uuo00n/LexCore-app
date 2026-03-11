class SettingsState {
  const SettingsState({
    required this.notificationsEnabled,
    required this.biometricEnabled,
  });

  final bool notificationsEnabled;
  final bool biometricEnabled;

  SettingsState copyWith({bool? notificationsEnabled, bool? biometricEnabled}) {
    return SettingsState(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
    );
  }
}
