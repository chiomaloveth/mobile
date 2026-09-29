// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_other_info_response_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GetOtherInfoResponseDataImpl _$$GetOtherInfoResponseDataImplFromJson(
        Map<String, dynamic> json) =>
    _$GetOtherInfoResponseDataImpl(
      success: json['success'] as bool,
      data: GetOtherInfoResponseDataInner.fromJson(
          json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$GetOtherInfoResponseDataImplToJson(
        _$GetOtherInfoResponseDataImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'data': instance.data.toJson(),
    };

_$GetOtherInfoResponseDataInnerImpl
    _$$GetOtherInfoResponseDataInnerImplFromJson(Map<String, dynamic> json) =>
        _$GetOtherInfoResponseDataInnerImpl(
          id: json['_id'] as String,
          profilePicture: json['profilePicture'] as String?,
          username: json['username'] as String?,
          postsCount: (json['postsCount'] as num).toInt(),
          followersCount: (json['followersCount'] as num).toInt(),
          followingCount: (json['followingCount'] as num).toInt(),
          isFollowing: json['isFollowing'] as bool,
          followsYou: json['followsYou'] as bool,
          instagram: json['instagram'] as String?,
          youtube: json['youtube'] as String?,
          link: json['link'] as String?,
        );

Map<String, dynamic> _$$GetOtherInfoResponseDataInnerImplToJson(
    _$GetOtherInfoResponseDataInnerImpl instance) {
  final val = <String, dynamic>{
    '_id': instance.id,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('profilePicture', instance.profilePicture);
  writeNotNull('username', instance.username);
  val['postsCount'] = instance.postsCount;
  val['followersCount'] = instance.followersCount;
  val['followingCount'] = instance.followingCount;
  val['isFollowing'] = instance.isFollowing;
  val['followsYou'] = instance.followsYou;
  writeNotNull('instagram', instance.instagram);
  writeNotNull('youtube', instance.youtube);
  writeNotNull('link', instance.link);
  return val;
}
