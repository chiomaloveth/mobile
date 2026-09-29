// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'get_comment_response_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

GetCommentResponseData _$GetCommentResponseDataFromJson(
    Map<String, dynamic> json) {
  return _GetCommentResponseData.fromJson(json);
}

/// @nodoc
mixin _$GetCommentResponseData {
  @JsonKey(name: '_id')
  String? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user')
  MyUser? get user => throw _privateConstructorUsedError;
  @JsonKey(name: 'post')
  String? get post => throw _privateConstructorUsedError;
  @JsonKey(name: 'content')
  String? get content => throw _privateConstructorUsedError;
  @JsonKey(name: 'media')
  String? get media => throw _privateConstructorUsedError;
  @JsonKey(name: 'likes')
  List<String>? get likes => throw _privateConstructorUsedError;
  @JsonKey(name: 'parentComment')
  String? get parentComment => throw _privateConstructorUsedError;
  @JsonKey(name: 'type')
  String? get type => throw _privateConstructorUsedError;
  @JsonKey(name: 'createdAt')
  String? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updatedAt')
  String? get updatedAt => throw _privateConstructorUsedError;
  @JsonKey(name: '__v')
  int? get v => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GetCommentResponseDataCopyWith<GetCommentResponseData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GetCommentResponseDataCopyWith<$Res> {
  factory $GetCommentResponseDataCopyWith(GetCommentResponseData value,
          $Res Function(GetCommentResponseData) then) =
      _$GetCommentResponseDataCopyWithImpl<$Res, GetCommentResponseData>;
  @useResult
  $Res call(
      {@JsonKey(name: '_id') String? id,
      @JsonKey(name: 'user') MyUser? user,
      @JsonKey(name: 'post') String? post,
      @JsonKey(name: 'content') String? content,
      @JsonKey(name: 'media') String? media,
      @JsonKey(name: 'likes') List<String>? likes,
      @JsonKey(name: 'parentComment') String? parentComment,
      @JsonKey(name: 'type') String? type,
      @JsonKey(name: 'createdAt') String? createdAt,
      @JsonKey(name: 'updatedAt') String? updatedAt,
      @JsonKey(name: '__v') int? v});

  $MyUserCopyWith<$Res>? get user;
}

/// @nodoc
class _$GetCommentResponseDataCopyWithImpl<$Res,
        $Val extends GetCommentResponseData>
    implements $GetCommentResponseDataCopyWith<$Res> {
  _$GetCommentResponseDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? user = freezed,
    Object? post = freezed,
    Object? content = freezed,
    Object? media = freezed,
    Object? likes = freezed,
    Object? parentComment = freezed,
    Object? type = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? v = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      user: freezed == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as MyUser?,
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
              as List<String>?,
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
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $MyUserCopyWith<$Res>? get user {
    if (_value.user == null) {
      return null;
    }

    return $MyUserCopyWith<$Res>(_value.user!, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$GetCommentResponseDataImplCopyWith<$Res>
    implements $GetCommentResponseDataCopyWith<$Res> {
  factory _$$GetCommentResponseDataImplCopyWith(
          _$GetCommentResponseDataImpl value,
          $Res Function(_$GetCommentResponseDataImpl) then) =
      __$$GetCommentResponseDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: '_id') String? id,
      @JsonKey(name: 'user') MyUser? user,
      @JsonKey(name: 'post') String? post,
      @JsonKey(name: 'content') String? content,
      @JsonKey(name: 'media') String? media,
      @JsonKey(name: 'likes') List<String>? likes,
      @JsonKey(name: 'parentComment') String? parentComment,
      @JsonKey(name: 'type') String? type,
      @JsonKey(name: 'createdAt') String? createdAt,
      @JsonKey(name: 'updatedAt') String? updatedAt,
      @JsonKey(name: '__v') int? v});

  @override
  $MyUserCopyWith<$Res>? get user;
}

/// @nodoc
class __$$GetCommentResponseDataImplCopyWithImpl<$Res>
    extends _$GetCommentResponseDataCopyWithImpl<$Res,
        _$GetCommentResponseDataImpl>
    implements _$$GetCommentResponseDataImplCopyWith<$Res> {
  __$$GetCommentResponseDataImplCopyWithImpl(
      _$GetCommentResponseDataImpl _value,
      $Res Function(_$GetCommentResponseDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? user = freezed,
    Object? post = freezed,
    Object? content = freezed,
    Object? media = freezed,
    Object? likes = freezed,
    Object? parentComment = freezed,
    Object? type = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? v = freezed,
  }) {
    return _then(_$GetCommentResponseDataImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      user: freezed == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as MyUser?,
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
              as List<String>?,
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
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GetCommentResponseDataImpl implements _GetCommentResponseData {
  const _$GetCommentResponseDataImpl(
      {@JsonKey(name: '_id') this.id,
      @JsonKey(name: 'user') this.user,
      @JsonKey(name: 'post') this.post,
      @JsonKey(name: 'content') this.content,
      @JsonKey(name: 'media') this.media,
      @JsonKey(name: 'likes') final List<String>? likes,
      @JsonKey(name: 'parentComment') this.parentComment,
      @JsonKey(name: 'type') this.type,
      @JsonKey(name: 'createdAt') this.createdAt,
      @JsonKey(name: 'updatedAt') this.updatedAt,
      @JsonKey(name: '__v') this.v})
      : _likes = likes;

  factory _$GetCommentResponseDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$GetCommentResponseDataImplFromJson(json);

  @override
  @JsonKey(name: '_id')
  final String? id;
  @override
  @JsonKey(name: 'user')
  final MyUser? user;
  @override
  @JsonKey(name: 'post')
  final String? post;
  @override
  @JsonKey(name: 'content')
  final String? content;
  @override
  @JsonKey(name: 'media')
  final String? media;
  final List<String>? _likes;
  @override
  @JsonKey(name: 'likes')
  List<String>? get likes {
    final value = _likes;
    if (value == null) return null;
    if (_likes is EqualUnmodifiableListView) return _likes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'parentComment')
  final String? parentComment;
  @override
  @JsonKey(name: 'type')
  final String? type;
  @override
  @JsonKey(name: 'createdAt')
  final String? createdAt;
  @override
  @JsonKey(name: 'updatedAt')
  final String? updatedAt;
  @override
  @JsonKey(name: '__v')
  final int? v;

  @override
  String toString() {
    return 'GetCommentResponseData(id: $id, user: $user, post: $post, content: $content, media: $media, likes: $likes, parentComment: $parentComment, type: $type, createdAt: $createdAt, updatedAt: $updatedAt, v: $v)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GetCommentResponseDataImpl &&
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
            (identical(other.v, v) || other.v == v));
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
      v);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GetCommentResponseDataImplCopyWith<_$GetCommentResponseDataImpl>
      get copyWith => __$$GetCommentResponseDataImplCopyWithImpl<
          _$GetCommentResponseDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GetCommentResponseDataImplToJson(
      this,
    );
  }
}

abstract class _GetCommentResponseData implements GetCommentResponseData {
  const factory _GetCommentResponseData(
      {@JsonKey(name: '_id') final String? id,
      @JsonKey(name: 'user') final MyUser? user,
      @JsonKey(name: 'post') final String? post,
      @JsonKey(name: 'content') final String? content,
      @JsonKey(name: 'media') final String? media,
      @JsonKey(name: 'likes') final List<String>? likes,
      @JsonKey(name: 'parentComment') final String? parentComment,
      @JsonKey(name: 'type') final String? type,
      @JsonKey(name: 'createdAt') final String? createdAt,
      @JsonKey(name: 'updatedAt') final String? updatedAt,
      @JsonKey(name: '__v') final int? v}) = _$GetCommentResponseDataImpl;

  factory _GetCommentResponseData.fromJson(Map<String, dynamic> json) =
      _$GetCommentResponseDataImpl.fromJson;

  @override
  @JsonKey(name: '_id')
  String? get id;
  @override
  @JsonKey(name: 'user')
  MyUser? get user;
  @override
  @JsonKey(name: 'post')
  String? get post;
  @override
  @JsonKey(name: 'content')
  String? get content;
  @override
  @JsonKey(name: 'media')
  String? get media;
  @override
  @JsonKey(name: 'likes')
  List<String>? get likes;
  @override
  @JsonKey(name: 'parentComment')
  String? get parentComment;
  @override
  @JsonKey(name: 'type')
  String? get type;
  @override
  @JsonKey(name: 'createdAt')
  String? get createdAt;
  @override
  @JsonKey(name: 'updatedAt')
  String? get updatedAt;
  @override
  @JsonKey(name: '__v')
  int? get v;
  @override
  @JsonKey(ignore: true)
  _$$GetCommentResponseDataImplCopyWith<_$GetCommentResponseDataImpl>
      get copyWith => throw _privateConstructorUsedError;
}

MyUser _$MyUserFromJson(Map<String, dynamic> json) {
  return _MyUser.fromJson(json);
}

/// @nodoc
mixin _$MyUser {
  @JsonKey(name: '_id')
  String? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'profilePicture')
  String? get profilePicture => throw _privateConstructorUsedError;
  @JsonKey(name: 'username')
  String? get username => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MyUserCopyWith<MyUser> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MyUserCopyWith<$Res> {
  factory $MyUserCopyWith(MyUser value, $Res Function(MyUser) then) =
      _$MyUserCopyWithImpl<$Res, MyUser>;
  @useResult
  $Res call(
      {@JsonKey(name: '_id') String? id,
      @JsonKey(name: 'profilePicture') String? profilePicture,
      @JsonKey(name: 'username') String? username});
}

/// @nodoc
class _$MyUserCopyWithImpl<$Res, $Val extends MyUser>
    implements $MyUserCopyWith<$Res> {
  _$MyUserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? profilePicture = freezed,
    Object? username = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      profilePicture: freezed == profilePicture
          ? _value.profilePicture
          : profilePicture // ignore: cast_nullable_to_non_nullable
              as String?,
      username: freezed == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MyUserImplCopyWith<$Res> implements $MyUserCopyWith<$Res> {
  factory _$$MyUserImplCopyWith(
          _$MyUserImpl value, $Res Function(_$MyUserImpl) then) =
      __$$MyUserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: '_id') String? id,
      @JsonKey(name: 'profilePicture') String? profilePicture,
      @JsonKey(name: 'username') String? username});
}

