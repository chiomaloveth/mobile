import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:qik_talk/features/feed/presentation/state/data/create_preference_list.dart';

part 'get_user_by_preference.freezed.dart';
part 'get_user_by_preference.g.dart';

@freezed
class GetUserByPreference with _$GetUserByPreference {
  const factory GetUserByPreference({
    required bool success,
    required String message,
    required MatchingUsersData data,
  }) = _GetUserByPreference;

  factory GetUserByPreference.fromJson(Map<String, dynamic> json) =>
      _$GetUserByPreferenceFromJson(json);
}

@freezed
class MatchingUsersData with _$MatchingUsersData {
  const factory MatchingUsersData({
    required Preferences myPreferences,
    required List<MatchingUser> matchingUsers,
    required int totalMatches,
  }) = _MatchingUsersData;

  factory MatchingUsersData.fromJson(Map<String, dynamic> json) =>
      _$MatchingUsersDataFromJson(json);
}

@freezed
class MatchingUser with _$MatchingUser {
  const factory MatchingUser({
    @JsonKey(name: '_id') required String id,
    required String phone,
    @JsonKey(name: '__v') required int v,
    required String about,
    required AccountInfoRequest accountInfoRequest,
    required String accountStatus,
    required AdminFlags adminFlags,
    required List<String> blockedUsers,
    required List<String> contacts,
    required String createdAt,
    required DataSettings dataSettings,
    required List<String> fcmTokens,
    required bool hasPassword,
    required bool isOnline,
    required bool isProfileComplete,
    required String lastActive,
    required Privacy privacy,
    required String profilePicture,
    required int reportCount,
    required String role,
    required Security security,
    required Settings settings,
    required String updatedAt,
    String? username,
    String? email,
    required Preferences preferences,
    required Preferences matchedPreferences,
    required int matchCount,
  }) = _MatchingUser;

  factory MatchingUser.fromJson(Map<String, dynamic> json) =>
      _$MatchingUserFromJson(json);
}
