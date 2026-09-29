// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_created_response_feed_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GetCreatedResponseFeedDataImpl _$$GetCreatedResponseFeedDataImplFromJson(
        Map<String, dynamic> json) =>
    _$GetCreatedResponseFeedDataImpl(
      id: json['_id'] as String,
      user: json['user'] as String,
      content: json['content'] as String? ?? '',
      media:
          (json['media'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      likes:
          (json['likes'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      privacy: json['privacy'] as String? ?? 'everyone',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      v: (json['__v'] as num?)?.toInt(),
      commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$GetCreatedResponseFeedDataImplToJson(
    _$GetCreatedResponseFeedDataImpl instance) {
  final val = <String, dynamic>{
    '_id': instance.id,
    'user': instance.user,
    'content': instance.content,
    'media': instance.media,
    'likes': instance.likes,
    'privacy': instance.privacy,
    'createdAt': instance.createdAt.toIso8601String(),
    'updatedAt': instance.updatedAt.toIso8601String(),
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('__v', instance.v);
  val['commentCount'] = instance.commentCount;
  return val;
}
