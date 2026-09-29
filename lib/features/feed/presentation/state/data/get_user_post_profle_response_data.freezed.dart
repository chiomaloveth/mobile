// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'get_user_post_profle_response_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

GetUserPostProfleResponseData _$GetUserPostProfleResponseDataFromJson(
    Map<String, dynamic> json) {
  return _GetUserPostProfleResponseData.fromJson(json);
}

/// @nodoc
mixin _$GetUserPostProfleResponseData {
  @JsonKey(name: '_id')
  String get id => throw _privateConstructorUsedError;
  MyUser get user => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _mediaFromJson)
  List<String> get media => throw _privateConstructorUsedError;
  List<String> get likes => throw _privateConstructorUsedError;
  List<String> get shares => throw _privateConstructorUsedError;
  int get views => throw _privateConstructorUsedError;
  dynamic get sharedFrom => throw _privateConstructorUsedError;
  Music? get music => throw _privateConstructorUsedError;
  String get privacy => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;
  String get updatedAt => throw _privateConstructorUsedError;
  @JsonKey(name: '__v')
  int? get v => throw _privateConstructorUsedError;
  @JsonKey(name: 'commentCount')
  int get commentCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'id')
  String get userPostId => throw _privateConstructorUsedError;
  bool get allowComment => throw _privateConstructorUsedError;
  List<dynamic> get bookmarks => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GetUserPostProfleResponseDataCopyWith<GetUserPostProfleResponseData>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GetUserPostProfleResponseDataCopyWith<$Res> {
  factory $GetUserPostProfleResponseDataCopyWith(
          GetUserPostProfleResponseData value,
          $Res Function(GetUserPostProfleResponseData) then) =
      _$GetUserPostProfleResponseDataCopyWithImpl<$Res,
          GetUserPostProfleResponseData>;
  @useResult
  $Res call(
      {@JsonKey(name: '_id') String id,
      MyUser user,
      String content,
      @JsonKey(fromJson: _mediaFromJson) List<String> media,
      List<String> likes,
      List<String> shares,
      int views,
      dynamic sharedFrom,
      Music? music,
      String privacy,
      String createdAt,
      String updatedAt,
      @JsonKey(name: '__v') int? v,
      @JsonKey(name: 'commentCount') int commentCount,
      @JsonKey(name: 'id') String userPostId,
      bool allowComment,
      List<dynamic> bookmarks});

  $MyUserCopyWith<$Res> get user;
  $MusicCopyWith<$Res>? get music;
}

