// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_privacy_settings_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UpdatePrivacySettingsResponseImpl
    _$$UpdatePrivacySettingsResponseImplFromJson(Map<String, dynamic> json) =>
        _$UpdatePrivacySettingsResponseImpl(
          success: json['success'] as bool,
          message: json['message'] as String,
          data: PrivacySettingsResponseData.fromJson(
              json['data'] as Map<String, dynamic>),
        );

Map<String, dynamic> _$$UpdatePrivacySettingsResponseImplToJson(
        _$UpdatePrivacySettingsResponseImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data.toJson(),
    };

_$PrivacySettingsResponseDataImpl _$$PrivacySettingsResponseDataImplFromJson(
        Map<String, dynamic> json) =>
    _$PrivacySettingsResponseDataImpl(
      isPrivateAccount: json['isPrivateAccount'] as bool,
      privacy:
          PrivacyResponseData.fromJson(json['privacy'] as Map<String, dynamic>),
      defaultMessageTimer: json['defaultMessageTimer'] as String,
      settings: SettingsResponseData.fromJson(
          json['settings'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$PrivacySettingsResponseDataImplToJson(
        _$PrivacySettingsResponseDataImpl instance) =>
    <String, dynamic>{
      'isPrivateAccount': instance.isPrivateAccount,
      'privacy': instance.privacy.toJson(),
      'defaultMessageTimer': instance.defaultMessageTimer,
      'settings': instance.settings.toJson(),
    };

_$PrivacyResponseDataImpl _$$PrivacyResponseDataImplFromJson(
        Map<String, dynamic> json) =>
    _$PrivacyResponseDataImpl(
      profilePhotoExceptions: (json['profilePhotoExceptions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      aboutExceptions: (json['aboutExceptions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      groupExceptions: (json['groupExceptions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      statusVisibility: json['statusVisibility'] as String? ?? 'contacts',
      statusExceptions: (json['statusExceptions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      statusIncluded: (json['statusIncluded'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
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
              ?.map((e) => e as String)
              .toList() ??
          const [],
      videosVisibility: json['videosVisibility'] as String? ?? 'everyone',
    );

Map<String, dynamic> _$$PrivacyResponseDataImplToJson(
        _$PrivacyResponseDataImpl instance) =>
    <String, dynamic>{
      'profilePhotoExceptions': instance.profilePhotoExceptions,
      'aboutExceptions': instance.aboutExceptions,
      'groupExceptions': instance.groupExceptions,
      'statusVisibility': instance.statusVisibility,
      'statusExceptions': instance.statusExceptions,
      'statusIncluded': instance.statusIncluded,
      'likedVideosVisibility': instance.likedVideosVisibility,
      'commentPermissions': instance.commentPermissions,
      'duetPermissions': instance.duetPermissions,
      'messagePermissions': instance.messagePermissions,
      'about': instance.about,
      'groups': instance.groups,
      'lastSeen': instance.lastSeen,
      'profilePhoto': instance.profilePhoto,
      'readReceipts': instance.readReceipts,
      'lastSeenExceptions': instance.lastSeenExceptions,
      'videosVisibility': instance.videosVisibility,
    };

_$SettingsResponseDataImpl _$$SettingsResponseDataImplFromJson(
        Map<String, dynamic> json) =>
    _$SettingsResponseDataImpl(
      notifications: NotificationsResponseData.fromJson(
          json['notifications'] as Map<String, dynamic>),
      commentFilters: CommentFiltersResponseData.fromJson(
          json['commentFilters'] as Map<String, dynamic>),
      allowScreenshots: json['allowScreenshots'] as bool? ?? true,
      chatWallpaper: json['chatWallpaper'] as String? ?? '',
      isAppLockEnabled: json['isAppLockEnabled'] as bool? ?? false,
      themeMode: json['themeMode'] as String? ?? 'system',
    );

Map<String, dynamic> _$$SettingsResponseDataImplToJson(
        _$SettingsResponseDataImpl instance) =>
    <String, dynamic>{
      'notifications': instance.notifications.toJson(),
      'commentFilters': instance.commentFilters.toJson(),
      'allowScreenshots': instance.allowScreenshots,
      'chatWallpaper': instance.chatWallpaper,
      'isAppLockEnabled': instance.isAppLockEnabled,
      'themeMode': instance.themeMode,
    };

_$NotificationsResponseDataImpl _$$NotificationsResponseDataImplFromJson(
        Map<String, dynamic> json) =>
    _$NotificationsResponseDataImpl(
      calls: json['calls'] as bool? ?? true,
      groups: json['groups'] as bool? ?? true,
      messages: json['messages'] as bool? ?? true,
      sound: json['sound'] as bool? ?? true,
      vibrate: json['vibrate'] as bool? ?? true,
    );

Map<String, dynamic> _$$NotificationsResponseDataImplToJson(
        _$NotificationsResponseDataImpl instance) =>
    <String, dynamic>{
      'calls': instance.calls,
      'groups': instance.groups,
      'messages': instance.messages,
      'sound': instance.sound,
      'vibrate': instance.vibrate,
    };

_$CommentFiltersResponseDataImpl _$$CommentFiltersResponseDataImplFromJson(
        Map<String, dynamic> json) =>
    _$CommentFiltersResponseDataImpl(
      filterOffensiveWords: json['filterOffensiveWords'] as bool? ?? true,
      filterSpam: json['filterSpam'] as bool? ?? false,
    );

Map<String, dynamic> _$$CommentFiltersResponseDataImplToJson(
        _$CommentFiltersResponseDataImpl instance) =>
    <String, dynamic>{
      'filterOffensiveWords': instance.filterOffensiveWords,
      'filterSpam': instance.filterSpam,
    };
