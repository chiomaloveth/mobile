// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'get_comment_reply.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

GetCommentReply _$GetCommentReplyFromJson(Map<String, dynamic> json) {
  return _GetCommentReply.fromJson(json);
}

/// @nodoc
mixin _$GetCommentReply {
  bool get success => throw _privateConstructorUsedError;
  int get count => throw _privateConstructorUsedError;
  List<GetCommentReplyData> get data => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GetCommentReplyCopyWith<GetCommentReply> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GetCommentReplyCopyWith<$Res> {
  factory $GetCommentReplyCopyWith(
          GetCommentReply value, $Res Function(GetCommentReply) then) =
      _$GetCommentReplyCopyWithImpl<$Res, GetCommentReply>;
  @useResult
  $Res call({bool success, int count, List<GetCommentReplyData> data});
}

/// @nodoc
class _$GetCommentReplyCopyWithImpl<$Res, $Val extends GetCommentReply>
    implements $GetCommentReplyCopyWith<$Res> {
  _$GetCommentReplyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? count = null,
    Object? data = null,
  }) {
    return _then(_value.copyWith(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      count: null == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as List<GetCommentReplyData>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GetCommentReplyImplCopyWith<$Res>
    implements $GetCommentReplyCopyWith<$Res> {
  factory _$$GetCommentReplyImplCopyWith(_$GetCommentReplyImpl value,
          $Res Function(_$GetCommentReplyImpl) then) =
      __$$GetCommentReplyImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool success, int count, List<GetCommentReplyData> data});
}

/// @nodoc
class __$$GetCommentReplyImplCopyWithImpl<$Res>
    extends _$GetCommentReplyCopyWithImpl<$Res, _$GetCommentReplyImpl>
    implements _$$GetCommentReplyImplCopyWith<$Res> {
  __$$GetCommentReplyImplCopyWithImpl(
      _$GetCommentReplyImpl _value, $Res Function(_$GetCommentReplyImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? count = null,
    Object? data = null,
  }) {
    return _then(_$GetCommentReplyImpl(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      count: null == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
      data: null == data
          ? _value._data
          : data // ignore: cast_nullable_to_non_nullable
              as List<GetCommentReplyData>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GetCommentReplyImpl implements _GetCommentReply {
  const _$GetCommentReplyImpl(
      {required this.success,
      required this.count,
      required final List<GetCommentReplyData> data})
      : _data = data;

  factory _$GetCommentReplyImpl.fromJson(Map<String, dynamic> json) =>
      _$$GetCommentReplyImplFromJson(json);

  @override
  final bool success;
  @override
  final int count;
  final List<GetCommentReplyData> _data;
  @override
  List<GetCommentReplyData> get data {
    if (_data is EqualUnmodifiableListView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_data);
  }

  @override
  String toString() {
    return 'GetCommentReply(success: $success, count: $count, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GetCommentReplyImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.count, count) || other.count == count) &&
            const DeepCollectionEquality().equals(other._data, _data));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, success, count, const DeepCollectionEquality().hash(_data));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GetCommentReplyImplCopyWith<_$GetCommentReplyImpl> get copyWith =>
      __$$GetCommentReplyImplCopyWithImpl<_$GetCommentReplyImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GetCommentReplyImplToJson(
      this,
    );
  }
}

abstract class _GetCommentReply implements GetCommentReply {
  const factory _GetCommentReply(
      {required final bool success,
      required final int count,
      required final List<GetCommentReplyData> data}) = _$GetCommentReplyImpl;

  factory _GetCommentReply.fromJson(Map<String, dynamic> json) =
      _$GetCommentReplyImpl.fromJson;

  @override
  bool get success;
  @override
  int get count;
  @override
  List<GetCommentReplyData> get data;
  @override
  @JsonKey(ignore: true)
  _$$GetCommentReplyImplCopyWith<_$GetCommentReplyImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GetCommentReplyData _$GetCommentReplyDataFromJson(Map<String, dynamic> json) {
  return _GetCommentReplyData.fromJson(json);
}

/// @nodoc
mixin _$GetCommentReplyData {
  @JsonKey(name: '_id')
  String get id => throw _privateConstructorUsedError;
  MyUser get user => throw _privateConstructorUsedError;
  String? get post => throw _privateConstructorUsedError;
  String? get content => throw _privateConstructorUsedError;
  List<dynamic>? get media => throw _privateConstructorUsedError;
  List<dynamic>? get likes => throw _privateConstructorUsedError;
  String? get parentComment => throw _privateConstructorUsedError;
  String? get type => throw _privateConstructorUsedError;
  String? get createdAt => throw _privateConstructorUsedError;
  String? get updatedAt => throw _privateConstructorUsedError;
  int? get v => throw _privateConstructorUsedError;
  @JsonKey(name: 'id')
  String? get replyId => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GetCommentReplyDataCopyWith<GetCommentReplyData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GetCommentReplyDataCopyWith<$Res> {
  factory $GetCommentReplyDataCopyWith(
          GetCommentReplyData value, $Res Function(GetCommentReplyData) then) =
      _$GetCommentReplyDataCopyWithImpl<$Res, GetCommentReplyData>;
  @useResult
  $Res call(
      {@JsonKey(name: '_id') String id,
      MyUser user,
      String? post,
      String? content,
      List<dynamic>? media,
      List<dynamic>? likes,
      String? parentComment,
      String? type,
      String? createdAt,
      String? updatedAt,
      int? v,
      @JsonKey(name: 'id') String? replyId});

  $MyUserCopyWith<$Res> get user;
}

/// @nodoc
class _$GetCommentReplyDataCopyWithImpl<$Res, $Val extends GetCommentReplyData>
    implements $GetCommentReplyDataCopyWith<$Res> {
  _$GetCommentReplyDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? user = null,
    Object? post = freezed,
    Object? content = freezed,
    Object? media = freezed,
    Object? likes = freezed,
    Object? parentComment = freezed,
    Object? type = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? v = freezed,
    Object? replyId = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as MyUser,
      post: freezed == post
          ? _value.post
          : post // ignore: cast_nullable_to_non_nullable
              as String?,
      content: freezed == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String?,
      media: freezed == media
          ? _value.media
          : media // ignore: cast_nullable_to_non_nullable
              as List<dynamic>?,
      likes: freezed == likes
          ? _value.likes
          : likes // ignore: cast_nullable_to_non_nullable
              as List<dynamic>?,
      parentComment: freezed == parentComment
          ? _value.parentComment
          : parentComment // ignore: cast_nullable_to_non_nullable
              as String?,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      v: freezed == v
          ? _value.v
          : v // ignore: cast_nullable_to_non_nullable
              as int?,
      replyId: freezed == replyId
          ? _value.replyId
          : replyId // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $MyUserCopyWith<$Res> get user {
    return $MyUserCopyWith<$Res>(_value.user, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$GetCommentReplyDataImplCopyWith<$Res>
    implements $GetCommentReplyDataCopyWith<$Res> {
  factory _$$GetCommentReplyDataImplCopyWith(_$GetCommentReplyDataImpl value,
          $Res Function(_$GetCommentReplyDataImpl) then) =
      __$$GetCommentReplyDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: '_id') String id,
      MyUser user,
      String? post,
      String? content,
      List<dynamic>? media,
      List<dynamic>? likes,
      String? parentComment,
      String? type,
      String? createdAt,
      String? updatedAt,
      int? v,
      @JsonKey(name: 'id') String? replyId});

  @override
  $MyUserCopyWith<$Res> get user;
}

/// @nodoc
class __$$GetCommentReplyDataImplCopyWithImpl<$Res>
    extends _$GetCommentReplyDataCopyWithImpl<$Res, _$GetCommentReplyDataImpl>
    implements _$$GetCommentReplyDataImplCopyWith<$Res> {
  __$$GetCommentReplyDataImplCopyWithImpl(_$GetCommentReplyDataImpl _value,
      $Res Function(_$GetCommentReplyDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? user = null,
    Object? post = freezed,
    Object? content = freezed,
    Object? media = freezed,
    Object? likes = freezed,
    Object? parentComment = freezed,
    Object? type = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? v = freezed,
    Object? replyId = freezed,
  }) {
    return _then(_$GetCommentReplyDataImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as MyUser,
      post: freezed == post
          ? _value.post
          : post // ignore: cast_nullable_to_non_nullable
              as String?,
      content: freezed == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String?,
      media: freezed == media
          ? _value._media
          : media // ignore: cast_nullable_to_non_nullable
              as List<dynamic>?,
      likes: freezed == likes
          ? _value._likes
          : likes // ignore: cast_nullable_to_non_nullable
              as List<dynamic>?,
      parentComment: freezed == parentComment
          ? _value.parentComment
          : parentComment // ignore: cast_nullable_to_non_nullable
              as String?,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      v: freezed == v
          ? _value.v
          : v // ignore: cast_nullable_to_non_nullable
              as int?,
      replyId: freezed == replyId
          ? _value.replyId
          : replyId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GetCommentReplyDataImpl implements _GetCommentReplyData {
  const _$GetCommentReplyDataImpl(
      {@JsonKey(name: '_id') required this.id,
      required this.user,
      this.post,
      this.content,
      final List<dynamic>? media,
      final List<dynamic>? likes,
      this.parentComment,
      this.type,
      this.createdAt,
      this.updatedAt,
      this.v,
      @JsonKey(name: 'id') this.replyId})
      : _media = media,
        _likes = likes;

  factory _$GetCommentReplyDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$GetCommentReplyDataImplFromJson(json);

  @override
  @JsonKey(name: '_id')
  final String id;
  @override
  final MyUser user;
  @override
  final String? post;
  @override
  final String? content;
  final List<dynamic>? _media;
  @override
  List<dynamic>? get media {
    final value = _media;
    if (value == null) return null;
    if (_media is EqualUnmodifiableListView) return _media;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<dynamic>? _likes;
  @override
  List<dynamic>? get likes {
    final value = _likes;
    if (value == null) return null;
    if (_likes is EqualUnmodifiableListView) return _likes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? parentComment;
  @override
  final String? type;
  @override
  final String? createdAt;
  @override
  final String? updatedAt;
  @override
  final int? v;
  @override
  @JsonKey(name: 'id')
  final String? replyId;

  @override
  String toString() {
    return 'GetCommentReplyData(id: $id, user: $user, post: $post, content: $content, media: $media, likes: $likes, parentComment: $parentComment, type: $type, createdAt: $createdAt, updatedAt: $updatedAt, v: $v, replyId: $replyId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GetCommentReplyDataImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.post, post) || other.post == post) &&
            (identical(other.content, content) || other.content == content) &&
            const DeepCollectionEquality().equals(other._media, _media) &&
            const DeepCollectionEquality().equals(other._likes, _likes) &&
            (identical(other.parentComment, parentComment) ||
                other.parentComment == parentComment) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.v, v) || other.v == v) &&
            (identical(other.replyId, replyId) || other.replyId == replyId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      user,
      post,
      content,
      const DeepCollectionEquality().hash(_media),
      const DeepCollectionEquality().hash(_likes),
      parentComment,
      type,
      createdAt,
      updatedAt,
      v,
      replyId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GetCommentReplyDataImplCopyWith<_$GetCommentReplyDataImpl> get copyWith =>
      __$$GetCommentReplyDataImplCopyWithImpl<_$GetCommentReplyDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GetCommentReplyDataImplToJson(
      this,
    );
  }
}

abstract class _GetCommentReplyData implements GetCommentReplyData {
  const factory _GetCommentReplyData(
      {@JsonKey(name: '_id') required final String id,
      required final MyUser user,
      final String? post,
      final String? content,
      final List<dynamic>? media,
      final List<dynamic>? likes,
      final String? parentComment,
      final String? type,
      final String? createdAt,
      final String? updatedAt,
      final int? v,
      @JsonKey(name: 'id') final String? replyId}) = _$GetCommentReplyDataImpl;

  factory _GetCommentReplyData.fromJson(Map<String, dynamic> json) =
      _$GetCommentReplyDataImpl.fromJson;

  @override
  @JsonKey(name: '_id')
  String get id;
  @override
  MyUser get user;
  @override
  String? get post;
  @override
  String? get content;
  @override
  List<dynamic>? get media;
  @override
  List<dynamic>? get likes;
  @override
  String? get parentComment;
  @override
  String? get type;
  @override
  String? get createdAt;
  @override
  String? get updatedAt;
  @override
  int? get v;
  @override
  @JsonKey(name: 'id')
  String? get replyId;
  @override
  @JsonKey(ignore: true)
  _$$GetCommentReplyDataImplCopyWith<_$GetCommentReplyDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
