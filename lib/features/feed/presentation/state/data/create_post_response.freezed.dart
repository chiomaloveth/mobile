// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_post_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CreatePostResponse _$CreatePostResponseFromJson(Map<String, dynamic> json) {
  return _CreatePostResponse.fromJson(json);
}

/// @nodoc
mixin _$CreatePostResponse {
  @JsonKey(name: '_id')
  String get id => throw _privateConstructorUsedError;
  String? get user => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  List<String> get media => throw _privateConstructorUsedError;
  int get views => throw _privateConstructorUsedError;
  List<dynamic> get likes => throw _privateConstructorUsedError;
  List<dynamic> get shares => throw _privateConstructorUsedError;
  List<dynamic> get bookmarks => throw _privateConstructorUsedError;
  dynamic get sharedFrom => throw _privateConstructorUsedError;
  Music? get music => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  String get privacy => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  @JsonKey(name: '__v')
  int? get v => throw _privateConstructorUsedError;
  @JsonKey(name: 'commentCount')
  int get commentCount => throw _privateConstructorUsedError;
  bool? get isFollowing => throw _privateConstructorUsedError;
  @JsonKey(name: 'id')
  String? get legacyId => throw _privateConstructorUsedError;
  bool? get allowComment => throw _privateConstructorUsedError;
  @JsonKey(name: 'overlayText')
  String? get overlayText => throw _privateConstructorUsedError;
  @JsonKey(name: 'overlayVideos')
  List<String>? get overlayVideos => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CreatePostResponseCopyWith<CreatePostResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreatePostResponseCopyWith<$Res> {
  factory $CreatePostResponseCopyWith(
          CreatePostResponse value, $Res Function(CreatePostResponse) then) =
      _$CreatePostResponseCopyWithImpl<$Res, CreatePostResponse>;
  @useResult
  $Res call(
      {@JsonKey(name: '_id') String id,
      String? user,
      String content,
      List<String> media,
      int views,
      List<dynamic> likes,
      List<dynamic> shares,
      List<dynamic> bookmarks,
      dynamic sharedFrom,
      Music? music,
      List<String> tags,
      String privacy,
      DateTime createdAt,
      DateTime updatedAt,
      @JsonKey(name: '__v') int? v,
      @JsonKey(name: 'commentCount') int commentCount,
      bool? isFollowing,
      @JsonKey(name: 'id') String? legacyId,
      bool? allowComment,
      @JsonKey(name: 'overlayText') String? overlayText,
      @JsonKey(name: 'overlayVideos') List<String>? overlayVideos});

  $MusicCopyWith<$Res>? get music;
}

/// @nodoc
class _$CreatePostResponseCopyWithImpl<$Res, $Val extends CreatePostResponse>
    implements $CreatePostResponseCopyWith<$Res> {
  _$CreatePostResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? user = freezed,
    Object? content = null,
    Object? media = null,
    Object? views = null,
    Object? likes = null,
    Object? shares = null,
    Object? bookmarks = null,
    Object? sharedFrom = freezed,
    Object? music = freezed,
    Object? tags = null,
    Object? privacy = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? v = freezed,
    Object? commentCount = null,
    Object? isFollowing = freezed,
    Object? legacyId = freezed,
    Object? allowComment = freezed,
    Object? overlayText = freezed,
    Object? overlayVideos = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      user: freezed == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as String?,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      media: null == media
          ? _value.media
          : media // ignore: cast_nullable_to_non_nullable
              as List<String>,
      views: null == views
          ? _value.views
          : views // ignore: cast_nullable_to_non_nullable
              as int,
      likes: null == likes
          ? _value.likes
          : likes // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
      shares: null == shares
          ? _value.shares
          : shares // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
      bookmarks: null == bookmarks
          ? _value.bookmarks
          : bookmarks // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
      sharedFrom: freezed == sharedFrom
          ? _value.sharedFrom
          : sharedFrom // ignore: cast_nullable_to_non_nullable
              as dynamic,
      music: freezed == music
          ? _value.music
          : music // ignore: cast_nullable_to_non_nullable
              as Music?,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      privacy: null == privacy
          ? _value.privacy
          : privacy // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      v: freezed == v
          ? _value.v
          : v // ignore: cast_nullable_to_non_nullable
              as int?,
      commentCount: null == commentCount
          ? _value.commentCount
          : commentCount // ignore: cast_nullable_to_non_nullable
              as int,
      isFollowing: freezed == isFollowing
          ? _value.isFollowing
          : isFollowing // ignore: cast_nullable_to_non_nullable
              as bool?,
      legacyId: freezed == legacyId
          ? _value.legacyId
          : legacyId // ignore: cast_nullable_to_non_nullable
              as String?,
      allowComment: freezed == allowComment
          ? _value.allowComment
          : allowComment // ignore: cast_nullable_to_non_nullable
              as bool?,
      overlayText: freezed == overlayText
          ? _value.overlayText
          : overlayText // ignore: cast_nullable_to_non_nullable
              as String?,
      overlayVideos: freezed == overlayVideos
          ? _value.overlayVideos
          : overlayVideos // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ) as $Val);
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
abstract class _$$CreatePostResponseImplCopyWith<$Res>
    implements $CreatePostResponseCopyWith<$Res> {
  factory _$$CreatePostResponseImplCopyWith(_$CreatePostResponseImpl value,
          $Res Function(_$CreatePostResponseImpl) then) =
      __$$CreatePostResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: '_id') String id,
      String? user,
      String content,
      List<String> media,
      int views,
      List<dynamic> likes,
      List<dynamic> shares,
      List<dynamic> bookmarks,
      dynamic sharedFrom,
      Music? music,
      List<String> tags,
      String privacy,
      DateTime createdAt,
      DateTime updatedAt,
      @JsonKey(name: '__v') int? v,
      @JsonKey(name: 'commentCount') int commentCount,
      bool? isFollowing,
      @JsonKey(name: 'id') String? legacyId,
      bool? allowComment,
      @JsonKey(name: 'overlayText') String? overlayText,
      @JsonKey(name: 'overlayVideos') List<String>? overlayVideos});

  @override
  $MusicCopyWith<$Res>? get music;
}

