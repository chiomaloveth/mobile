// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'get_feed_response_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

GetFeedResponseData _$GetFeedResponseDataFromJson(Map<String, dynamic> json) {
  return _GetFeedResponseData.fromJson(json);
}

/// @nodoc
mixin _$GetFeedResponseData {
  @JsonKey(name: '_id')
  String get id => throw _privateConstructorUsedError;
  FeedUser get user => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  List<String> get media => throw _privateConstructorUsedError;
  List<dynamic> get likes => throw _privateConstructorUsedError;
  List<dynamic> get shares => throw _privateConstructorUsedError;
  List<dynamic> get bookmarks => throw _privateConstructorUsedError;
  int get views => throw _privateConstructorUsedError;
  bool get isBookmarked => throw _privateConstructorUsedError;
  bool get isFollowing => throw _privateConstructorUsedError;
  @JsonKey(name: 'commentCount')
  int get commentCount => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  int get bookmarkCount => throw _privateConstructorUsedError;
  List<dynamic>? get overlays => throw _privateConstructorUsedError;
  String? get overlayText => throw _privateConstructorUsedError;
  List<String>? get overlayVideos => throw _privateConstructorUsedError;
  dynamic get sharedFrom => throw _privateConstructorUsedError;
  Music? get music => throw _privateConstructorUsedError;
  String get privacy => throw _privateConstructorUsedError;
  bool get allowComment => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  @JsonKey(name: '__v')
  int get v => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GetFeedResponseDataCopyWith<GetFeedResponseData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GetFeedResponseDataCopyWith<$Res> {
  factory $GetFeedResponseDataCopyWith(
          GetFeedResponseData value, $Res Function(GetFeedResponseData) then) =
      _$GetFeedResponseDataCopyWithImpl<$Res, GetFeedResponseData>;
  @useResult
  $Res call(
      {@JsonKey(name: '_id') String id,
      FeedUser user,
      String content,
      List<String> media,
      List<dynamic> likes,
      List<dynamic> shares,
      List<dynamic> bookmarks,
      int views,
      bool isBookmarked,
      bool isFollowing,
      @JsonKey(name: 'commentCount') int commentCount,
      List<String> tags,
      int bookmarkCount,
      List<dynamic>? overlays,
      String? overlayText,
      List<String>? overlayVideos,
      dynamic sharedFrom,
      Music? music,
      String privacy,
      bool allowComment,
      DateTime createdAt,
      DateTime updatedAt,
      @JsonKey(name: '__v') int v});

  $FeedUserCopyWith<$Res> get user;
  $MusicCopyWith<$Res>? get music;
}

/// @nodoc
class _$GetFeedResponseDataCopyWithImpl<$Res, $Val extends GetFeedResponseData>
    implements $GetFeedResponseDataCopyWith<$Res> {
  _$GetFeedResponseDataCopyWithImpl(this._value, this._then);

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
    Object? bookmarks = null,
    Object? views = null,
    Object? isBookmarked = null,
    Object? isFollowing = null,
    Object? commentCount = null,
    Object? tags = null,
    Object? bookmarkCount = null,
    Object? overlays = freezed,
    Object? overlayText = freezed,
    Object? overlayVideos = freezed,
    Object? sharedFrom = freezed,
    Object? music = freezed,
    Object? privacy = null,
    Object? allowComment = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? v = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as FeedUser,
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
              as List<dynamic>,
      shares: null == shares
          ? _value.shares
          : shares // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
      bookmarks: null == bookmarks
          ? _value.bookmarks
          : bookmarks // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
      views: null == views
          ? _value.views
          : views // ignore: cast_nullable_to_non_nullable
              as int,
      isBookmarked: null == isBookmarked
          ? _value.isBookmarked
          : isBookmarked // ignore: cast_nullable_to_non_nullable
              as bool,
      isFollowing: null == isFollowing
          ? _value.isFollowing
          : isFollowing // ignore: cast_nullable_to_non_nullable
              as bool,
      commentCount: null == commentCount
          ? _value.commentCount
          : commentCount // ignore: cast_nullable_to_non_nullable
              as int,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      bookmarkCount: null == bookmarkCount
          ? _value.bookmarkCount
          : bookmarkCount // ignore: cast_nullable_to_non_nullable
              as int,
      overlays: freezed == overlays
          ? _value.overlays
          : overlays // ignore: cast_nullable_to_non_nullable
              as List<dynamic>?,
      overlayText: freezed == overlayText
          ? _value.overlayText
          : overlayText // ignore: cast_nullable_to_non_nullable
              as String?,
      overlayVideos: freezed == overlayVideos
          ? _value.overlayVideos
          : overlayVideos // ignore: cast_nullable_to_non_nullable
              as List<String>?,
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
      allowComment: null == allowComment
          ? _value.allowComment
          : allowComment // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      v: null == v
          ? _value.v
          : v // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $FeedUserCopyWith<$Res> get user {
    return $FeedUserCopyWith<$Res>(_value.user, (value) {
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
abstract class _$$GetFeedResponseDataImplCopyWith<$Res>
    implements $GetFeedResponseDataCopyWith<$Res> {
  factory _$$GetFeedResponseDataImplCopyWith(_$GetFeedResponseDataImpl value,
          $Res Function(_$GetFeedResponseDataImpl) then) =
      __$$GetFeedResponseDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: '_id') String id,
      FeedUser user,
      String content,
      List<String> media,
      List<dynamic> likes,
      List<dynamic> shares,
      List<dynamic> bookmarks,
      int views,
      bool isBookmarked,
      bool isFollowing,
      @JsonKey(name: 'commentCount') int commentCount,
      List<String> tags,
      int bookmarkCount,
      List<dynamic>? overlays,
      String? overlayText,
      List<String>? overlayVideos,
      dynamic sharedFrom,
      Music? music,
      String privacy,
      bool allowComment,
      DateTime createdAt,
      DateTime updatedAt,
      @JsonKey(name: '__v') int v});

  @override
  $FeedUserCopyWith<$Res> get user;
  @override
  $MusicCopyWith<$Res>? get music;
}

/// @nodoc
class __$$GetFeedResponseDataImplCopyWithImpl<$Res>
    extends _$GetFeedResponseDataCopyWithImpl<$Res, _$GetFeedResponseDataImpl>
    implements _$$GetFeedResponseDataImplCopyWith<$Res> {
  __$$GetFeedResponseDataImplCopyWithImpl(_$GetFeedResponseDataImpl _value,
      $Res Function(_$GetFeedResponseDataImpl) _then)
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
    Object? bookmarks = null,
    Object? views = null,
    Object? isBookmarked = null,
    Object? isFollowing = null,
    Object? commentCount = null,
    Object? tags = null,
    Object? bookmarkCount = null,
    Object? overlays = freezed,
    Object? overlayText = freezed,
    Object? overlayVideos = freezed,
    Object? sharedFrom = freezed,
    Object? music = freezed,
    Object? privacy = null,
    Object? allowComment = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? v = null,
  }) {
    return _then(_$GetFeedResponseDataImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as FeedUser,
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
              as List<dynamic>,
      shares: null == shares
          ? _value._shares
          : shares // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
      bookmarks: null == bookmarks
          ? _value._bookmarks
          : bookmarks // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
      views: null == views
          ? _value.views
          : views // ignore: cast_nullable_to_non_nullable
              as int,
      isBookmarked: null == isBookmarked
          ? _value.isBookmarked
          : isBookmarked // ignore: cast_nullable_to_non_nullable
              as bool,
      isFollowing: null == isFollowing
          ? _value.isFollowing
          : isFollowing // ignore: cast_nullable_to_non_nullable
              as bool,
      commentCount: null == commentCount
          ? _value.commentCount
          : commentCount // ignore: cast_nullable_to_non_nullable
              as int,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      bookmarkCount: null == bookmarkCount
          ? _value.bookmarkCount
          : bookmarkCount // ignore: cast_nullable_to_non_nullable
              as int,
      overlays: freezed == overlays
          ? _value._overlays
          : overlays // ignore: cast_nullable_to_non_nullable
              as List<dynamic>?,
      overlayText: freezed == overlayText
          ? _value.overlayText
          : overlayText // ignore: cast_nullable_to_non_nullable
              as String?,
      overlayVideos: freezed == overlayVideos
          ? _value._overlayVideos
          : overlayVideos // ignore: cast_nullable_to_non_nullable
              as List<String>?,
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
      allowComment: null == allowComment
          ? _value.allowComment
          : allowComment // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      v: null == v
          ? _value.v
          : v // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GetFeedResponseDataImpl
    with DiagnosticableTreeMixin
    implements _GetFeedResponseData {
  const _$GetFeedResponseDataImpl(
      {@JsonKey(name: '_id') required this.id,
      required this.user,
      this.content = '',
      final List<String> media = const [],
      final List<dynamic> likes = const [],
      final List<dynamic> shares = const [],
      final List<dynamic> bookmarks = const [],
      this.views = 0,
      this.isBookmarked = false,
      this.isFollowing = false,
      @JsonKey(name: 'commentCount') this.commentCount = 0,
      final List<String> tags = const [],
      this.bookmarkCount = 0,
      final List<dynamic>? overlays,
      this.overlayText,
      final List<String>? overlayVideos,
      this.sharedFrom,
      this.music,
      this.privacy = 'everyone',
      this.allowComment = true,
      required this.createdAt,
      required this.updatedAt,
      @JsonKey(name: '__v') this.v = 0})
      : _media = media,
        _likes = likes,
        _shares = shares,
        _bookmarks = bookmarks,
        _tags = tags,
        _overlays = overlays,
        _overlayVideos = overlayVideos;

  factory _$GetFeedResponseDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$GetFeedResponseDataImplFromJson(json);

  @override
  @JsonKey(name: '_id')
  final String id;
  @override
  final FeedUser user;
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
  @JsonKey()
  final int views;
  @override
  @JsonKey()
  final bool isBookmarked;
  @override
  @JsonKey()
  final bool isFollowing;
  @override
  @JsonKey(name: 'commentCount')
  final int commentCount;
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
  final int bookmarkCount;
  final List<dynamic>? _overlays;
  @override
  List<dynamic>? get overlays {
    final value = _overlays;
    if (value == null) return null;
    if (_overlays is EqualUnmodifiableListView) return _overlays;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? overlayText;
  final List<String>? _overlayVideos;
  @override
  List<String>? get overlayVideos {
    final value = _overlayVideos;
    if (value == null) return null;
    if (_overlayVideos is EqualUnmodifiableListView) return _overlayVideos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final dynamic sharedFrom;
  @override
  final Music? music;
  @override
  @JsonKey()
  final String privacy;
  @override
  @JsonKey()
  final bool allowComment;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  @JsonKey(name: '__v')
  final int v;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'GetFeedResponseData(id: $id, user: $user, content: $content, media: $media, likes: $likes, shares: $shares, bookmarks: $bookmarks, views: $views, isBookmarked: $isBookmarked, isFollowing: $isFollowing, commentCount: $commentCount, tags: $tags, bookmarkCount: $bookmarkCount, overlays: $overlays, overlayText: $overlayText, overlayVideos: $overlayVideos, sharedFrom: $sharedFrom, music: $music, privacy: $privacy, allowComment: $allowComment, createdAt: $createdAt, updatedAt: $updatedAt, v: $v)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'GetFeedResponseData'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('user', user))
      ..add(DiagnosticsProperty('content', content))
      ..add(DiagnosticsProperty('media', media))
      ..add(DiagnosticsProperty('likes', likes))
      ..add(DiagnosticsProperty('shares', shares))
      ..add(DiagnosticsProperty('bookmarks', bookmarks))
      ..add(DiagnosticsProperty('views', views))
      ..add(DiagnosticsProperty('isBookmarked', isBookmarked))
      ..add(DiagnosticsProperty('isFollowing', isFollowing))
      ..add(DiagnosticsProperty('commentCount', commentCount))
      ..add(DiagnosticsProperty('tags', tags))
      ..add(DiagnosticsProperty('bookmarkCount', bookmarkCount))
      ..add(DiagnosticsProperty('overlays', overlays))
      ..add(DiagnosticsProperty('overlayText', overlayText))
      ..add(DiagnosticsProperty('overlayVideos', overlayVideos))
      ..add(DiagnosticsProperty('sharedFrom', sharedFrom))
      ..add(DiagnosticsProperty('music', music))
      ..add(DiagnosticsProperty('privacy', privacy))
      ..add(DiagnosticsProperty('allowComment', allowComment))
      ..add(DiagnosticsProperty('createdAt', createdAt))
      ..add(DiagnosticsProperty('updatedAt', updatedAt))
      ..add(DiagnosticsProperty('v', v));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GetFeedResponseDataImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.content, content) || other.content == content) &&
            const DeepCollectionEquality().equals(other._media, _media) &&
            const DeepCollectionEquality().equals(other._likes, _likes) &&
            const DeepCollectionEquality().equals(other._shares, _shares) &&
            const DeepCollectionEquality()
                .equals(other._bookmarks, _bookmarks) &&
            (identical(other.views, views) || other.views == views) &&
            (identical(other.isBookmarked, isBookmarked) ||
                other.isBookmarked == isBookmarked) &&
            (identical(other.isFollowing, isFollowing) ||
                other.isFollowing == isFollowing) &&
            (identical(other.commentCount, commentCount) ||
                other.commentCount == commentCount) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.bookmarkCount, bookmarkCount) ||
                other.bookmarkCount == bookmarkCount) &&
            const DeepCollectionEquality().equals(other._overlays, _overlays) &&
            (identical(other.overlayText, overlayText) ||
                other.overlayText == overlayText) &&
            const DeepCollectionEquality()
                .equals(other._overlayVideos, _overlayVideos) &&
            const DeepCollectionEquality()
                .equals(other.sharedFrom, sharedFrom) &&
            (identical(other.music, music) || other.music == music) &&
            (identical(other.privacy, privacy) || other.privacy == privacy) &&
            (identical(other.allowComment, allowComment) ||
                other.allowComment == allowComment) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.v, v) || other.v == v));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        user,
        content,
        const DeepCollectionEquality().hash(_media),
        const DeepCollectionEquality().hash(_likes),
        const DeepCollectionEquality().hash(_shares),
        const DeepCollectionEquality().hash(_bookmarks),
        views,
        isBookmarked,
        isFollowing,
        commentCount,
        const DeepCollectionEquality().hash(_tags),
        bookmarkCount,
        const DeepCollectionEquality().hash(_overlays),
        overlayText,
        const DeepCollectionEquality().hash(_overlayVideos),
        const DeepCollectionEquality().hash(sharedFrom),
        music,
        privacy,
        allowComment,
        createdAt,
        updatedAt,
        v
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GetFeedResponseDataImplCopyWith<_$GetFeedResponseDataImpl> get copyWith =>
      __$$GetFeedResponseDataImplCopyWithImpl<_$GetFeedResponseDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GetFeedResponseDataImplToJson(
      this,
    );
  }
}

