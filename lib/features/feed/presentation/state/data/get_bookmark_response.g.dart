// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_bookmark_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GetBookmarkResponseImpl _$$GetBookmarkResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$GetBookmarkResponseImpl(
      success: json['success'] as bool,
      count: (json['count'] as num).toInt(),
      data: (json['data'] as List<dynamic>)
          .map((e) =>
              GetBookmarkResponseData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$GetBookmarkResponseImplToJson(
        _$GetBookmarkResponseImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'count': instance.count,
      'data': instance.data.map((e) => e.toJson()).toList(),
    };

_$GetBookmarkResponseDataImpl _$$GetBookmarkResponseDataImplFromJson(
        Map<String, dynamic> json) =>
    _$GetBookmarkResponseDataImpl(
      id: json['_id'] as String,
      user: MyUser.fromJson(json['user'] as Map<String, dynamic>),
      content: json['content'] as String? ?? '',
      media: json['media'] == null
          ? const []
          : _bookmarkMediaFromJson(json['media'] as List?),
      likes: json['likes'] as List<dynamic>? ?? const [],
      shares: json['shares'] as List<dynamic>? ?? const [],
      bookmarks: json['bookmarks'] as List<dynamic>? ?? const [],
      sharedFrom: json['sharedFrom'],
      privacy: json['privacy'] as String? ?? 'everyone',
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      v: (json['__v'] as num?)?.toInt(),
      commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
      bookMarkId: json['id'] as String?,
    );

Map<String, dynamic> _$$GetBookmarkResponseDataImplToJson(
    _$GetBookmarkResponseDataImpl instance) {
  final val = <String, dynamic>{
    '_id': instance.id,
    'user': instance.user.toJson(),
    'content': instance.content,
    'media': instance.media,
    'likes': instance.likes,
    'shares': instance.shares,
    'bookmarks': instance.bookmarks,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('sharedFrom', instance.sharedFrom);
  val['privacy'] = instance.privacy;
  val['createdAt'] = instance.createdAt;
  val['updatedAt'] = instance.updatedAt;
  writeNotNull('__v', instance.v);
  val['commentCount'] = instance.commentCount;
  writeNotNull('id', instance.bookMarkId);
  return val;
}
