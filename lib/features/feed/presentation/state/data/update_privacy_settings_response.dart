import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_privacy_settings_response.freezed.dart';
part 'update_privacy_settings_response.g.dart';

@freezed
class UpdatePrivacySettingsResponse with _$UpdatePrivacySettingsResponse {
  const factory UpdatePrivacySettingsResponse({
    required bool success,
    required String message,
    required PrivacySettingsResponseData data,
  }) = _UpdatePrivacySettingsResponse;

  factory UpdatePrivacySettingsResponse.fromJson(Map<String, dynamic> json) =>
      _$UpdatePrivacySettingsResponseFromJson(json);
}

@freezed
class PrivacySettingsResponseData with _$PrivacySettingsResponseData {
  const factory PrivacySettingsResponseData({
    required bool isPrivateAccount,
    required PrivacyResponseData privacy,
    required String defaultMessageTimer,
    required SettingsResponseData settings,
  }) = _PrivacySettingsResponseData;

  factory PrivacySettingsResponseData.fromJson(Map<String, dynamic> json) =>
      _$PrivacySettingsResponseDataFromJson(json);
}

@freezed
class PrivacyResponseData with _$PrivacyResponseData {
  const factory PrivacyResponseData({
    @Default([]) List<String> profilePhotoExceptions,
    @Default([]) List<String> aboutExceptions,
    @Default([]) List<String> groupExceptions,
    @Default('contacts') String statusVisibility,
    @Default([]) List<String> statusExceptions,
    @Default([]) List<String> statusIncluded,
    @Default('everyone') String likedVideosVisibility,
    @Default('everyone') String commentPermissions,
    @Default('everyone') String duetPermissions,
    @Default('everyone') String messagePermissions,
    @Default('everyone') String about,
    @Default('everyone') String groups,
    @Default('everyone') String lastSeen,
    @Default('everyone') String profilePhoto,
    @Default(true) bool readReceipts,
    @Default([]) List<String> lastSeenExceptions,
    @Default('everyone') String videosVisibility,
  }) = _PrivacyResponseData;

  factory PrivacyResponseData.fromJson(Map<String, dynamic> json) =>
      _$PrivacyResponseDataFromJson(json);
}

@freezed
class SettingsResponseData with _$SettingsResponseData {
  const factory SettingsResponseData({
    required NotificationsResponseData notifications,
    required CommentFiltersResponseData commentFilters,
    @Default(true) bool allowScreenshots,
    @Default('') String chatWallpaper,
    @Default(false) bool isAppLockEnabled,
    @Default('system') String themeMode,
  }) = _SettingsResponseData;

  factory SettingsResponseData.fromJson(Map<String, dynamic> json) =>
      _$SettingsResponseDataFromJson(json);
}

@freezed
class NotificationsResponseData with _$NotificationsResponseData {
  const factory NotificationsResponseData({
    @Default(true) bool calls,
    @Default(true) bool groups,
    @Default(true) bool messages,
    @Default(true) bool sound,
    @Default(true) bool vibrate,
  }) = _NotificationsResponseData;

  factory NotificationsResponseData.fromJson(Map<String, dynamic> json) =>
      _$NotificationsResponseDataFromJson(json);
}

@freezed
class CommentFiltersResponseData with _$CommentFiltersResponseData {
  const factory CommentFiltersResponseData({
    @Default(true) bool filterOffensiveWords,
    @Default(false) bool filterSpam,
  }) = _CommentFiltersResponseData;

  factory CommentFiltersResponseData.fromJson(Map<String, dynamic> json) =>
      _$CommentFiltersResponseDataFromJson(json);
}
