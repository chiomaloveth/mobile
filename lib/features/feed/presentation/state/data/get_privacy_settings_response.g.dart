// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_privacy_settings_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GetPrivacySettingsResponseImpl _$$GetPrivacySettingsResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$GetPrivacySettingsResponseImpl(
      success: json['success'] as bool,
      data:
          GetPrivacySettingsData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$GetPrivacySettingsResponseImplToJson(
        _$GetPrivacySettingsResponseImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'data': instance.data.toJson(),
    };

_$GetPrivacySettingsDataImpl _$$GetPrivacySettingsDataImplFromJson(
        Map<String, dynamic> json) =>
    _$GetPrivacySettingsDataImpl(
      isPrivateAccount: json['isPrivateAccount'] as bool? ?? false,
      privacy: GetPrivacyData.fromJson(json['privacy'] as Map<String, dynamic>),
      defaultMessageTimer: json['defaultMessageTimer'] as String? ?? 'off',
      settings: GetPrivacyAppSettings.fromJson(
          json['settings'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$GetPrivacySettingsDataImplToJson(
        _$GetPrivacySettingsDataImpl instance) =>
    <String, dynamic>{
      'isPrivateAccount': instance.isPrivateAccount,
      'privacy': instance.privacy.toJson(),
      'defaultMessageTimer': instance.defaultMessageTimer,
      'settings': instance.settings.toJson(),
    };

_$GetPrivacyDataImpl _$$GetPrivacyDataImplFromJson(Map<String, dynamic> json) =>
    _$GetPrivacyDataImpl(
      profilePhotoExceptions:
          json['profilePhotoExceptions'] as List<dynamic>? ?? const [],
      aboutExceptions: json['aboutExceptions'] as List<dynamic>? ?? const [],
      groupExceptions: json['groupExceptions'] as List<dynamic>? ?? const [],
      statusVisibility: json['statusVisibility'] as String? ?? 'contacts',
      statusExceptions: json['statusExceptions'] as List<dynamic>? ?? const [],
      statusIncluded: json['statusIncluded'] as List<dynamic>? ?? const [],
      videosVisibility: json['videosVisibility'] as String? ?? 'everyone',
      likedVideosVisibility:
          json['likedVideosVisibility'] as String? ?? 'everyone',
      commentPermissions: json['commentPermissions'] as String? ?? 'everyone',
      duetPermissions: json['duetPermissions'] as String? ?? 'everyone',
      messagePermissions: json['messagePermissions'] as String? ?? 'everyone',
      about: json['about'] as String? ?? 'everyone',
      groups: json['groups'] as String? ?? 'everyone',
      lastSeen: json['lastSeen'] as String? ?? 'everyone',
      profilePhoto: json['profilePhoto'] as String? ?? 'everyone',
      readReceipts: json['readReceipts'] as bool? ?? true,
      lastSeenExceptions: (json['lastSeenExceptions'] as List<dynamic>?)
              ?.map((e) =>
                  PrivacyExceptionUser.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$GetPrivacyDataImplToJson(
        _$GetPrivacyDataImpl instance) =>
    <String, dynamic>{
      'profilePhotoExceptions': instance.profilePhotoExceptions,
      'aboutExceptions': instance.aboutExceptions,
      'groupExceptions': instance.groupExceptions,
      'statusVisibility': instance.statusVisibility,
      'statusExceptions': instance.statusExceptions,
      'statusIncluded': instance.statusIncluded,
      'videosVisibility': instance.videosVisibility,
      'likedVideosVisibility': instance.likedVideosVisibility,
      'commentPermissions': instance.commentPermissions,
      'duetPermissions': instance.duetPermissions,
      'messagePermissions': instance.messagePermissions,
      'about': instance.about,
      'groups': instance.groups,
      'lastSeen': instance.lastSeen,
      'profilePhoto': instance.profilePhoto,
      'readReceipts': instance.readReceipts,
      'lastSeenExceptions':
          instance.lastSeenExceptions.map((e) => e.toJson()).toList(),
    };

_$PrivacyExceptionUserImpl _$$PrivacyExceptionUserImplFromJson(
        Map<String, dynamic> json) =>
    _$PrivacyExceptionUserImpl(
      id: json['_id'] as String,
      profilePicture: json['profilePicture'] as String? ?? '',
    );

Map<String, dynamic> _$$PrivacyExceptionUserImplToJson(
        _$PrivacyExceptionUserImpl instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'profilePicture': instance.profilePicture,
    };

_$GetPrivacyAppSettingsImpl _$$GetPrivacyAppSettingsImplFromJson(
        Map<String, dynamic> json) =>
    _$GetPrivacyAppSettingsImpl(
      notifications: GetPrivacyNotifications.fromJson(
          json['notifications'] as Map<String, dynamic>),
      commentFilters: GetPrivacyCommentFilters.fromJson(
          json['commentFilters'] as Map<String, dynamic>),
      allowScreenshots: json['allowScreenshots'] as bool? ?? true,
      chatWallpaper: json['chatWallpaper'] as String? ?? '',
      isAppLockEnabled: json['isAppLockEnabled'] as bool? ?? false,
      themeMode: json['themeMode'] as String? ?? 'system',
    );

Map<String, dynamic> _$$GetPrivacyAppSettingsImplToJson(
        _$GetPrivacyAppSettingsImpl instance) =>
    <String, dynamic>{
      'notifications': instance.notifications.toJson(),
      'commentFilters': instance.commentFilters.toJson(),
      'allowScreenshots': instance.allowScreenshots,
      'chatWallpaper': instance.chatWallpaper,
      'isAppLockEnabled': instance.isAppLockEnabled,
      'themeMode': instance.themeMode,
    };

_$GetPrivacyNotificationsImpl _$$GetPrivacyNotificationsImplFromJson(
        Map<String, dynamic> json) =>
    _$GetPrivacyNotificationsImpl(
      calls: json['calls'] as bool? ?? true,
      groups: json['groups'] as bool? ?? true,
      messages: json['messages'] as bool? ?? true,
      sound: json['sound'] as bool? ?? true,
      vibrate: json['vibrate'] as bool? ?? true,
      messageTone: json['messageTone'] as String? ?? 'Default',
      groupTone: json['groupTone'] as String? ?? 'Default',
    );

Map<String, dynamic> _$$GetPrivacyNotificationsImplToJson(
        _$GetPrivacyNotificationsImpl instance) =>
    <String, dynamic>{
      'calls': instance.calls,
      'groups': instance.groups,
      'messages': instance.messages,
      'sound': instance.sound,
      'vibrate': instance.vibrate,
      'messageTone': instance.messageTone,
      'groupTone': instance.groupTone,
    };

_$GetPrivacyCommentFiltersImpl _$$GetPrivacyCommentFiltersImplFromJson(
        Map<String, dynamic> json) =>
    _$GetPrivacyCommentFiltersImpl(
      filterSpam: json['filterSpam'] as bool? ?? true,
      filterOffensiveWords: json['filterOffensiveWords'] as bool? ?? true,
    );

Map<String, dynamic> _$$GetPrivacyCommentFiltersImplToJson(
        _$GetPrivacyCommentFiltersImpl instance) =>
    <String, dynamic>{
      'filterSpam': instance.filterSpam,
      'filterOffensiveWords': instance.filterOffensiveWords,
    };