/// @nodoc
class __$$MyUserImplCopyWithImpl<$Res>
    extends _$MyUserCopyWithImpl<$Res, _$MyUserImpl>
    implements _$$MyUserImplCopyWith<$Res> {
  __$$MyUserImplCopyWithImpl(
      _$MyUserImpl _value, $Res Function(_$MyUserImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? profilePicture = freezed,
    Object? username = freezed,
  }) {
    return _then(_$MyUserImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      profilePicture: freezed == profilePicture
          ? _value.profilePicture
          : profilePicture // ignore: cast_nullable_to_non_nullable
              as String?,
      username: freezed == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MyUserImpl implements _MyUser {
  const _$MyUserImpl(
      {@JsonKey(name: '_id') this.id,
      @JsonKey(name: 'profilePicture') this.profilePicture,
      @JsonKey(name: 'username') this.username});

  factory _$MyUserImpl.fromJson(Map<String, dynamic> json) =>
      _$$MyUserImplFromJson(json);

  @override
  @JsonKey(name: '_id')
  final String? id;
  @override
  @JsonKey(name: 'profilePicture')
  final String? profilePicture;
  @override
  @JsonKey(name: 'username')
  final String? username;

  @override
  String toString() {
    return 'MyUser(id: $id, profilePicture: $profilePicture, username: $username)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MyUserImpl &&
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
  _$$MyUserImplCopyWith<_$MyUserImpl> get copyWith =>
      __$$MyUserImplCopyWithImpl<_$MyUserImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MyUserImplToJson(
      this,
    );
  }
}

abstract class _MyUser implements MyUser {
  const factory _MyUser(
      {@JsonKey(name: '_id') final String? id,
      @JsonKey(name: 'profilePicture') final String? profilePicture,
      @JsonKey(name: 'username') final String? username}) = _$MyUserImpl;

  factory _MyUser.fromJson(Map<String, dynamic> json) = _$MyUserImpl.fromJson;

  @override
  @JsonKey(name: '_id')
  String? get id;
  @override
  @JsonKey(name: 'profilePicture')
  String? get profilePicture;
  @override
  @JsonKey(name: 'username')
  String? get username;
  @override
  @JsonKey(ignore: true)
  _$$MyUserImplCopyWith<_$MyUserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
