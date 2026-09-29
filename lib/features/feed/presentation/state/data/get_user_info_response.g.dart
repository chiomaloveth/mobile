// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_user_info_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GetUserInfoResponseImpl _$$GetUserInfoResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$GetUserInfoResponseImpl(
      success: json['success'] as bool,
      data: UserInfoData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$GetUserInfoResponseImplToJson(
        _$GetUserInfoResponseImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'data': instance.data.toJson(),
    };

_$UserInfoDataImpl _$$UserInfoDataImplFromJson(Map<String, dynamic> json) =>
    _$UserInfoDataImpl(
      security: Security.fromJson(json['security'] as Map<String, dynamic>),
      adminFlags:
          AdminFlags.fromJson(json['adminFlags'] as Map<String, dynamic>),
      privacy: Privacy.fromJson(json['privacy'] as Map<String, dynamic>),
      dataSettings:
          DataSettings.fromJson(json['dataSettings'] as Map<String, dynamic>),
      accountInfoRequest: AccountInfoRequest.fromJson(
          json['accountInfoRequest'] as Map<String, dynamic>),
      settings: Settings.fromJson(json['settings'] as Map<String, dynamic>),
      id: json['_id'] as String,
      phone: json['phone'] as String,
      v: (json['__v'] as num?)?.toInt(),
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
      preferences: json['preferences'] == null
          ? null
          : CategoriesData.fromJson(
              json['preferences'] as Map<String, dynamic>),
      instagram: json['instagram'] as String?,
      youtube: json['youtube'] as String?,
      interestScores: json['interestScores'] as Map<String, dynamic>?,
      isFollowing: json['isFollowing'] as bool?,
      username: json['username'] as String?,
      email: json['email'] as String?,
      postsCount: (json['postsCount'] as num?)?.toInt(),
      followersCount: (json['followersCount'] as num?)?.toInt(),
      followingCount: (json['followingCount'] as num?)?.toInt(),
      hidePhone: json['hidePhone'] as bool?,
      fullName: json['fullName'] as String?,
      link: json['link'] as String?,
    );

Map<String, dynamic> _$$UserInfoDataImplToJson(_$UserInfoDataImpl instance) {
  final val = <String, dynamic>{
    'security': instance.security.toJson(),
    'adminFlags': instance.adminFlags.toJson(),
    'privacy': instance.privacy.toJson(),
    'dataSettings': instance.dataSettings.toJson(),
    'accountInfoRequest': instance.accountInfoRequest.toJson(),
    'settings': instance.settings.toJson(),
    '_id': instance.id,
    'phone': instance.phone,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('__v', instance.v);
  val['about'] = instance.about;
  val['accountStatus'] = instance.accountStatus;
  val['blockedUsers'] = instance.blockedUsers;
  val['contacts'] = instance.contacts;
  val['createdAt'] = instance.createdAt;
  val['fcmTokens'] = instance.fcmTokens;
  val['hasPassword'] = instance.hasPassword;
  val['isOnline'] = instance.isOnline;
  val['isProfileComplete'] = instance.isProfileComplete;
  val['lastActive'] = instance.lastActive;
  val['profileImages'] = instance.profileImages;
  val['profilePicture'] = instance.profilePicture;
  val['reportCount'] = instance.reportCount;
  val['role'] = instance.role;
  val['updatedAt'] = instance.updatedAt;
  writeNotNull('preferences', instance.preferences?.toJson());
  writeNotNull('instagram', instance.instagram);
  writeNotNull('youtube', instance.youtube);
  writeNotNull('interestScores', instance.interestScores);
  writeNotNull('isFollowing', instance.isFollowing);
  writeNotNull('username', instance.username);
  writeNotNull('email', instance.email);
  writeNotNull('postsCount', instance.postsCount);
  writeNotNull('followersCount', instance.followersCount);
  writeNotNull('followingCount', instance.followingCount);
  writeNotNull('hidePhone', instance.hidePhone);
  writeNotNull('fullName', instance.fullName);
  writeNotNull('link', instance.link);
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

_$AutoDownloadImpl _$$AutoDownloadImplFromJson(Map<String, dynamic> json) =>
    _$AutoDownloadImpl(
      wifi: Wifi.fromJson(json['wifi'] as Map<String, dynamic>),
      cellular: Cellular.fromJson(json['cellular'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$AutoDownloadImplToJson(_$AutoDownloadImpl instance) =>
    <String, dynamic>{
      'wifi': instance.wifi.toJson(),
      'cellular': instance.cellular.toJson(),
    };

_$WifiImpl _$$WifiImplFromJson(Map<String, dynamic> json) => _$WifiImpl(
      documents: json['documents'] as bool,
      photos: json['photos'] as bool,
      videos: json['videos'] as bool,
    );

Map<String, dynamic> _$$WifiImplToJson(_$WifiImpl instance) =>
    <String, dynamic>{
      'documents': instance.documents,
      'photos': instance.photos,
      'videos': instance.videos,
    };

_$CellularImpl _$$CellularImplFromJson(Map<String, dynamic> json) =>
    _$CellularImpl(
      documents: json['documents'] as bool,
      photos: json['photos'] as bool,
      videos: json['videos'] as bool,
    );

Map<String, dynamic> _$$CellularImplToJson(_$CellularImpl instance) =>
    <String, dynamic>{
      'documents': instance.documents,
      'photos': instance.photos,
      'videos': instance.videos,
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
