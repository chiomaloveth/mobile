// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_reply_comment_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CreateReplyCommentResponse _$CreateReplyCommentResponseFromJson(
    Map<String, dynamic> json) {
  return _CreateReplyCommentResponse.fromJson(json);
}

/// @nodoc
mixin _$CreateReplyCommentResponse {
  MyUser get user => throw _privateConstructorUsedError;
  String? get post => throw _privateConstructorUsedError;
  String? get content => throw _privateConstructorUsedError;
  String? get media => throw _privateConstructorUsedError;
  List<dynamic>? get likes => throw _privateConstructorUsedError;
  String? get parentComment => throw _privateConstructorUsedError;
  String? get type => throw _privateConstructorUsedError;
  @JsonKey(name: '_id')
  String? get id => throw _privateConstructorUsedError;
  String? get createdAt => throw _privateConstructorUsedError;
  String? get updatedAt => throw _privateConstructorUsedError;
  int? get v => throw _privateConstructorUsedError;
  @JsonKey(name: 'id')
  String? get commentReplyId => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CreateReplyCommentResponseCopyWith<CreateReplyCommentResponse>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateReplyCommentResponseCopyWith<$Res> {
  factory $CreateReplyCommentResponseCopyWith(CreateReplyCommentResponse value,
          $Res Function(CreateReplyCommentResponse) then) =
      _$CreateReplyCommentResponseCopyWithImpl<$Res,
          CreateReplyCommentResponse>;
  @useResult
  $Res call(
      {MyUser user,
      String? post,
      String? content,
      String? media,
      List<dynamic>? likes,
      String? parentComment,
      String? type,
      @JsonKey(name: '_id') String? id,
      String? createdAt,
      String? updatedAt,
      int? v,
      @JsonKey(name: 'id') String? commentReplyId});

  $MyUserCopyWith<$Res> get user;
}

/// @nodoc
class _$CreateReplyCommentResponseCopyWithImpl<$Res,
        $Val extends CreateReplyCommentResponse>
    implements $CreateReplyCommentResponseCopyWith<$Res> {
  _$CreateReplyCommentResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user = null,
    Object? post = freezed,
    Object? content = freezed,
    Object? media = freezed,
    Object? likes = freezed,
    Object? parentComment = freezed,
    Object? type = freezed,
    Object? id = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? v = freezed,
    Object? commentReplyId = freezed,
  }) {
    return _then(_value.copyWith(
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
              as String?,
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
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
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
      commentReplyId: freezed == commentReplyId
          ? _value.commentReplyId
          : commentReplyId // ignore: cast_nullable_to_non_nullable
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
abstract class _$$CreateReplyCommentResponseImplCopyWith<$Res>
    implements $CreateReplyCommentResponseCopyWith<$Res> {
  factory _$$CreateReplyCommentResponseImplCopyWith(
          _$CreateReplyCommentResponseImpl value,
          $Res Function(_$CreateReplyCommentResponseImpl) then) =
      __$$CreateReplyCommentResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {MyUser user,
      String? post,
      String? content,
      String? media,
      List<dynamic>? likes,
      String? parentComment,
      String? type,
      @JsonKey(name: '_id') String? id,
      String? createdAt,
      String? updatedAt,
      int? v,
      @JsonKey(name: 'id') String? commentReplyId});

  @override
  $MyUserCopyWith<$Res> get user;
}

/// @nodoc
class __$$CreateReplyCommentResponseImplCopyWithImpl<$Res>
    extends _$CreateReplyCommentResponseCopyWithImpl<$Res,
        _$CreateReplyCommentResponseImpl>
    implements _$$CreateReplyCommentResponseImplCopyWith<$Res> {
  __$$CreateReplyCommentResponseImplCopyWithImpl(
      _$CreateReplyCommentResponseImpl _value,
      $Res Function(_$CreateReplyCommentResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user = null,
    Object? post = freezed,
    Object? content = freezed,
    Object? media = freezed,
    Object? likes = freezed,
    Object? parentComment = freezed,
    Object? type = freezed,
    Object? id = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? v = freezed,
    Object? commentReplyId = freezed,
  }) {
    return _then(_$CreateReplyCommentResponseImpl(
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
              as String?,
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
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
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
      commentReplyId: freezed == commentReplyId
          ? _value.commentReplyId
          : commentReplyId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateReplyCommentResponseImpl implements _CreateReplyCommentResponse {
  const _$CreateReplyCommentResponseImpl(
      {required this.user,
      this.post,
      this.content,
      this.media,
      final List<dynamic>? likes,
      this.parentComment,
      this.type,
      @JsonKey(name: '_id') this.id,
      this.createdAt,
      this.updatedAt,
      this.v,
      @JsonKey(name: 'id') this.commentReplyId})
      : _likes = likes;

  factory _$CreateReplyCommentResponseImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$CreateReplyCommentResponseImplFromJson(json);

  @override
  final MyUser user;
  @override
  final String? post;
  @override
  final String? content;
  @override
  final String? media;
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
  @JsonKey(name: '_id')
  final String? id;
  @override
  final String? createdAt;
  @override
  final String? updatedAt;
  @override
  final int? v;
  @override
  @JsonKey(name: 'id')
  final String? commentReplyId;

  @override
  String toString() {
    return 'CreateReplyCommentResponse(user: $user, post: $post, content: $content, media: $media, likes: $likes, parentComment: $parentComment, type: $type, id: $id, createdAt: $createdAt, updatedAt: $updatedAt, v: $v, commentReplyId: $commentReplyId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateReplyCommentResponseImpl &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.post, post) || other.post == post) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.media, media) || other.media == media) &&
            const DeepCollectionEquality().equals(other._likes, _likes) &&
            (identical(other.parentComment, parentComment) ||
                other.parentComment == parentComment) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.v, v) || other.v == v) &&
            (identical(other.commentReplyId, commentReplyId) ||
                other.commentReplyId == commentReplyId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      user,
      post,
      content,
      media,
      const DeepCollectionEquality().hash(_likes),
      parentComment,
      type,
      id,
      createdAt,
      updatedAt,
      v,
      commentReplyId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateReplyCommentResponseImplCopyWith<_$CreateReplyCommentResponseImpl>
      get copyWith => __$$CreateReplyCommentResponseImplCopyWithImpl<
          _$CreateReplyCommentResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateReplyCommentResponseImplToJson(
      this,
    );
  }
}

abstract class _CreateReplyCommentResponse
    implements CreateReplyCommentResponse {
  const factory _CreateReplyCommentResponse(
          {required final MyUser user,
          final String? post,
          final String? content,
          final String? media,
          final List<dynamic>? likes,
          final String? parentComment,
          final String? type,
          @JsonKey(name: '_id') final String? id,
          final String? createdAt,
          final String? updatedAt,
          final int? v,
          @JsonKey(name: 'id') final String? commentReplyId}) =
      _$CreateReplyCommentResponseImpl;

  factory _CreateReplyCommentResponse.fromJson(Map<String, dynamic> json) =
      _$CreateReplyCommentResponseImpl.fromJson;

  @override
  MyUser get user;
  @override
  String? get post;
  @override
  String? get content;
  @override
  String? get media;
  @override
  List<dynamic>? get likes;
  @override
  String? get parentComment;
  @override
  String? get type;
  @override
  @JsonKey(name: '_id')
  String? get id;
  @override
  String? get createdAt;
  @override
  String? get updatedAt;
  @override
  int? get v;
  @override
  @JsonKey(name: 'id')
  String? get commentReplyId;
  @override
  @JsonKey(ignore: true)
  _$$CreateReplyCommentResponseImplCopyWith<_$CreateReplyCommentResponseImpl>
      get copyWith => throw _privateConstructorUsedError;
}
