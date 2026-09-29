// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_user_by_preference.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GetUserByPreferenceImpl _$$GetUserByPreferenceImplFromJson(
        Map<String, dynamic> json) =>
    _$GetUserByPreferenceImpl(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: MatchingUsersData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$GetUserByPreferenceImplToJson(
        _$GetUserByPreferenceImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data.toJson(),
    };

_$MatchingUsersDataImpl _$$MatchingUsersDataImplFromJson(
        Map<String, dynamic> json) =>
    _$MatchingUsersDataImpl(
      myPreferences:
          Preferences.fromJson(json['myPreferences'] as Map<String, dynamic>),
      matchingUsers: (json['matchingUsers'] as List<dynamic>)
          .map((e) => MatchingUser.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalMatches: (json['totalMatches'] as num).toInt(),
    );

Map<String, dynamic> _$$MatchingUsersDataImplToJson(
        _$MatchingUsersDataImpl instance) =>
    <String, dynamic>{
      'myPreferences': instance.myPreferences.toJson(),
      'matchingUsers': instance.matchingUsers.map((e) => e.toJson()).toList(),
      'totalMatches': instance.totalMatches,
    };

_$MatchingUserImpl _$$MatchingUserImplFromJson(Map<String, dynamic> json) =>
    _$MatchingUserImpl(
      id: json['_id'] as String,
      phone: json['phone'] as String,
      v: (json['__v'] as num).toInt(),
      about: json['about'] as String,
      accountInfoRequest: AccountInfoRequest.fromJson(
          json['accountInfoRequest'] as Map<String, dynamic>),
      accountStatus: json['accountStatus'] as String,
      adminFlags:
          AdminFlags.fromJson(json['adminFlags'] as Map<String, dynamic>),
      blockedUsers: (json['blockedUsers'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      contacts:
          (json['contacts'] as List<dynamic>).map((e) => e as String).toList(),
      createdAt: json['createdAt'] as String,
      dataSettings:
          DataSettings.fromJson(json['dataSettings'] as Map<String, dynamic>),
      fcmTokens:
          (json['fcmTokens'] as List<dynamic>).map((e) => e as String).toList(),
      hasPassword: json['hasPassword'] as bool,
      isOnline: json['isOnline'] as bool,
      isProfileComplete: json['isProfileComplete'] as bool,
      lastActive: json['lastActive'] as String,
      privacy: Privacy.fromJson(json['privacy'] as Map<String, dynamic>),
      profilePicture: json['profilePicture'] as String,
      reportCount: (json['reportCount'] as num).toInt(),
      role: json['role'] as String,
      security: Security.fromJson(json['security'] as Map<String, dynamic>),
      settings: Settings.fromJson(json['settings'] as Map<String, dynamic>),
      updatedAt: json['updatedAt'] as String,
      username: json['username'] as String?,
      email: json['email'] as String?,
      preferences:
          Preferences.fromJson(json['preferences'] as Map<String, dynamic>),
      matchedPreferences: Preferences.fromJson(
          json['matchedPreferences'] as Map<String, dynamic>),
      matchCount: (json['matchCount'] as num).toInt(),
    );

Map<String, dynamic> _$$MatchingUserImplToJson(_$MatchingUserImpl instance) {
  final val = <String, dynamic>{
    '_id': instance.id,
    'phone': instance.phone,
    '__v': instance.v,
    'about': instance.about,
    'accountInfoRequest': instance.accountInfoRequest.toJson(),
    'accountStatus': instance.accountStatus,
    'adminFlags': instance.adminFlags.toJson(),
    'blockedUsers': instance.blockedUsers,
    'contacts': instance.contacts,
    'createdAt': instance.createdAt,
    'dataSettings': instance.dataSettings.toJson(),
    'fcmTokens': instance.fcmTokens,
    'hasPassword': instance.hasPassword,
    'isOnline': instance.isOnline,
    'isProfileComplete': instance.isProfileComplete,
    'lastActive': instance.lastActive,
    'privacy': instance.privacy.toJson(),
    'profilePicture': instance.profilePicture,
    'reportCount': instance.reportCount,
    'role': instance.role,
    'security': instance.security.toJson(),
    'settings': instance.settings.toJson(),
    'updatedAt': instance.updatedAt,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('username', instance.username);
  writeNotNull('email', instance.email);
  val['preferences'] = instance.preferences.toJson();
  val['matchedPreferences'] = instance.matchedPreferences.toJson();
  val['matchCount'] = instance.matchCount;
  return val;
}