abstract class _GetFeedResponseData implements GetFeedResponseData {
  const factory _GetFeedResponseData(
      {@JsonKey(name: '_id') required final String id,
      required final FeedUser user,
      final String content,
      final List<String> media,
      final List<dynamic> likes,
      final List<dynamic> shares,
      final List<dynamic> bookmarks,
      final int views,
      final bool isBookmarked,
      final bool isFollowing,
      @JsonKey(name: 'commentCount') final int commentCount,
      final List<String> tags,
      final int bookmarkCount,
      final List<dynamic>? overlays,
      final String? overlayText,
      final List<String>? overlayVideos,
      final dynamic sharedFrom,
      final Music? music,
      final String privacy,
      final bool allowComment,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      @JsonKey(name: '__v') final int v}) = _$GetFeedResponseDataImpl;

  factory _GetFeedResponseData.fromJson(Map<String, dynamic> json) =
      _$GetFeedResponseDataImpl.fromJson;

  @override
  @JsonKey(name: '_id')
  String get id;
  @override
  FeedUser get user;
  @override
  String get content;
  @override
  List<String> get media;
  @override
  List<dynamic> get likes;
  @override
  List<dynamic> get shares;
  @override
  List<dynamic> get bookmarks;
  @override
  int get views;
  @override
  bool get isBookmarked;
  @override
  bool get isFollowing;
  @override
  @JsonKey(name: 'commentCount')
  int get commentCount;
  @override
  List<String> get tags;
  @override
  int get bookmarkCount;
  @override
  List<dynamic>? get overlays;
  @override
  String? get overlayText;
  @override
  List<String>? get overlayVideos;
  @override
  dynamic get sharedFrom;
  @override
  Music? get music;
  @override
  String get privacy;
  @override
  bool get allowComment;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  @JsonKey(name: '__v')
  int get v;
  @override
  @JsonKey(ignore: true)
  _$$GetFeedResponseDataImplCopyWith<_$GetFeedResponseDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Music _$MusicFromJson(Map<String, dynamic> json) {
  return _Music.fromJson(json);
}

/// @nodoc
mixin _$Music {
  String get thirdPartyId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get artist => throw _privateConstructorUsedError;
  String get audioUrl => throw _privateConstructorUsedError;
  String? get coverImage => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MusicCopyWith<Music> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MusicCopyWith<$Res> {
  factory $MusicCopyWith(Music value, $Res Function(Music) then) =
      _$MusicCopyWithImpl<$Res, Music>;
  @useResult
  $Res call(
      {String thirdPartyId,
      String title,
      String artist,
      String audioUrl,
      String? coverImage});
}

/// @nodoc
class _$MusicCopyWithImpl<$Res, $Val extends Music>
    implements $MusicCopyWith<$Res> {
  _$MusicCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? thirdPartyId = null,
    Object? title = null,
    Object? artist = null,
    Object? audioUrl = null,
    Object? coverImage = freezed,
  }) {
    return _then(_value.copyWith(
      thirdPartyId: null == thirdPartyId
          ? _value.thirdPartyId
          : thirdPartyId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      artist: null == artist
          ? _value.artist
          : artist // ignore: cast_nullable_to_non_nullable
              as String,
      audioUrl: null == audioUrl
          ? _value.audioUrl
          : audioUrl // ignore: cast_nullable_to_non_nullable
              as String,
      coverImage: freezed == coverImage
          ? _value.coverImage
          : coverImage // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MusicImplCopyWith<$Res> implements $MusicCopyWith<$Res> {
  factory _$$MusicImplCopyWith(
          _$MusicImpl value, $Res Function(_$MusicImpl) then) =
      __$$MusicImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String thirdPartyId,
      String title,
      String artist,
      String audioUrl,
      String? coverImage});
}

/// @nodoc
class __$$MusicImplCopyWithImpl<$Res>
    extends _$MusicCopyWithImpl<$Res, _$MusicImpl>
    implements _$$MusicImplCopyWith<$Res> {
  __$$MusicImplCopyWithImpl(
      _$MusicImpl _value, $Res Function(_$MusicImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? thirdPartyId = null,
    Object? title = null,
    Object? artist = null,
    Object? audioUrl = null,
    Object? coverImage = freezed,
  }) {
    return _then(_$MusicImpl(
      thirdPartyId: null == thirdPartyId
          ? _value.thirdPartyId
          : thirdPartyId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      artist: null == artist
          ? _value.artist
          : artist // ignore: cast_nullable_to_non_nullable
              as String,
      audioUrl: null == audioUrl
          ? _value.audioUrl
          : audioUrl // ignore: cast_nullable_to_non_nullable
              as String,
      coverImage: freezed == coverImage
          ? _value.coverImage
          : coverImage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MusicImpl with DiagnosticableTreeMixin implements _Music {
  const _$MusicImpl(
      {required this.thirdPartyId,
      required this.title,
      required this.artist,
      required this.audioUrl,
      this.coverImage});

  factory _$MusicImpl.fromJson(Map<String, dynamic> json) =>
      _$$MusicImplFromJson(json);

  @override
  final String thirdPartyId;
  @override
  final String title;
  @override
  final String artist;
  @override
  final String audioUrl;
  @override
  final String? coverImage;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Music(thirdPartyId: $thirdPartyId, title: $title, artist: $artist, audioUrl: $audioUrl, coverImage: $coverImage)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Music'))
      ..add(DiagnosticsProperty('thirdPartyId', thirdPartyId))
      ..add(DiagnosticsProperty('title', title))
      ..add(DiagnosticsProperty('artist', artist))
      ..add(DiagnosticsProperty('audioUrl', audioUrl))
      ..add(DiagnosticsProperty('coverImage', coverImage));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MusicImpl &&
            (identical(other.thirdPartyId, thirdPartyId) ||
                other.thirdPartyId == thirdPartyId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.artist, artist) || other.artist == artist) &&
            (identical(other.audioUrl, audioUrl) ||
                other.audioUrl == audioUrl) &&
            (identical(other.coverImage, coverImage) ||
                other.coverImage == coverImage));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, thirdPartyId, title, artist, audioUrl, coverImage);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MusicImplCopyWith<_$MusicImpl> get copyWith =>
      __$$MusicImplCopyWithImpl<_$MusicImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MusicImplToJson(
      this,
    );
  }
}

abstract class _Music implements Music {
  const factory _Music(
      {required final String thirdPartyId,
      required final String title,
      required final String artist,
      required final String audioUrl,
      final String? coverImage}) = _$MusicImpl;

  factory _Music.fromJson(Map<String, dynamic> json) = _$MusicImpl.fromJson;

  @override
  String get thirdPartyId;
  @override
  String get title;
  @override
  String get artist;
  @override
  String get audioUrl;
  @override
  String? get coverImage;
  @override
  @JsonKey(ignore: true)
  _$$MusicImplCopyWith<_$MusicImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
