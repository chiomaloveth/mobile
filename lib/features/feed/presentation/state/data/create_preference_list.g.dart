// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_preference_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CreatePreferenceListImpl _$$CreatePreferenceListImplFromJson(
        Map<String, dynamic> json) =>
    _$CreatePreferenceListImpl(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: UserPreferencesData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$CreatePreferenceListImplToJson(
        _$CreatePreferenceListImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data.toJson(),
    };

_$UserPreferencesDataImpl _$$UserPreferencesDataImplFromJson(
        Map<String, dynamic> json) =>
    _$UserPreferencesDataImpl(
      security: Security.fromJson(json['security'] as Map<String, dynamic>),
      adminFlags:
          AdminFlags.fromJson(json['adminFlags'] as Map<String, dynamic>),
      privacy: Privacy.fromJson(json['privacy'] as Map<String, dynamic>),
      dataSettings:
          DataSettings.fromJson(json['dataSettings'] as Map<String, dynamic>),
      accountInfoRequest: AccountInfoRequest.fromJson(
          json['accountInfoRequest'] as Map<String, dynamic>),
      settings: Settings.fromJson(json['settings'] as Map<String, dynamic>),
      preferences:
          Preferences.fromJson(json['preferences'] as Map<String, dynamic>),
      id: json['_id'] as String,
      phone: json['phone'] as String,
      v: (json['__v'] as num).toInt(),
      about: json['about'] as String,
      accountStatus: json['accountStatus'] as String,
      blockedUsers: json['blockedUsers'] as List<dynamic>,
      contacts: json['contacts'] as List<dynamic>,
      createdAt: json['createdAt'] as String,
      fcmTokens:
          (json['fcmTokens'] as List<dynamic>).map((e) => e as String).toList(),
      hasPassword: json['hasPassword'] as bool,
      isOnline: json['isOnline'] as bool,
      isProfileComplete: json['isProfileComplete'] as bool,
      lastActive: json['lastActive'] as String,
      profileImages: json['profileImages'] as List<dynamic>,
      profilePicture: json['profilePicture'] as String,
      reportCount: (json['reportCount'] as num).toInt(),
      role: json['role'] as String,
      updatedAt: json['updatedAt'] as String,
      email: json['email'] as String?,
      username: json['username'] as String?,
      postsCount: (json['postsCount'] as num?)?.toInt() ?? 0,
      followersCount: (json['followersCount'] as num?)?.toInt() ?? 0,
      followingCount: (json['followingCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$UserPreferencesDataImplToJson(
    _$UserPreferencesDataImpl instance) {
  final val = <String, dynamic>{
    'security': instance.security.toJson(),
    'adminFlags': instance.adminFlags.toJson(),
    'privacy': instance.privacy.toJson(),
    'dataSettings': instance.dataSettings.toJson(),
    'accountInfoRequest': instance.accountInfoRequest.toJson(),
    'settings': instance.settings.toJson(),
    'preferences': instance.preferences.toJson(),
    '_id': instance.id,
    'phone': instance.phone,
    '__v': instance.v,
    'about': instance.about,
    'accountStatus': instance.accountStatus,
    'blockedUsers': instance.blockedUsers,
    'contacts': instance.contacts,
    'createdAt': instance.createdAt,
    'fcmTokens': instance.fcmTokens,
    'hasPassword': instance.hasPassword,
    'isOnline': instance.isOnline,
    'isProfileComplete': instance.isProfileComplete,
    'lastActive': instance.lastActive,
    'profileImages': instance.profileImages,
    'profilePicture': instance.profilePicture,
    'reportCount': instance.reportCount,
    'role': instance.role,
    'updatedAt': instance.updatedAt,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('email', instance.email);
  writeNotNull('username', instance.username);
  val['postsCount'] = instance.postsCount;
  val['followersCount'] = instance.followersCount;
  val['followingCount'] = instance.followingCount;
  return val;
}

_$SecurityImpl _$$SecurityImplFromJson(Map<String, dynamic> json) =>
    _$SecurityImpl(
      twoFactorEnabled: json['twoFactorEnabled'] as bool,
    );

Map<String, dynamic> _$$SecurityImplToJson(_$SecurityImpl instance) =>
    <String, dynamic>{
      'twoFactorEnabled': instance.twoFactorEnabled,
    };

_$AdminFlagsImpl _$$AdminFlagsImplFromJson(Map<String, dynamic> json) =>
    _$AdminFlagsImpl(
      isFlagged: json['isFlagged'] as bool,
      reason: json['reason'] as String,
    );

Map<String, dynamic> _$$AdminFlagsImplToJson(_$AdminFlagsImpl instance) =>
    <String, dynamic>{
      'isFlagged': instance.isFlagged,
      'reason': instance.reason,
    };

_$PrivacyImpl _$$PrivacyImplFromJson(Map<String, dynamic> json) =>
    _$PrivacyImpl(
      about: json['about'] as String,
      groups: json['groups'] as String,
      lastSeen: json['lastSeen'] as String,
      profilePhoto: json['profilePhoto'] as String,
      readReceipts: json['readReceipts'] as bool,
    );

Map<String, dynamic> _$$PrivacyImplToJson(_$PrivacyImpl instance) =>
    <String, dynamic>{
      'about': instance.about,
      'groups': instance.groups,
      'lastSeen': instance.lastSeen,
      'profilePhoto': instance.profilePhoto,
      'readReceipts': instance.readReceipts,
    };

_$DownloadConfigImpl _$$DownloadConfigImplFromJson(Map<String, dynamic> json) =>
    _$DownloadConfigImpl(
      documents: json['documents'] as bool,
      photos: json['photos'] as bool,
      videos: json['videos'] as bool,
    );

Map<String, dynamic> _$$DownloadConfigImplToJson(
        _$DownloadConfigImpl instance) =>
    <String, dynamic>{
      'documents': instance.documents,
      'photos': instance.photos,
      'videos': instance.videos,
    };

_$AutoDownloadImpl _$$AutoDownloadImplFromJson(Map<String, dynamic> json) =>
    _$AutoDownloadImpl(
      wifi: DownloadConfig.fromJson(json['wifi'] as Map<String, dynamic>),
      cellular:
          DownloadConfig.fromJson(json['cellular'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$AutoDownloadImplToJson(_$AutoDownloadImpl instance) =>
    <String, dynamic>{
      'wifi': instance.wifi.toJson(),
      'cellular': instance.cellular.toJson(),
    };

_$DataSettingsImpl _$$DataSettingsImplFromJson(Map<String, dynamic> json) =>
    _$DataSettingsImpl(
      autoDownload:
          AutoDownload.fromJson(json['autoDownload'] as Map<String, dynamic>),
      networkUsage: (json['networkUsage'] as num).toInt(),
    );

Map<String, dynamic> _$$DataSettingsImplToJson(_$DataSettingsImpl instance) =>
    <String, dynamic>{
      'autoDownload': instance.autoDownload.toJson(),
      'networkUsage': instance.networkUsage,
    };

_$AccountInfoRequestImpl _$$AccountInfoRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$AccountInfoRequestImpl(
      status: json['status'] as String,
    );

Map<String, dynamic> _$$AccountInfoRequestImplToJson(
        _$AccountInfoRequestImpl instance) =>
    <String, dynamic>{
      'status': instance.status,
    };

_$NotificationsImpl _$$NotificationsImplFromJson(Map<String, dynamic> json) =>
    _$NotificationsImpl(
      calls: json['calls'] as bool,
      groups: json['groups'] as bool,
      messages: json['messages'] as bool,
      sound: json['sound'] as bool,
      vibrate: json['vibrate'] as bool,
    );

Map<String, dynamic> _$$NotificationsImplToJson(_$NotificationsImpl instance) =>
    <String, dynamic>{
      'calls': instance.calls,
      'groups': instance.groups,
      'messages': instance.messages,
      'sound': instance.sound,
      'vibrate': instance.vibrate,
    };

_$SettingsImpl _$$SettingsImplFromJson(Map<String, dynamic> json) =>
    _$SettingsImpl(
      notifications:
          Notifications.fromJson(json['notifications'] as Map<String, dynamic>),
      allowScreenshots: json['allowScreenshots'] as bool,
      chatWallpaper: json['chatWallpaper'] as String,
      isAppLockEnabled: json['isAppLockEnabled'] as bool,
      themeMode: json['themeMode'] as String,
    );

Map<String, dynamic> _$$SettingsImplToJson(_$SettingsImpl instance) =>
    <String, dynamic>{
      'notifications': instance.notifications.toJson(),
      'allowScreenshots': instance.allowScreenshots,
      'chatWallpaper': instance.chatWallpaper,
      'isAppLockEnabled': instance.isAppLockEnabled,
      'themeMode': instance.themeMode,
    };

_$PreferencesImpl _$$PreferencesImplFromJson(Map<String, dynamic> json) =>
    _$PreferencesImpl(
      entertainment: (json['entertainment'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      homeFamily: (json['homeFamily'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      fashionBeauty: (json['fashionBeauty'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$$PreferencesImplToJson(_$PreferencesImpl instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('entertainment', instance.entertainment);
  writeNotNull('homeFamily', instance.homeFamily);
  writeNotNull('fashionBeauty', instance.fashionBeauty);
  return val;
}