/// @nodoc
class __$$CreatePostResponseImplCopyWithImpl<$Res>
    extends _$CreatePostResponseCopyWithImpl<$Res, _$CreatePostResponseImpl>
    implements _$$CreatePostResponseImplCopyWith<$Res> {
  __$$CreatePostResponseImplCopyWithImpl(_$CreatePostResponseImpl _value,
      $Res Function(_$CreatePostResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? user = freezed,
    Object? content = null,
    Object? media = null,
    Object? views = null,
    Object? likes = null,
    Object? shares = null,
    Object? bookmarks = null,
    Object? sharedFrom = freezed,
    Object? music = freezed,
    Object? tags = null,
    Object? privacy = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? v = freezed,
    Object? commentCount = null,
    Object? isFollowing = freezed,
    Object? legacyId = freezed,
    Object? allowComment = freezed,
    Object? overlayText = freezed,
    Object? overlayVideos = freezed,
  }) {
    return _then(_$CreatePostResponseImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      user: freezed == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as String?,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      media: null == media
          ? _value._media
          : media // ignore: cast_nullable_to_non_nullable
              as List<String>,
      views: null == views
          ? _value.views
          : views // ignore: cast_nullable_to_non_nullable
              as int,
      likes: null == likes
          ? _value._likes
          : likes // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
      shares: null == shares
          ? _value._shares
          : shares // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
      bookmarks: null == bookmarks
          ? _value._bookmarks
          : bookmarks // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
      sharedFrom: freezed == sharedFrom
          ? _value.sharedFrom
          : sharedFrom // ignore: cast_nullable_to_non_nullable
              as dynamic,
      music: freezed == music
          ? _value.music
          : music // ignore: cast_nullable_to_non_nullable
              as Music?,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      privacy: null == privacy
          ? _value.privacy
          : privacy // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      v: freezed == v
          ? _value.v
          : v // ignore: cast_nullable_to_non_nullable
              as int?,
      commentCount: null == commentCount
          ? _value.commentCount
          : commentCount // ignore: cast_nullable_to_non_nullable
              as int,
      isFollowing: freezed == isFollowing
          ? _value.isFollowing
          : isFollowing // ignore: cast_nullable_to_non_nullable
              as bool?,
      legacyId: freezed == legacyId
          ? _value.legacyId
          : legacyId // ignore: cast_nullable_to_non_nullable
              as String?,
      allowComment: freezed == allowComment
          ? _value.allowComment
          : allowComment // ignore: cast_nullable_to_non_nullable
              as bool?,
      overlayText: freezed == overlayText
          ? _value.overlayText
          : overlayText // ignore: cast_nullable_to_non_nullable
              as String?,
      overlayVideos: freezed == overlayVideos
          ? _value._overlayVideos
          : overlayVideos // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CreatePostResponseImpl implements _CreatePostResponse {
  const _$CreatePostResponseImpl(
      {@JsonKey(name: '_id') required this.id,
      this.user,
      this.content = '',
      final List<String> media = const [],
      this.views = 0,
      final List<dynamic> likes = const [],
      final List<dynamic> shares = const [],
      final List<dynamic> bookmarks = const [],
      this.sharedFrom,
      this.music,
      final List<String> tags = const <String>[],
      this.privacy = 'everyone',
      required this.createdAt,
      required this.updatedAt,
      @JsonKey(name: '__v') this.v,
      @JsonKey(name: 'commentCount') this.commentCount = 0,
      this.isFollowing,
      @JsonKey(name: 'id') this.legacyId,
      this.allowComment,
      @JsonKey(name: 'overlayText') this.overlayText,
      @JsonKey(name: 'overlayVideos') final List<String>? overlayVideos})
      : _media = media,
        _likes = likes,
        _shares = shares,
        _bookmarks = bookmarks,
        _tags = tags,
        _overlayVideos = overlayVideos;

  factory _$CreatePostResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreatePostResponseImplFromJson(json);

  @override
  @JsonKey(name: '_id')
  final String id;
  @override
  final String? user;
  @override
  @JsonKey()
  final String content;
  final List<String> _media;
  @override
  @JsonKey()
  List<String> get media {
    if (_media is EqualUnmodifiableListView) return _media;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_media);
  }

  @override
  @JsonKey()
  final int views;
  final List<dynamic> _likes;
  @override
  @JsonKey()
  List<dynamic> get likes {
    if (_likes is EqualUnmodifiableListView) return _likes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_likes);
  }

  final List<dynamic> _shares;
  @override
  @JsonKey()
  List<dynamic> get shares {
    if (_shares is EqualUnmodifiableListView) return _shares;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_shares);
  }

  final List<dynamic> _bookmarks;
  @override
  @JsonKey()
  List<dynamic> get bookmarks {
    if (_bookmarks is EqualUnmodifiableListView) return _bookmarks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_bookmarks);
  }

  @override
  final dynamic sharedFrom;
  @override
  final Music? music;
  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  @JsonKey()
  final String privacy;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  @JsonKey(name: '__v')
  final int? v;
  @override
  @JsonKey(name: 'commentCount')
  final int commentCount;
  @override
  final bool? isFollowing;
  @override
  @JsonKey(name: 'id')
  final String? legacyId;
  @override
  final bool? allowComment;
  @override
  @JsonKey(name: 'overlayText')
  final String? overlayText;
  final List<String>? _overlayVideos;
  @override
  @JsonKey(name: 'overlayVideos')
  List<String>? get overlayVideos {
    final value = _overlayVideos;
    if (value == null) return null;
    if (_overlayVideos is EqualUnmodifiableListView) return _overlayVideos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'CreatePostResponse(id: $id, user: $user, content: $content, media: $media, views: $views, likes: $likes, shares: $shares, bookmarks: $bookmarks, sharedFrom: $sharedFrom, music: $music, tags: $tags, privacy: $privacy, createdAt: $createdAt, updatedAt: $updatedAt, v: $v, commentCount: $commentCount, isFollowing: $isFollowing, legacyId: $legacyId, allowComment: $allowComment, overlayText: $overlayText, overlayVideos: $overlayVideos)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreatePostResponseImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.content, content) || other.content == content) &&
            const DeepCollectionEquality().equals(other._media, _media) &&
            (identical(other.views, views) || other.views == views) &&
            const DeepCollectionEquality().equals(other._likes, _likes) &&
            const DeepCollectionEquality().equals(other._shares, _shares) &&
            const DeepCollectionEquality()
                .equals(other._bookmarks, _bookmarks) &&
            const DeepCollectionEquality()
                .equals(other.sharedFrom, sharedFrom) &&
            (identical(other.music, music) || other.music == music) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.privacy, privacy) || other.privacy == privacy) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.v, v) || other.v == v) &&
            (identical(other.commentCount, commentCount) ||
                other.commentCount == commentCount) &&
            (identical(other.isFollowing, isFollowing) ||
                other.isFollowing == isFollowing) &&
            (identical(other.legacyId, legacyId) ||
                other.legacyId == legacyId) &&
            (identical(other.allowComment, allowComment) ||
                other.allowComment == allowComment) &&
            (identical(other.overlayText, overlayText) ||
                other.overlayText == overlayText) &&
            const DeepCollectionEquality()
                .equals(other._overlayVideos, _overlayVideos));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        user,
        content,
        const DeepCollectionEquality().hash(_media),
        views,
        const DeepCollectionEquality().hash(_likes),
        const DeepCollectionEquality().hash(_shares),
        const DeepCollectionEquality().hash(_bookmarks),
        const DeepCollectionEquality().hash(sharedFrom),
        music,
        const DeepCollectionEquality().hash(_tags),
        privacy,
        createdAt,
        updatedAt,
        v,
        commentCount,
        isFollowing,
        legacyId,
        allowComment,
        overlayText,
        const DeepCollectionEquality().hash(_overlayVideos)
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CreatePostResponseImplCopyWith<_$CreatePostResponseImpl> get copyWith =>
      __$$CreatePostResponseImplCopyWithImpl<_$CreatePostResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreatePostResponseImplToJson(
      this,
    );
  }
}

