// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'get_comment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

GetComment _$GetCommentFromJson(Map<String, dynamic> json) {
  return _GetComment.fromJson(json);
}

/// @nodoc
mixin _$GetComment {
  @JsonKey(name: '_id')
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user')
  CommentUser get user => throw _privateConstructorUsedError;
  @JsonKey(name: 'post')
  String get post => throw _privateConstructorUsedError;
  @JsonKey(name: 'content')
  String? get content => throw _privateConstructorUsedError;
  @JsonKey(name: 'media')
  String? get media => throw _privateConstructorUsedError;
  List<String> get likes => throw _privateConstructorUsedError;
  String? get parentComment => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String? get createdAt => throw _privateConstructorUsedError;
  String? get updatedAt => throw _privateConstructorUsedError;
  @JsonKey(name: '__v')
  int get v => throw _privateConstructorUsedError;
  List<GetComment> get replies =>
      throw _privateConstructorUsedError; // Some endpoints might return 'id' instead of '_id' or both
  @JsonKey(name: 'id')
  String? get commentId => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GetCommentCopyWith<GetComment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GetCommentCopyWith<$Res> {
  factory $GetCommentCopyWith(
          GetComment value, $Res Function(GetComment) then) =
      _$GetCommentCopyWithImpl<$Res, GetComment>;
  @useResult
  $Res call(
      {@JsonKey(name: '_id') String id,
      @JsonKey(name: 'user') CommentUser user,
      @JsonKey(name: 'post') String post,
      @JsonKey(name: 'content') String? content,
      @JsonKey(name: 'media') String? media,
      List<String> likes,
      String? parentComment,
      String type,
      String? createdAt,
      String? updatedAt,
      @JsonKey(name: '__v') int v,
      List<GetComment> replies,
      @JsonKey(name: 'id') String? commentId});

  $CommentUserCopyWith<$Res> get user;
}

/// @nodoc
class _$GetCommentCopyWithImpl<$Res, $Val extends GetComment>
    implements $GetCommentCopyWith<$Res> {
  _$GetCommentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? user = null,
    Object? post = null,
    Object? content = freezed,
    Object? media = freezed,
    Object? likes = null,
    Object? parentComment = freezed,
    Object? type = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? v = null,
    Object? replies = null,
    Object? commentId = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as CommentUser,
      post: null == post
          ? _value.post
          : post // ignore: cast_nullable_to_non_nullable
              as String,
      content: freezed == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String?,
      media: freezed == media
          ? _value.media
          : media // ignore: cast_nullable_to_non_nullable
              as String?,
      likes: null == likes
          ? _value.likes
          : likes // ignore: cast_nullable_to_non_nullable
              as List<String>,
      parentComment: freezed == parentComment
          ? _value.parentComment
          : parentComment // ignore: cast_nullable_to_non_nullable
              as String?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      v: null == v
          ? _value.v
          : v // ignore: cast_nullable_to_non_nullable
              as int,
      replies: null == replies
          ? _value.replies
          : replies // ignore: cast_nullable_to_non_nullable
              as List<GetComment>,
      commentId: freezed == commentId
          ? _value.commentId
          : commentId // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $CommentUserCopyWith<$Res> get user {
    return $CommentUserCopyWith<$Res>(_value.user, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$GetCommentImplCopyWith<$Res>
    implements $GetCommentCopyWith<$Res> {
  factory _$$GetCommentImplCopyWith(
          _$GetCommentImpl value, $Res Function(_$GetCommentImpl) then) =
      __$$GetCommentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: '_id') String id,
      @JsonKey(name: 'user') CommentUser user,
      @JsonKey(name: 'post') String post,
      @JsonKey(name: 'content') String? content,
      @JsonKey(name: 'media') String? media,
      List<String> likes,
      String? parentComment,
      String type,
      String? createdAt,
      String? updatedAt,
      @JsonKey(name: '__v') int v,
      List<GetComment> replies,
      @JsonKey(name: 'id') String? commentId});

  @override
  $CommentUserCopyWith<$Res> get user;
}

