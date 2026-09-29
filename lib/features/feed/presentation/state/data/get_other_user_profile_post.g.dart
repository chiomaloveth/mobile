// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_other_user_profile_post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GetOtherUserProfilePostImpl _$$GetOtherUserProfilePostImplFromJson(
        Map<String, dynamic> json) =>
    _$GetOtherUserProfilePostImpl(
      success: json['success'] as bool,
      data: (json['data'] as List<dynamic>)
          .map((e) =>
              GetOtherUserProfilePostData.fromJson(e as Map<String, dynamic>))
          .toList(),
      page: (json['page'] as num).toInt(),
      pageSize: (json['pageSize'] as num).toInt(),
      totalPosts: (json['totalPosts'] as num?)?.toInt() ?? 0,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$GetOtherUserProfilePostImplToJson(
        _$GetOtherUserProfilePostImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'data': instance.data.map((e) => e.toJson()).toList(),
      'page': instance.page,
      'pageSize': instance.pageSize,
      'totalPosts': instance.totalPosts,
      'totalPages': instance.totalPages,
    };

_$GetOtherUserProfilePostDataImpl _$$GetOtherUserProfilePostDataImplFromJson(
        Map<String, dynamic> json) =>
    _$GetOtherUserProfilePostDataImpl(
      id: json['_id'] as String,
      user: MyUser.fromJson(json['user'] as Map<String, dynamic>),
      content: json['content'] as String?,
      media: (json['media'] as List<dynamic>?)
              ?.map((e) => e as String?)
              .toList() ??
          const [],
      likes:
          (json['likes'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      shares: (json['shares'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      bookmarks: (json['bookmarks'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String?).toList() ??
              const [],
      sharedFrom: json['sharedFrom'] as String?,
      privacy: json['privacy'] as String,
      views: (json['views'] as num?)?.toInt() ?? 0,
      commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      allowComment: json['allowComment'] as bool? ?? true,
    );

Map<String, dynamic> _$$GetOtherUserProfilePostDataImplToJson(
    _$GetOtherUserProfilePostDataImpl instance) {
  final val = <String, dynamic>{
    '_id': instance.id,
    'user': instance.user.toJson(),
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('content', instance.content);
  val['media'] = instance.media;
  val['likes'] = instance.likes;
  val['shares'] = instance.shares;
  val['bookmarks'] = instance.bookmarks;
  val['tags'] = instance.tags;
  writeNotNull('sharedFrom', instance.sharedFrom);
  val['privacy'] = instance.privacy;
  val['views'] = instance.views;
  val['commentCount'] = instance.commentCount;
  val['createdAt'] = instance.createdAt.toIso8601String();
  val['updatedAt'] = instance.updatedAt.toIso8601String();
  val['allowComment'] = instance.allowComment;
  return val;
}
