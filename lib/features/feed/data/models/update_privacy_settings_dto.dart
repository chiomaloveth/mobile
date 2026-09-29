import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_privacy_settings_dto.freezed.dart';
part 'update_privacy_settings_dto.g.dart';

@freezed
class UpdatePrivacySettingsDto with _$UpdatePrivacySettingsDto {
  @JsonSerializable(includeIfNull: false)
  const factory UpdatePrivacySettingsDto({
    bool? isPrivateAccount,
    PrivacySettingsDto? privacy,
    AppSettingsDto? settings,
    String? defaultMessageTimer,
  }) = _UpdatePrivacySettingsDto;

  factory UpdatePrivacySettingsDto.fromJson(Map<String, dynamic> json) =>
      _$UpdatePrivacySettingsDtoFromJson(json);
}

@freezed
class PrivacySettingsDto with _$PrivacySettingsDto {
  @JsonSerializable(includeIfNull: false)
  const factory PrivacySettingsDto({
    String? statusVisibility,
    List<String>? statusExceptions,
    List<String>? statusIncluded,
    String? likedVideosVisibility,
    String? commentPermissions,
    String? duetPermissions,
    String? messagePermissions,
    String? about,
    String? groups,
    String? lastSeen,
    String? profilePhoto,
    bool? readReceipts,
    List<String>? lastSeenExceptions,
    List<String>? profilePhotoExceptions,
    List<String>? aboutExceptions,
    List<String>? groupExceptions,
    String? videosVisibility,
  }) = _PrivacySettingsDto;

  factory PrivacySettingsDto.fromJson(Map<String, dynamic> json) =>
      _$PrivacySettingsDtoFromJson(json);
}

@freezed
class AppSettingsDto with _$AppSettingsDto {
  @JsonSerializable(includeIfNull: false)
  const factory AppSettingsDto({
    NotificationSettingsDto? notifications,
    CommentFiltersDto? commentFilters,
    bool? allowScreenshots,
    String? chatWallpaper,
    bool? isAppLockEnabled,
    String? themeMode,
  }) = _AppSettingsDto;

  factory AppSettingsDto.fromJson(Map<String, dynamic> json) =>
      _$AppSettingsDtoFromJson(json);
}

@freezed
class NotificationSettingsDto with _$NotificationSettingsDto {
  @JsonSerializable(includeIfNull: false)
  const factory NotificationSettingsDto({
    bool? calls,
    bool? groups,
    bool? messages,
    bool? sound,
    bool? vibrate,
    String? messageTone,
    String? groupTone,
    double? notificationVolume,
  }) = _NotificationSettingsDto;

  factory NotificationSettingsDto.fromJson(Map<String, dynamic> json) =>
      _$NotificationSettingsDtoFromJson(json);
}

@freezed
class CommentFiltersDto with _$CommentFiltersDto {
  @JsonSerializable(includeIfNull: false)
  const factory CommentFiltersDto({
    bool? filterOffensiveWords,
    bool? filterSpam,
  }) = _CommentFiltersDto;

  factory CommentFiltersDto.fromJson(Map<String, dynamic> json) =>
      _$CommentFiltersDtoFromJson(json);
}
