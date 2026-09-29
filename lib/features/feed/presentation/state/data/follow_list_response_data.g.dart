// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'follow_list_response_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FollowUserInfoImpl _$$FollowUserInfoImplFromJson(Map<String, dynamic> json) =>
    _$FollowUserInfoImpl(
      id: json['_id'] as String,
      username: json['username'] as String,
      profilePicture: json['profilePicture'] as String? ?? '',
    );

Map<String, dynamic> _$$FollowUserInfoImplToJson(
        _$FollowUserInfoImpl instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'username': instance.username,
      'profilePicture': instance.profilePicture,
    };

_$FollowerItemImpl _$$FollowerItemImplFromJson(Map<String, dynamic> json) =>
    _$FollowerItemImpl(
      id: json['_id'] as String,
      follower:
          FollowUserInfo.fromJson(json['follower'] as Map<String, dynamic>),
      following: json['following'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$FollowerItemImplToJson(_$FollowerItemImpl instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'follower': instance.follower.toJson(),
      'following': instance.following,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

_$GetFollowersResponseImpl _$$GetFollowersResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$GetFollowersResponseImpl(
      success: json['success'] as bool,
      count: (json['count'] as num).toInt(),
      data: (json['data'] as List<dynamic>)
          .map((e) => FollowerItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$GetFollowersResponseImplToJson(
        _$GetFollowersResponseImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'count': instance.count,
      'data': instance.data.map((e) => e.toJson()).toList(),
    };

_$FollowingItemImpl _$$FollowingItemImplFromJson(Map<String, dynamic> json) =>
    _$FollowingItemImpl(
      id: json['_id'] as String,
      follower: json['follower'] as String,
      following:
          FollowingUserInfo.fromJson(json['following'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$FollowingItemImplToJson(_$FollowingItemImpl instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'follower': instance.follower,
      'following': instance.following.toJson(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

_$FollowingUserInfoImpl _$$FollowingUserInfoImplFromJson(
        Map<String, dynamic> json) =>
    _$FollowingUserInfoImpl(
      id: json['_id'] as String,
      username: json['username'] as String,
      profilePicture: json['profilePicture'] as String? ?? '',
    );

Map<String, dynamic> _$$FollowingUserInfoImplToJson(
        _$FollowingUserInfoImpl instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'username': instance.username,
      'profilePicture': instance.profilePicture,
    };

_$GetFollowingResponseImpl _$$GetFollowingResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$GetFollowingResponseImpl(
      success: json['success'] as bool,
      count: (json['count'] as num).toInt(),
      data: (json['data'] as List<dynamic>)
          .map((e) => FollowingItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$GetFollowingResponseImplToJson(
        _$GetFollowingResponseImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'count': instance.count,
      'data': instance.data.map((e) => e.toJson()).toList(),
    };