/// @nodoc
class _$GetUserPostProfleResponseDataCopyWithImpl<$Res,
        $Val extends GetUserPostProfleResponseData>
    implements $GetUserPostProfleResponseDataCopyWith<$Res> {
  _$GetUserPostProfleResponseDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? user = null,
    Object? content = null,
    Object? media = null,
    Object? likes = null,
    Object? shares = null,
    Object? views = null,
    Object? sharedFrom = freezed,
    Object? music = freezed,
    Object? privacy = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? v = freezed,
    Object? commentCount = null,
    Object? userPostId = null,
    Object? allowComment = null,
    Object? bookmarks = null,
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
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      media: null == media
          ? _value.media
          : media // ignore: cast_nullable_to_non_nullable
              as List<String>,
      likes: null == likes
          ? _value.likes
          : likes // ignore: cast_nullable_to_non_nullable
              as List<String>,
      shares: null == shares
          ? _value.shares
          : shares // ignore: cast_nullable_to_non_nullable
              as List<String>,
      views: null == views
          ? _value.views
          : views // ignore: cast_nullable_to_non_nullable
              as int,
      sharedFrom: freezed == sharedFrom
          ? _value.sharedFrom
          : sharedFrom // ignore: cast_nullable_to_non_nullable
              as dynamic,
      music: freezed == music
          ? _value.music
          : music // ignore: cast_nullable_to_non_nullable
              as Music?,
      privacy: null == privacy
          ? _value.privacy
          : privacy // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String,
      v: freezed == v
          ? _value.v
          : v // ignore: cast_nullable_to_non_nullable
              as int?,
      commentCount: null == commentCount
          ? _value.commentCount
          : commentCount // ignore: cast_nullable_to_non_nullable
              as int,
      userPostId: null == userPostId
          ? _value.userPostId
          : userPostId // ignore: cast_nullable_to_non_nullable
              as String,
      allowComment: null == allowComment
          ? _value.allowComment
          : allowComment // ignore: cast_nullable_to_non_nullable
              as bool,
      bookmarks: null == bookmarks
          ? _value.bookmarks
          : bookmarks // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $MyUserCopyWith<$Res> get user {
    return $MyUserCopyWith<$Res>(_value.user, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $MusicCopyWith<$Res>? get music {
    if (_value.music == null) {
      return null;
    }

    return $MusicCopyWith<$Res>(_value.music!, (value) {
      return _then(_value.copyWith(music: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$GetUserPostProfleResponseDataImplCopyWith<$Res>
    implements $GetUserPostProfleResponseDataCopyWith<$Res> {
  factory _$$GetUserPostProfleResponseDataImplCopyWith(
          _$GetUserPostProfleResponseDataImpl value,
          $Res Function(_$GetUserPostProfleResponseDataImpl) then) =
      __$$GetUserPostProfleResponseDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: '_id') String id,
      MyUser user,
      String content,
      @JsonKey(fromJson: _mediaFromJson) List<String> media,
      List<String> likes,
      List<String> shares,
      int views,
      dynamic sharedFrom,
      Music? music,
      String privacy,
      String createdAt,
      String updatedAt,
      @JsonKey(name: '__v') int? v,
      @JsonKey(name: 'commentCount') int commentCount,
      @JsonKey(name: 'id') String userPostId,
      bool allowComment,
      List<dynamic> bookmarks});

  @override
  $MyUserCopyWith<$Res> get user;
  @override
  $MusicCopyWith<$Res>? get music;
}

/// @nodoc
class __$$GetUserPostProfleResponseDataImplCopyWithImpl<$Res>
    extends _$GetUserPostProfleResponseDataCopyWithImpl<$Res,
        _$GetUserPostProfleResponseDataImpl>
    implements _$$GetUserPostProfleResponseDataImplCopyWith<$Res> {
  __$$GetUserPostProfleResponseDataImplCopyWithImpl(
      _$GetUserPostProfleResponseDataImpl _value,
      $Res Function(_$GetUserPostProfleResponseDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? user = null,
    Object? content = null,
    Object? media = null,
    Object? likes = null,
    Object? shares = null,
    Object? views = null,
    Object? sharedFrom = freezed,
    Object? music = freezed,
    Object? privacy = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? v = freezed,
    Object? commentCount = null,
    Object? userPostId = null,
    Object? allowComment = null,
    Object? bookmarks = null,
  }) {
    return _then(_$GetUserPostProfleResponseDataImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as MyUser,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      media: null == media
          ? _value._media
          : media // ignore: cast_nullable_to_non_nullable
              as List<String>,
      likes: null == likes
          ? _value._likes
          : likes // ignore: cast_nullable_to_non_nullable
              as List<String>,
      shares: null == shares
          ? _value._shares
          : shares // ignore: cast_nullable_to_non_nullable
              as List<String>,
      views: null == views
          ? _value.views
          : views // ignore: cast_nullable_to_non_nullable
              as int,
      sharedFrom: freezed == sharedFrom
          ? _value.sharedFrom
          : sharedFrom // ignore: cast_nullable_to_non_nullable
              as dynamic,
      music: freezed == music
          ? _value.music
          : music // ignore: cast_nullable_to_non_nullable
              as Music?,
      privacy: null == privacy
          ? _value.privacy
          : privacy // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String,
      v: freezed == v
          ? _value.v
          : v // ignore: cast_nullable_to_non_nullable
              as int?,
      commentCount: null == commentCount
          ? _value.commentCount
          : commentCount // ignore: cast_nullable_to_non_nullable
              as int,
      userPostId: null == userPostId
          ? _value.userPostId
          : userPostId // ignore: cast_nullable_to_non_nullable
              as String,
      allowComment: null == allowComment
          ? _value.allowComment
          : allowComment // ignore: cast_nullable_to_non_nullable
              as bool,
      bookmarks: null == bookmarks
          ? _value._bookmarks
          : bookmarks // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GetUserPostProfleResponseDataImpl
    implements _GetUserPostProfleResponseData {
  const _$GetUserPostProfleResponseDataImpl(
      {@JsonKey(name: '_id') required this.id,
      required this.user,
      this.content = '',
      @JsonKey(fromJson: _mediaFromJson) final List<String> media = const [],
      final List<String> likes = const [],
      final List<String> shares = const [],
      this.views = 0,
      this.sharedFrom,
      this.music,
      this.privacy = 'everyone',
      required this.createdAt,
      required this.updatedAt,
      @JsonKey(name: '__v') this.v,
      @JsonKey(name: 'commentCount') this.commentCount = 0,
      @JsonKey(name: 'id') required this.userPostId,
      this.allowComment = true,
      final List<dynamic> bookmarks = const []})
      : _media = media,
        _likes = likes,
        _shares = shares,
        _bookmarks = bookmarks;

  factory _$GetUserPostProfleResponseDataImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$GetUserPostProfleResponseDataImplFromJson(json);

  @override
  @JsonKey(name: '_id')
  final String id;
  @override
  final MyUser user;
  @override
  @JsonKey()
  final String content;
  final List<String> _media;
  @override
  @JsonKey(fromJson: _mediaFromJson)
  List<String> get media {
    if (_media is EqualUnmodifiableListView) return _media;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_media);
  }

  final List<String> _likes;
  @override
  @JsonKey()
  List<String> get likes {
    if (_likes is EqualUnmodifiableListView) return _likes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_likes);
  }

  final List<String> _shares;
  @override
  @JsonKey()
  List<String> get shares {
    if (_shares is EqualUnmodifiableListView) return _shares;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_shares);
  }

  @override
  @JsonKey()
  final int views;
  @override
  final dynamic sharedFrom;
  @override
  final Music? music;
  @override
  @JsonKey()
  final String privacy;
  @override
  final String createdAt;
  @override
  final String updatedAt;
  @override
  @JsonKey(name: '__v')
  final int? v;
  @override
  @JsonKey(name: 'commentCount')
  final int commentCount;
  @override
  @JsonKey(name: 'id')
  final String userPostId;
  @override
  @JsonKey()
  final bool allowComment;
  final List<dynamic> _bookmarks;
  @override
  @JsonKey()
  List<dynamic> get bookmarks {
    if (_bookmarks is EqualUnmodifiableListView) return _bookmarks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_bookmarks);
  }

  @override
  String toString() {
    return 'GetUserPostProfleResponseData(id: $id, user: $user, content: $content, media: $media, likes: $likes, shares: $shares, views: $views, sharedFrom: $sharedFrom, music: $music, privacy: $privacy, createdAt: $createdAt, updatedAt: $updatedAt, v: $v, commentCount: $commentCount, userPostId: $userPostId, allowComment: $allowComment, bookmarks: $bookmarks)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GetUserPostProfleResponseDataImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.content, content) || other.content == content) &&
            const DeepCollectionEquality().equals(other._media, _media) &&
            const DeepCollectionEquality().equals(other._likes, _likes) &&
            const DeepCollectionEquality().equals(other._shares, _shares) &&
            (identical(other.views, views) || other.views == views) &&
            const DeepCollectionEquality()
                .equals(other.sharedFrom, sharedFrom) &&
            (identical(other.music, music) || other.music == music) &&
            (identical(other.privacy, privacy) || other.privacy == privacy) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.v, v) || other.v == v) &&
            (identical(other.commentCount, commentCount) ||
                other.commentCount == commentCount) &&
            (identical(other.userPostId, userPostId) ||
                other.userPostId == userPostId) &&
            (identical(other.allowComment, allowComment) ||
                other.allowComment == allowComment) &&
            const DeepCollectionEquality()
                .equals(other._bookmarks, _bookmarks));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      user,
      content,
      const DeepCollectionEquality().hash(_media),
      const DeepCollectionEquality().hash(_likes),
      const DeepCollectionEquality().hash(_shares),
      views,
      const DeepCollectionEquality().hash(sharedFrom),
      music,
      privacy,
      createdAt,
      updatedAt,
      v,
      commentCount,
      userPostId,
      allowComment,
      const DeepCollectionEquality().hash(_bookmarks));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GetUserPostProfleResponseDataImplCopyWith<
          _$GetUserPostProfleResponseDataImpl>
      get copyWith => __$$GetUserPostProfleResponseDataImplCopyWithImpl<
          _$GetUserPostProfleResponseDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GetUserPostProfleResponseDataImplToJson(
      this,
    );
  }
}

