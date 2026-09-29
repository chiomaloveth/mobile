// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FeedUserImpl _$$FeedUserImplFromJson(Map<String, dynamic> json) =>
    _$FeedUserImpl(
      id: json['_id'] as String,
      profilePicture: json['profilePicture'] as String? ?? '',
      username: json['username'] as String? ?? '',
    );

Map<String, dynamic> _$$FeedUserImplToJson(_$FeedUserImpl instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'profilePicture': instance.profilePicture,
      'username': instance.username,
    };
