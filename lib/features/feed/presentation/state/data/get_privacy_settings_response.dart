import 'package:freezed_annotation/freezed_annotation.dart';

part 'get_privacy_settings_response.freezed.dart';
part 'get_privacy_settings_response.g.dart';

@freezed
class GetPrivacySettingsResponse with _$GetPrivacySettingsResponse {
  const factory GetPrivacySettingsResponse({
    required bool success,
    required GetPrivacySettingsData data,
  }) = _GetPrivacySettingsResponse;

  factory GetPrivacySettingsResponse.fromJson(Map<String, dynamic> json) =>
      _$GetPrivacySettingsResponseFromJson(json);
}

@freezed
class GetPrivacySettingsData with _$GetPrivacySettingsData {
  const factory GetPrivacySettingsData({
    @Default(false) bool isPrivateAccount,
    required GetPrivacyData privacy,
    @Default('off') String defaultMessageTimer,
    required GetPrivacyAppSettings settings,
  }) = _GetPrivacySettingsData;

  factory GetPrivacySettingsData.fromJson(Map<String, dynamic> json) =>
      _$GetPrivacySettingsDataFromJson(json);
}

@freezed
class GetPrivacyData with _$GetPrivacyData {
  const factory GetPrivacyData({
    @Default([]) List<dynamic> profilePhotoExceptions,
    @Default([]) List<dynamic> aboutExceptions,
    @Default([]) List<dynamic> groupExceptions,
    @Default('contacts') String statusVisibility,
    @Default([]) List<dynamic> statusExceptions,
    @Default([]) List<dynamic> statusIncluded,
    @Default('everyone') String videosVisibility,
    @Default('everyone') String likedVideosVisibility,
    @Default('everyone') String commentPermissions,
    @Default('everyone') String duetPermissions,
    @Default('everyone') String messagePermissions,
    @Default('everyone') String about,
    @Default('everyone') String groups,
    @Default('everyone') String lastSeen,
    @Default('everyone') String profilePhoto,
    @Default(true) bool readReceipts,
    @Default([]) List<PrivacyExceptionUser> lastSeenExceptions,
  }) = _GetPrivacyData;

  factory GetPrivacyData.fromJson(Map<String, dynamic> json) =>
      _$GetPrivacyDataFromJson(json);
}

@freezed
class PrivacyExceptionUser with _$PrivacyExceptionUser {
  const factory PrivacyExceptionUser({
    @JsonKey(name: '_id') required String id,
    @Default('') String profilePicture,
  }) = _PrivacyExceptionUser;

  factory PrivacyExceptionUser.fromJson(Map<String, dynamic> json) =>
      _$PrivacyExceptionUserFromJson(json);
}

@freezed
class GetPrivacyAppSettings with _$GetPrivacyAppSettings {
  const factory GetPrivacyAppSettings({
    required GetPrivacyNotifications notifications,
    required GetPrivacyCommentFilters commentFilters,
    @Default(true) bool allowScreenshots,
    @Default('') String chatWallpaper,
    @Default(false) bool isAppLockEnabled,
    @Default('system') String themeMode,
  }) = _GetPrivacyAppSettings;

  factory GetPrivacyAppSettings.fromJson(Map<String, dynamic> json) =>
      _$GetPrivacyAppSettingsFromJson(json);
}

@freezed
class GetPrivacyNotifications with _$GetPrivacyNotifications {
  const factory GetPrivacyNotifications({
    @Default(true) bool calls,
    @Default(true) bool groups,
    @Default(true) bool messages,
    @Default(true) bool sound,
    @Default(true) bool vibrate,
    @Default('Default') String messageTone,
    @Default('Default') String groupTone,
  }) = _GetPrivacyNotifications;

  factory GetPrivacyNotifications.fromJson(Map<String, dynamic> json) =>
      _$GetPrivacyNotificationsFromJson(json);
}

@freezed
class GetPrivacyCommentFilters with _$GetPrivacyCommentFilters {
  const factory GetPrivacyCommentFilters({
    @Default(true) bool filterSpam,
    @Default(true) bool filterOffensiveWords,
  }) = _GetPrivacyCommentFilters;

  factory GetPrivacyCommentFilters.fromJson(Map<String, dynamic> json) =>
      _$GetPrivacyCommentFiltersFromJson(json);
}
