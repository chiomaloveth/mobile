import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_preference_list.dart';

part 'get_user_info_response.freezed.dart';
part 'get_user_info_response.g.dart';

@freezed
class GetUserInfoResponse with _$GetUserInfoResponse {
  const factory GetUserInfoResponse({
    required bool success,
    required UserInfoData data,
  }) = _GetUserInfoResponse;

  factory GetUserInfoResponse.fromJson(Map<String, dynamic> json) =>
      _$GetUserInfoResponseFromJson(json);
}

@freezed
class UserInfoData with _$UserInfoData {
  const factory UserInfoData({
    required Security security,
    required AdminFlags adminFlags,
    required Privacy privacy,
    required DataSettings dataSettings,
    required AccountInfoRequest accountInfoRequest,
    required Settings settings,
    @JsonKey(name: '_id') required String id,
    required String phone,
    @JsonKey(name: '__v') int? v,
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
    CategoriesData? preferences,
    String? instagram,
    String? youtube,
    Map<String, dynamic>? interestScores,
    bool? isFollowing,
    String? username,
    String? email,
    int? postsCount,
    int? followersCount,
    int? followingCount,
    bool? hidePhone,
    String? fullName,
    String? link,
  }) = _UserInfoData;

  factory UserInfoData.fromJson(Map<String, dynamic> json) =>
      _$UserInfoDataFromJson(json);
}

@freezed
class Security with _$Security {
  const factory Security({required bool twoFactorEnabled}) = _Security;

  factory Security.fromJson(Map<String, dynamic> json) =>
      _$SecurityFromJson(json);
}

@freezed
class AdminFlags with _$AdminFlags {
  const factory AdminFlags({required bool isFlagged, required String reason}) =
      _AdminFlags;

  factory AdminFlags.fromJson(Map<String, dynamic> json) =>
      _$AdminFlagsFromJson(json);
}

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

@freezed
class DataSettings with _$DataSettings {
  const factory DataSettings({
    required AutoDownload autoDownload,
    required int networkUsage,
  }) = _DataSettings;

  factory DataSettings.fromJson(Map<String, dynamic> json) =>
      _$DataSettingsFromJson(json);
}

@freezed
class AutoDownload with _$AutoDownload {
  const factory AutoDownload({required Wifi wifi, required Cellular cellular}) =
      _AutoDownload;

  factory AutoDownload.fromJson(Map<String, dynamic> json) =>
      _$AutoDownloadFromJson(json);
}

@freezed
class Wifi with _$Wifi {
  const factory Wifi({
    required bool documents,
    required bool photos,
    required bool videos,
  }) = _Wifi;

  factory Wifi.fromJson(Map<String, dynamic> json) => _$WifiFromJson(json);
}

@freezed
class Cellular with _$Cellular {
  const factory Cellular({
    required bool documents,
    required bool photos,
    required bool videos,
  }) = _Cellular;

  factory Cellular.fromJson(Map<String, dynamic> json) =>
      _$CellularFromJson(json);
}

@freezed
class AccountInfoRequest with _$AccountInfoRequest {
  const factory AccountInfoRequest({required String status}) =
      _AccountInfoRequest;

  factory AccountInfoRequest.fromJson(Map<String, dynamic> json) =>
      _$AccountInfoRequestFromJson(json);
}

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
// @freezed
// class UserPreferences with _$UserPreferences {
//   const factory UserPreferences({
//     List<String>? entertainment,
//     List<String>? homeFamily,
//     List<String>? fashionBeauty,
//     @Default(false) bool? isPreferenceSet,
//   }) = _UserPreferences;

//   factory UserPreferences.fromJson(Map<String, dynamic> json) =>
//       _$UserPreferencesFromJson(json);
// }
