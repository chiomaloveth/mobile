// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_privacy_settings_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UpdatePrivacySettingsDtoImpl _$$UpdatePrivacySettingsDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$UpdatePrivacySettingsDtoImpl(
      isPrivateAccount: json['isPrivateAccount'] as bool?,
      privacy: json['privacy'] == null
          ? null
          : PrivacySettingsDto.fromJson(
              json['privacy'] as Map<String, dynamic>),
      settings: json['settings'] == null
          ? null
          : AppSettingsDto.fromJson(json['settings'] as Map<String, dynamic>),
      defaultMessageTimer: json['defaultMessageTimer'] as String?,
    );

Map<String, dynamic> _$$UpdatePrivacySettingsDtoImplToJson(
    _$UpdatePrivacySettingsDtoImpl instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('isPrivateAccount', instance.isPrivateAccount);
  writeNotNull('privacy', instance.privacy?.toJson());
  writeNotNull('settings', instance.settings?.toJson());
  writeNotNull('defaultMessageTimer', instance.defaultMessageTimer);
  return val;
}

_$PrivacySettingsDtoImpl _$$PrivacySettingsDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$PrivacySettingsDtoImpl(
      statusVisibility: json['statusVisibility'] as String?,
      statusExceptions: (json['statusExceptions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      statusIncluded: (json['statusIncluded'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      likedVideosVisibility: json['likedVideosVisibility'] as String?,
      commentPermissions: json['commentPermissions'] as String?,
      duetPermissions: json['duetPermissions'] as String?,
      messagePermissions: json['messagePermissions'] as String?,
      about: json['about'] as String?,
      groups: json['groups'] as String?,
      lastSeen: json['lastSeen'] as String?,
      profilePhoto: json['profilePhoto'] as String?,
      readReceipts: json['readReceipts'] as bool?,
      lastSeenExceptions: (json['lastSeenExceptions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      profilePhotoExceptions: (json['profilePhotoExceptions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      aboutExceptions: (json['aboutExceptions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      groupExceptions: (json['groupExceptions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      videosVisibility: json['videosVisibility'] as String?,
    );

Map<String, dynamic> _$$PrivacySettingsDtoImplToJson(
    _$PrivacySettingsDtoImpl instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('statusVisibility', instance.statusVisibility);
  writeNotNull('statusExceptions', instance.statusExceptions);
  writeNotNull('statusIncluded', instance.statusIncluded);
  writeNotNull('likedVideosVisibility', instance.likedVideosVisibility);
  writeNotNull('commentPermissions', instance.commentPermissions);
  writeNotNull('duetPermissions', instance.duetPermissions);
  writeNotNull('messagePermissions', instance.messagePermissions);
  writeNotNull('about', instance.about);
  writeNotNull('groups', instance.groups);
  writeNotNull('lastSeen', instance.lastSeen);
  writeNotNull('profilePhoto', instance.profilePhoto);
  writeNotNull('readReceipts', instance.readReceipts);
  writeNotNull('lastSeenExceptions', instance.lastSeenExceptions);
  writeNotNull('profilePhotoExceptions', instance.profilePhotoExceptions);
  writeNotNull('aboutExceptions', instance.aboutExceptions);
  writeNotNull('groupExceptions', instance.groupExceptions);
  writeNotNull('videosVisibility', instance.videosVisibility);
  return val;
}

_$AppSettingsDtoImpl _$$AppSettingsDtoImplFromJson(Map<String, dynamic> json) =>
    _$AppSettingsDtoImpl(
      notifications: json['notifications'] == null
          ? null
          : NotificationSettingsDto.fromJson(
              json['notifications'] as Map<String, dynamic>),
      commentFilters: json['commentFilters'] == null
          ? null
          : CommentFiltersDto.fromJson(
              json['commentFilters'] as Map<String, dynamic>),
      allowScreenshots: json['allowScreenshots'] as bool?,
      chatWallpaper: json['chatWallpaper'] as String?,
      isAppLockEnabled: json['isAppLockEnabled'] as bool?,
      themeMode: json['themeMode'] as String?,
    );

Map<String, dynamic> _$$AppSettingsDtoImplToJson(
    _$AppSettingsDtoImpl instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('notifications', instance.notifications?.toJson());
  writeNotNull('commentFilters', instance.commentFilters?.toJson());
  writeNotNull('allowScreenshots', instance.allowScreenshots);
  writeNotNull('chatWallpaper', instance.chatWallpaper);
  writeNotNull('isAppLockEnabled', instance.isAppLockEnabled);
  writeNotNull('themeMode', instance.themeMode);
  return val;
}

_$NotificationSettingsDtoImpl _$$NotificationSettingsDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$NotificationSettingsDtoImpl(
      calls: json['calls'] as bool?,
      groups: json['groups'] as bool?,
      messages: json['messages'] as bool?,
      sound: json['sound'] as bool?,
      vibrate: json['vibrate'] as bool?,
      messageTone: json['messageTone'] as String?,
      groupTone: json['groupTone'] as String?,
      notificationVolume: (json['notificationVolume'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$NotificationSettingsDtoImplToJson(
    _$NotificationSettingsDtoImpl instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('calls', instance.calls);
  writeNotNull('groups', instance.groups);
  writeNotNull('messages', instance.messages);
  writeNotNull('sound', instance.sound);
  writeNotNull('vibrate', instance.vibrate);
  writeNotNull('messageTone', instance.messageTone);
  writeNotNull('groupTone', instance.groupTone);
  writeNotNull('notificationVolume', instance.notificationVolume);
  return val;
}

_$CommentFiltersDtoImpl _$$CommentFiltersDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$CommentFiltersDtoImpl(
      filterOffensiveWords: json['filterOffensiveWords'] as bool?,
      filterSpam: json['filterSpam'] as bool?,
    );

Map<String, dynamic> _$$CommentFiltersDtoImplToJson(
    _$CommentFiltersDtoImpl instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('filterOffensiveWords', instance.filterOffensiveWords);
  writeNotNull('filterSpam', instance.filterSpam);
  return val;
}
