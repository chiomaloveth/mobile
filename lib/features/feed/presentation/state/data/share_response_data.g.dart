// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'share_response_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ShareResponseDataImpl _$$ShareResponseDataImplFromJson(
        Map<String, dynamic> json) =>
    _$ShareResponseDataImpl(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: ShareData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$ShareResponseDataImplToJson(
        _$ShareResponseDataImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data.toJson(),
    };

_$ShareDataImpl _$$ShareDataImplFromJson(Map<String, dynamic> json) =>
    _$ShareDataImpl(
      id: json['_id'] as String,
      user: json['user'] as String,
      content: json['content'] as String,
      media: (json['media'] as List<dynamic>).map((e) => e as String).toList(),
      likes: (json['likes'] as List<dynamic>).map((e) => e as String).toList(),
      shares:
          (json['shares'] as List<dynamic>).map((e) => e as String).toList(),
      sharedFrom: json['sharedFrom'],
      privacy: json['privacy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      v: (json['__v'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$ShareDataImplToJson(_$ShareDataImpl instance) {
  final val = <String, dynamic>{
    '_id': instance.id,
    'user': instance.user,
    'content': instance.content,
    'media': instance.media,
    'likes': instance.likes,
    'shares': instance.shares,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('sharedFrom', instance.sharedFrom);
  val['privacy'] = instance.privacy;
  val['createdAt'] = instance.createdAt.toIso8601String();
  val['updatedAt'] = instance.updatedAt.toIso8601String();
  writeNotNull('__v', instance.v);
  return val;
}