abstract class _CreatePostResponse implements CreatePostResponse {
  const factory _CreatePostResponse(
          {@JsonKey(name: '_id') required final String id,
          final String? user,
          final String content,
          final List<String> media,
          final int views,
          final List<dynamic> likes,
          final List<dynamic> shares,
          final List<dynamic> bookmarks,
          final dynamic sharedFrom,
          final Music? music,
          final List<String> tags,
          final String privacy,
          required final DateTime createdAt,
          required final DateTime updatedAt,
          @JsonKey(name: '__v') final int? v,
          @JsonKey(name: 'commentCount') final int commentCount,
          final bool? isFollowing,
          @JsonKey(name: 'id') final String? legacyId,
          final bool? allowComment,
          @JsonKey(name: 'overlayText') final String? overlayText,
          @JsonKey(name: 'overlayVideos') final List<String>? overlayVideos}) =
      _$CreatePostResponseImpl;

  factory _CreatePostResponse.fromJson(Map<String, dynamic> json) =
      _$CreatePostResponseImpl.fromJson;

  @override
  @JsonKey(name: '_id')
  String get id;
  @override
  String? get user;
  @override
  String get content;
  @override
  List<String> get media;
  @override
  int get views;
  @override
  List<dynamic> get likes;
  @override
  List<dynamic> get shares;
  @override
  List<dynamic> get bookmarks;
  @override
  dynamic get sharedFrom;
  @override
  Music? get music;
  @override
  List<String> get tags;
  @override
  String get privacy;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  @JsonKey(name: '__v')
  int? get v;
  @override
  @JsonKey(name: 'commentCount')
  int get commentCount;
  @override
  bool? get isFollowing;
  @override
  @JsonKey(name: 'id')
  String? get legacyId;
  @override
  bool? get allowComment;
  @override
  @JsonKey(name: 'overlayText')
  String? get overlayText;
  @override
  @JsonKey(name: 'overlayVideos')
  List<String>? get overlayVideos;
  @override
  @JsonKey(ignore: true)
  _$$CreatePostResponseImplCopyWith<_$CreatePostResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