abstract class _GetUserPostProfleResponseData
    implements GetUserPostProfleResponseData {
  const factory _GetUserPostProfleResponseData(
      {@JsonKey(name: '_id') required final String id,
      required final MyUser user,
      final String content,
      @JsonKey(fromJson: _mediaFromJson) final List<String> media,
      final List<String> likes,
      final List<String> shares,
      final int views,
      final dynamic sharedFrom,
      final Music? music,
      final String privacy,
      required final String createdAt,
      required final String updatedAt,
      @JsonKey(name: '__v') final int? v,
      @JsonKey(name: 'commentCount') final int commentCount,
      @JsonKey(name: 'id') required final String userPostId,
      final bool allowComment,
      final List<dynamic> bookmarks}) = _$GetUserPostProfleResponseDataImpl;

  factory _GetUserPostProfleResponseData.fromJson(Map<String, dynamic> json) =
      _$GetUserPostProfleResponseDataImpl.fromJson;

  @override
  @JsonKey(name: '_id')
  String get id;
  @override
  MyUser get user;
  @override
  String get content;
  @override
  @JsonKey(fromJson: _mediaFromJson)
  List<String> get media;
  @override
  List<String> get likes;
  @override
  List<String> get shares;
  @override
  int get views;
  @override
  dynamic get sharedFrom;
  @override
  Music? get music;
  @override
  String get privacy;
  @override
  String get createdAt;
  @override
  String get updatedAt;
  @override
  @JsonKey(name: '__v')
  int? get v;
  @override
  @JsonKey(name: 'commentCount')
  int get commentCount;
  @override
  @JsonKey(name: 'id')
  String get userPostId;
  @override
  bool get allowComment;
  @override
  List<dynamic> get bookmarks;
  @override
  @JsonKey(ignore: true)
  _$$GetUserPostProfleResponseDataImplCopyWith<
          _$GetUserPostProfleResponseDataImpl>
      get copyWith => throw _privateConstructorUsedError;
}