/// @nodoc
class __$$GetCommentImplCopyWithImpl<$Res>
    extends _$GetCommentCopyWithImpl<$Res, _$GetCommentImpl>
    implements _$$GetCommentImplCopyWith<$Res> {
  __$$GetCommentImplCopyWithImpl(
      _$GetCommentImpl _value, $Res Function(_$GetCommentImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? user = null,
    Object? post = null,
    Object? content = freezed,
    Object? media = freezed,
    Object? likes = null,
    Object? parentComment = freezed,
    Object? type = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? v = null,
    Object? replies = null,
    Object? commentId = freezed,
  }) {
    return _then(_$GetCommentImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as CommentUser,
      post: null == post
          ? _value.post
          : post // ignore: cast_nullable_to_non_nullable
              as String,
      content: freezed == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String?,
      media: freezed == media
          ? _value.media
          : media // ignore: cast_nullable_to_non_nullable
              as String?,
      likes: null == likes
          ? _value._likes
          : likes // ignore: cast_nullable_to_non_nullable
              as List<String>,
      parentComment: freezed == parentComment
          ? _value.parentComment
          : parentComment // ignore: cast_nullable_to_non_nullable
              as String?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      v: null == v
          ? _value.v
          : v // ignore: cast_nullable_to_non_nullable
              as int,
      replies: null == replies
          ? _value._replies
          : replies // ignore: cast_nullable_to_non_nullable
              as List<GetComment>,
      commentId: freezed == commentId
          ? _value.commentId
          : commentId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GetCommentImpl extends _GetComment {
  const _$GetCommentImpl(
      {@JsonKey(name: '_id') required this.id,
      @JsonKey(name: 'user') required this.user,
      @JsonKey(name: 'post') required this.post,
      @JsonKey(name: 'content') this.content,
      @JsonKey(name: 'media') this.media,
      final List<String> likes = const [],
      this.parentComment,
      this.type = 'text',
      this.createdAt,
      this.updatedAt,
      @JsonKey(name: '__v') this.v = 0,
      final List<GetComment> replies = const [],
      @JsonKey(name: 'id') this.commentId})
      : _likes = likes,
        _replies = replies,
        super._();

  factory _$GetCommentImpl.fromJson(Map<String, dynamic> json) =>
      _$$GetCommentImplFromJson(json);

  @override
  @JsonKey(name: '_id')
  final String id;
  @override
  @JsonKey(name: 'user')
  final CommentUser user;
  @override
  @JsonKey(name: 'post')
  final String post;
  @override
  @JsonKey(name: 'content')
  final String? content;
  @override
  @JsonKey(name: 'media')
  final String? media;
  final List<String> _likes;
  @override
  @JsonKey()
  List<String> get likes {
    if (_likes is EqualUnmodifiableListView) return _likes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_likes);
  }

  @override
  final String? parentComment;
  @override
  @JsonKey()
  final String type;
  @override
  final String? createdAt;
  @override
  final String? updatedAt;
  @override
  @JsonKey(name: '__v')
  final int v;
  final List<GetComment> _replies;
  @override
  @JsonKey()
  List<GetComment> get replies {
    if (_replies is EqualUnmodifiableListView) return _replies;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_replies);
  }

// Some endpoints might return 'id' instead of '_id' or both
  @override
  @JsonKey(name: 'id')
  final String? commentId;

  @override
  String toString() {
    return 'GetComment(id: $id, user: $user, post: $post, content: $content, media: $media, likes: $likes, parentComment: $parentComment, type: $type, createdAt: $createdAt, updatedAt: $updatedAt, v: $v, replies: $replies, commentId: $commentId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GetCommentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.post, post) || other.post == post) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.media, media) || other.media == media) &&
            const DeepCollectionEquality().equals(other._likes, _likes) &&
            (identical(other.parentComment, parentComment) ||
                other.parentComment == parentComment) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.v, v) || other.v == v) &&
            const DeepCollectionEquality().equals(other._replies, _replies) &&
            (identical(other.commentId, commentId) ||
                other.commentId == commentId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      user,
      post,
      content,
      media,
      const DeepCollectionEquality().hash(_likes),
      parentComment,
      type,
      createdAt,
      updatedAt,
      v,
      const DeepCollectionEquality().hash(_replies),
      commentId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GetCommentImplCopyWith<_$GetCommentImpl> get copyWith =>
      __$$GetCommentImplCopyWithImpl<_$GetCommentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GetCommentImplToJson(
      this,
    );
  }
}

abstract class _GetComment extends GetComment {
  const factory _GetComment(
      {@JsonKey(name: '_id') required final String id,
      @JsonKey(name: 'user') required final CommentUser user,
      @JsonKey(name: 'post') required final String post,
      @JsonKey(name: 'content') final String? content,
      @JsonKey(name: 'media') final String? media,
      final List<String> likes,
      final String? parentComment,
      final String type,
      final String? createdAt,
      final String? updatedAt,
      @JsonKey(name: '__v') final int v,
      final List<GetComment> replies,
      @JsonKey(name: 'id') final String? commentId}) = _$GetCommentImpl;
  const _GetComment._() : super._();

  factory _GetComment.fromJson(Map<String, dynamic> json) =
      _$GetCommentImpl.fromJson;

