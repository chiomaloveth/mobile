import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_preference_list.freezed.dart';
part 'create_preference_list.g.dart';

@freezed
class CreatePreferenceList with _$CreatePreferenceList {
  const factory CreatePreferenceList({
    required bool success,
    required String message,
    required UserPreferencesData data,
  }) = _CreatePreferenceList;

  factory CreatePreferenceList.fromJson(Map<String, dynamic> json) =>
      _$CreatePreferenceListFromJson(json);
}

// user_preferences_data.dart
@freezed
class UserPreferencesData with _$UserPreferencesData {
  const factory UserPreferencesData({
    required Security security,
    required AdminFlags adminFlags,
    required Privacy privacy,
    required DataSettings dataSettings,
    required AccountInfoRequest accountInfoRequest,
    required Settings settings,
    required Preferences preferences,
    @JsonKey(name: '_id') required String id,
    required String phone,
    @JsonKey(name: '__v') required int v,
    required String about,
    required String accountStatus,
    required List<dynamic> blockedUsers,
    required List<dynamic> contacts,
    required String createdAt,
    required List<String> fcmTokens,
    required bool hasPassword,
    required bool isOnline,
    required bool isProfileComplete,
    required String lastActive,
    required List<dynamic> profileImages,
    required String profilePicture,
    required int reportCount,
    required String role,
    required String updatedAt,
    String? email,
    String? username,
    @JsonKey(defaultValue: 0) required int postsCount,
    @JsonKey(defaultValue: 0) required int followersCount,
    @JsonKey(defaultValue: 0) required int followingCount,
  }) = _UserPreferencesData;

  factory UserPreferencesData.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesDataFromJson(json);
}

// security.dart
@freezed
class Security with _$Security {
  const factory Security({required bool twoFactorEnabled}) = _Security;
  factory Security.fromJson(Map<String, dynamic> json) =>
      _$SecurityFromJson(json);
}

// admin_flags.dart
@freezed
class AdminFlags with _$AdminFlags {
  const factory AdminFlags({required bool isFlagged, required String reason}) =
      _AdminFlags;
  factory AdminFlags.fromJson(Map<String, dynamic> json) =>
      _$AdminFlagsFromJson(json);
}

// privacy.dart
@freezed
class Privacy with _$Privacy {
  const factory Privacy({
    required String about,
    required String groups,
    required String lastSeen,
    required String profilePhoto,
    required bool readReceipts,
  }) = _Privacy;
  factory Privacy.fromJson(Map<String, dynamic> json) =>
      _$PrivacyFromJson(json);
}

// download_config.dart (reused for wifi & cellular)
@freezed
class DownloadConfig with _$DownloadConfig {
  const factory DownloadConfig({
    required bool documents,
    required bool photos,
    required bool videos,
  }) = _DownloadConfig;
  factory DownloadConfig.fromJson(Map<String, dynamic> json) =>
      _$DownloadConfigFromJson(json);
}

// auto_download.dart
@freezed
class AutoDownload with _$AutoDownload {
  const factory AutoDownload({
    required DownloadConfig wifi,
    required DownloadConfig cellular,
  }) = _AutoDownload;
  factory AutoDownload.fromJson(Map<String, dynamic> json) =>
      _$AutoDownloadFromJson(json);
}

// data_settings.dart
@freezed
class DataSettings with _$DataSettings {
  const factory DataSettings({
    required AutoDownload autoDownload,
    required int networkUsage,
  }) = _DataSettings;
  factory DataSettings.fromJson(Map<String, dynamic> json) =>
      _$DataSettingsFromJson(json);
}

// account_info_request.dart
@freezed
class AccountInfoRequest with _$AccountInfoRequest {
  const factory AccountInfoRequest({required String status}) =
      _AccountInfoRequest;
  factory AccountInfoRequest.fromJson(Map<String, dynamic> json) =>
      _$AccountInfoRequestFromJson(json);
}

// notifications.dart
@freezed
class Notifications with _$Notifications {
  const factory Notifications({
    required bool calls,
    required bool groups,
    required bool messages,
    required bool sound,
    required bool vibrate,
  }) = _Notifications;
  factory Notifications.fromJson(Map<String, dynamic> json) =>
      _$NotificationsFromJson(json);
}

// settings.dart
@freezed
class Settings with _$Settings {
  const factory Settings({
    required Notifications notifications,
    required bool allowScreenshots,
    required String chatWallpaper,
    required bool isAppLockEnabled,
    required String themeMode,
  }) = _Settings;
  factory Settings.fromJson(Map<String, dynamic> json) =>
      _$SettingsFromJson(json);
}

// preferences.dart
@freezed
class Preferences with _$Preferences {
  const factory Preferences({
    List<String>? entertainment,
    List<String>? homeFamily,
    List<String>? fashionBeauty,
  }) = _Preferences;
  factory Preferences.fromJson(Map<String, dynamic> json) =>
      _$PreferencesFromJson(json);
}