  @override
  @JsonKey(name: '_id')
  String get id;
  @override
  @JsonKey(name: 'user')
  CommentUser get user;
  @override
  @JsonKey(name: 'post')
  String get post;
  @override
  @JsonKey(name: 'content')
  String? get content;
  @override
  @JsonKey(name: 'media')
  String? get media;
  @override
  List<String> get likes;
  @override
  String? get parentComment;
  @override
  String get type;
  @override
  String? get createdAt;
  @override
  String? get updatedAt;
  @override
  @JsonKey(name: '__v')
  int get v;
  @override
  List<GetComment> get replies;
  @override // Some endpoints might return 'id' instead of '_id' or both
  @JsonKey(name: 'id')
  String? get commentId;
  @override
  @JsonKey(ignore: true)
  _$$GetCommentImplCopyWith<_$GetCommentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CommentUser _$CommentUserFromJson(Map<String, dynamic> json) {
  return _CommentUser.fromJson(json);
}

/// @nodoc
mixin _$CommentUser {
  @JsonKey(name: '_id')
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'profilePicture')
  String get profilePicture => throw _privateConstructorUsedError;
  @JsonKey(name: 'username')
  String get username => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CommentUserCopyWith<CommentUser> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommentUserCopyWith<$Res> {
  factory $CommentUserCopyWith(
          CommentUser value, $Res Function(CommentUser) then) =
      _$CommentUserCopyWithImpl<$Res, CommentUser>;
  @useResult
  $Res call(
      {@JsonKey(name: '_id') String id,
      @JsonKey(name: 'profilePicture') String profilePicture,
      @JsonKey(name: 'username') String username});
}

/// @nodoc
class _$CommentUserCopyWithImpl<$Res, $Val extends CommentUser>
    implements $CommentUserCopyWith<$Res> {
  _$CommentUserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? profilePicture = null,
    Object? username = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      profilePicture: null == profilePicture
          ? _value.profilePicture
          : profilePicture // ignore: cast_nullable_to_non_nullable
              as String,
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CommentUserImplCopyWith<$Res>
    implements $CommentUserCopyWith<$Res> {
  factory _$$CommentUserImplCopyWith(
          _$CommentUserImpl value, $Res Function(_$CommentUserImpl) then) =
      __$$CommentUserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: '_id') String id,
      @JsonKey(name: 'profilePicture') String profilePicture,
      @JsonKey(name: 'username') String username});
}

/// @nodoc
class __$$CommentUserImplCopyWithImpl<$Res>
    extends _$CommentUserCopyWithImpl<$Res, _$CommentUserImpl>
    implements _$$CommentUserImplCopyWith<$Res> {
  __$$CommentUserImplCopyWithImpl(
      _$CommentUserImpl _value, $Res Function(_$CommentUserImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? profilePicture = null,
    Object? username = null,
  }) {
    return _then(_$CommentUserImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      profilePicture: null == profilePicture
          ? _value.profilePicture
          : profilePicture // ignore: cast_nullable_to_non_nullable
              as String,
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CommentUserImpl implements _CommentUser {
  const _$CommentUserImpl(
      {@JsonKey(name: '_id') required this.id,
      @JsonKey(name: 'profilePicture') this.profilePicture = '',
      @JsonKey(name: 'username') this.username = 'Unknown'});

  factory _$CommentUserImpl.fromJson(Map<String, dynamic> json) =>
      _$$CommentUserImplFromJson(json);

  @override
  @JsonKey(name: '_id')
  final String id;
  @override
  @JsonKey(name: 'profilePicture')
  final String profilePicture;
  @override
  @JsonKey(name: 'username')
  final String username;

  @override
  String toString() {
    return 'CommentUser(id: $id, profilePicture: $profilePicture, username: $username)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommentUserImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.profilePicture, profilePicture) ||
                other.profilePicture == profilePicture) &&
            (identical(other.username, username) ||
                other.username == username));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, profilePicture, username);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CommentUserImplCopyWith<_$CommentUserImpl> get copyWith =>
      __$$CommentUserImplCopyWithImpl<_$CommentUserImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CommentUserImplToJson(
      this,
    );
  }
}

abstract class _CommentUser implements CommentUser {
  const factory _CommentUser(
      {@JsonKey(name: '_id') required final String id,
      @JsonKey(name: 'profilePicture') final String profilePicture,
      @JsonKey(name: 'username') final String username}) = _$CommentUserImpl;

  factory _CommentUser.fromJson(Map<String, dynamic> json) =
      _$CommentUserImpl.fromJson;

  @override
  @JsonKey(name: '_id')
  String get id;
  @override
  @JsonKey(name: 'profilePicture')
  String get profilePicture;
  @override
  @JsonKey(name: 'username')
  String get username;
  @override
  @JsonKey(ignore: true)
  _$$CommentUserImplCopyWith<_$CommentUserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
