// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'get_other_user_profile_post.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

GetOtherUserProfilePost _$GetOtherUserProfilePostFromJson(
    Map<String, dynamic> json) {
  return _GetOtherUserProfilePost.fromJson(json);
}

/// @nodoc
mixin _$GetOtherUserProfilePost {
  bool get success => throw _privateConstructorUsedError;
  List<GetOtherUserProfilePostData> get data =>
      throw _privateConstructorUsedError;
  int get page => throw _privateConstructorUsedError;
  int get pageSize => throw _privateConstructorUsedError;
  int get totalPosts => throw _privateConstructorUsedError;
  int get totalPages => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GetOtherUserProfilePostCopyWith<GetOtherUserProfilePost> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GetOtherUserProfilePostCopyWith<$Res> {
  factory $GetOtherUserProfilePostCopyWith(GetOtherUserProfilePost value,
          $Res Function(GetOtherUserProfilePost) then) =
      _$GetOtherUserProfilePostCopyWithImpl<$Res, GetOtherUserProfilePost>;
  @useResult
  $Res call(
      {bool success,
      List<GetOtherUserProfilePostData> data,
      int page,
      int pageSize,
      int totalPosts,
      int totalPages});
}

/// @nodoc
class _$GetOtherUserProfilePostCopyWithImpl<$Res,
        $Val extends GetOtherUserProfilePost>
    implements $GetOtherUserProfilePostCopyWith<$Res> {
  _$GetOtherUserProfilePostCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? data = null,
    Object? page = null,
    Object? pageSize = null,
    Object? totalPosts = null,
    Object? totalPages = null,
  }) {
    return _then(_value.copyWith(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as List<GetOtherUserProfilePostData>,
      page: null == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int,
      pageSize: null == pageSize
          ? _value.pageSize
          : pageSize // ignore: cast_nullable_to_non_nullable
              as int,
      totalPosts: null == totalPosts
          ? _value.totalPosts
          : totalPosts // ignore: cast_nullable_to_non_nullable
              as int,
      totalPages: null == totalPages
          ? _value.totalPages
          : totalPages // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GetOtherUserProfilePostImplCopyWith<$Res>
    implements $GetOtherUserProfilePostCopyWith<$Res> {
  factory _$$GetOtherUserProfilePostImplCopyWith(
          _$GetOtherUserProfilePostImpl value,
          $Res Function(_$GetOtherUserProfilePostImpl) then) =
      __$$GetOtherUserProfilePostImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool success,
      List<GetOtherUserProfilePostData> data,
      int page,
      int pageSize,
      int totalPosts,
      int totalPages});
}

/// @nodoc
class __$$GetOtherUserProfilePostImplCopyWithImpl<$Res>
    extends _$GetOtherUserProfilePostCopyWithImpl<$Res,
        _$GetOtherUserProfilePostImpl>
    implements _$$GetOtherUserProfilePostImplCopyWith<$Res> {
  __$$GetOtherUserProfilePostImplCopyWithImpl(
      _$GetOtherUserProfilePostImpl _value,
      $Res Function(_$GetOtherUserProfilePostImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? data = null,
    Object? page = null,
    Object? pageSize = null,
    Object? totalPosts = null,
    Object? totalPages = null,
  }) {
    return _then(_$GetOtherUserProfilePostImpl(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      data: null == data
          ? _value._data
          : data // ignore: cast_nullable_to_non_nullable
              as List<GetOtherUserProfilePostData>,
      page: null == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int,
      pageSize: null == pageSize
          ? _value.pageSize
          : pageSize // ignore: cast_nullable_to_non_nullable
              as int,
      totalPosts: null == totalPosts
          ? _value.totalPosts
          : totalPosts // ignore: cast_nullable_to_non_nullable
              as int,
      totalPages: null == totalPages
          ? _value.totalPages
          : totalPages // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GetOtherUserProfilePostImpl implements _GetOtherUserProfilePost {
  const _$GetOtherUserProfilePostImpl(
      {required this.success,
      required final List<GetOtherUserProfilePostData> data,
      required this.page,
      required this.pageSize,
      this.totalPosts = 0,
      this.totalPages = 0})
      : _data = data;

  factory _$GetOtherUserProfilePostImpl.fromJson(Map<String, dynamic> json) =>
      _$$GetOtherUserProfilePostImplFromJson(json);

  @override
  final bool success;
  final List<GetOtherUserProfilePostData> _data;
  @override
  List<GetOtherUserProfilePostData> get data {
    if (_data is EqualUnmodifiableListView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_data);
  }

  @override
  final int page;
  @override
  final int pageSize;
  @override
  @JsonKey()
  final int totalPosts;
  @override
  @JsonKey()
  final int totalPages;

  @override
  String toString() {
    return 'GetOtherUserProfilePost(success: $success, data: $data, page: $page, pageSize: $pageSize, totalPosts: $totalPosts, totalPages: $totalPages)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GetOtherUserProfilePostImpl &&
            (identical(other.success, success) || other.success == success) &&
            const DeepCollectionEquality().equals(other._data, _data) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.pageSize, pageSize) ||
                other.pageSize == pageSize) &&
            (identical(other.totalPosts, totalPosts) ||
                other.totalPosts == totalPosts) &&
            (identical(other.totalPages, totalPages) ||
                other.totalPages == totalPages));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      success,
      const DeepCollectionEquality().hash(_data),
      page,
      pageSize,
      totalPosts,
      totalPages);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GetOtherUserProfilePostImplCopyWith<_$GetOtherUserProfilePostImpl>
      get copyWith => __$$GetOtherUserProfilePostImplCopyWithImpl<
          _$GetOtherUserProfilePostImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GetOtherUserProfilePostImplToJson(
      this,
    );
  }
}

abstract class _GetOtherUserProfilePost implements GetOtherUserProfilePost {
  const factory _GetOtherUserProfilePost(
      {required final bool success,
      required final List<GetOtherUserProfilePostData> data,
      required final int page,
      required final int pageSize,
      final int totalPosts,
      final int totalPages}) = _$GetOtherUserProfilePostImpl;

  factory _GetOtherUserProfilePost.fromJson(Map<String, dynamic> json) =
      _$GetOtherUserProfilePostImpl.fromJson;

  @override
  bool get success;
  @override
  List<GetOtherUserProfilePostData> get data;
  @override
  int get page;
  @override
  int get pageSize;
  @override
  int get totalPosts;
  @override
  int get totalPages;
  @override
  @JsonKey(ignore: true)
  _$$GetOtherUserProfilePostImplCopyWith<_$GetOtherUserProfilePostImpl>
      get copyWith => throw _privateConstructorUsedError;
}

GetOtherUserProfilePostData _$GetOtherUserProfilePostDataFromJson(
    Map<String, dynamic> json) {
  return _GetOtherUserProfilePostData.fromJson(json);
}

/// @nodoc
mixin _$GetOtherUserProfilePostData {
  @JsonKey(name: '_id')
  String get id => throw _privateConstructorUsedError;
  MyUser get user => throw _privateConstructorUsedError;
  String? get content => throw _privateConstructorUsedError;
  List<String?> get media => throw _privateConstructorUsedError;
  List<String> get likes => throw _privateConstructorUsedError;
  List<String> get shares => throw _privateConstructorUsedError;
  List<String> get bookmarks => throw _privateConstructorUsedError;
  List<String?> get tags => throw _privateConstructorUsedError;
  String? get sharedFrom => throw _privateConstructorUsedError;
  String get privacy => throw _privateConstructorUsedError;
  @JsonKey(name: 'views')
  int get views => throw _privateConstructorUsedError;
  @JsonKey(name: 'commentCount')
  int get commentCount => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  bool get allowComment => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GetOtherUserProfilePostDataCopyWith<GetOtherUserProfilePostData>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GetOtherUserProfilePostDataCopyWith<$Res> {
  factory $GetOtherUserProfilePostDataCopyWith(
          GetOtherUserProfilePostData value,
          $Res Function(GetOtherUserProfilePostData) then) =
      _$GetOtherUserProfilePostDataCopyWithImpl<$Res,
          GetOtherUserProfilePostData>;
  @useResult
  $Res call(
      {@JsonKey(name: '_id') String id,
      MyUser user,
      String? content,
      List<String?> media,
      List<String> likes,
      List<String> shares,
      List<String> bookmarks,
      List<String?> tags,
      String? sharedFrom,
      String privacy,
      @JsonKey(name: 'views') int views,
      @JsonKey(name: 'commentCount') int commentCount,
      DateTime createdAt,
      DateTime updatedAt,
      bool allowComment});

  $MyUserCopyWith<$Res> get user;
}

/// @nodoc
class _$GetOtherUserProfilePostDataCopyWithImpl<$Res,
        $Val extends GetOtherUserProfilePostData>
    implements $GetOtherUserProfilePostDataCopyWith<$Res> {
  _$GetOtherUserProfilePostDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? user = null,
    Object? content = freezed,
    Object? media = null,
    Object? likes = null,
    Object? shares = null,
    Object? bookmarks = null,
    Object? tags = null,
    Object? sharedFrom = freezed,
    Object? privacy = null,
    Object? views = null,
    Object? commentCount = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? allowComment = null,
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
      content: freezed == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String?,
      media: null == media
          ? _value.media
          : media // ignore: cast_nullable_to_non_nullable
              as List<String?>,
      likes: null == likes
          ? _value.likes
          : likes // ignore: cast_nullable_to_non_nullable
              as List<String>,
      shares: null == shares
          ? _value.shares
          : shares // ignore: cast_nullable_to_non_nullable
              as List<String>,
      bookmarks: null == bookmarks
          ? _value.bookmarks
          : bookmarks // ignore: cast_nullable_to_non_nullable
              as List<String>,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String?>,
      sharedFrom: freezed == sharedFrom
          ? _value.sharedFrom
          : sharedFrom // ignore: cast_nullable_to_non_nullable
              as String?,
      privacy: null == privacy
          ? _value.privacy
          : privacy // ignore: cast_nullable_to_non_nullable
              as String,
      views: null == views
          ? _value.views
          : views // ignore: cast_nullable_to_non_nullable
              as int,
      commentCount: null == commentCount
          ? _value.commentCount
          : commentCount // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      allowComment: null == allowComment
          ? _value.allowComment
          : allowComment // ignore: cast_nullable_to_non_nullable
              as bool,
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
abstract class _$$GetOtherUserProfilePostDataImplCopyWith<$Res>
    implements $GetOtherUserProfilePostDataCopyWith<$Res> {
  factory _$$GetOtherUserProfilePostDataImplCopyWith(
          _$GetOtherUserProfilePostDataImpl value,
          $Res Function(_$GetOtherUserProfilePostDataImpl) then) =
      __$$GetOtherUserProfilePostDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: '_id') String id,
      MyUser user,
      String? content,
      List<String?> media,
      List<String> likes,
      List<String> shares,
      List<String> bookmarks,
      List<String?> tags,
      String? sharedFrom,
      String privacy,
      @JsonKey(name: 'views') int views,
      @JsonKey(name: 'commentCount') int commentCount,
      DateTime createdAt,
      DateTime updatedAt,
      bool allowComment});

  @override
  $MyUserCopyWith<$Res> get user;
}

/// @nodoc
class __$$GetOtherUserProfilePostDataImplCopyWithImpl<$Res>
    extends _$GetOtherUserProfilePostDataCopyWithImpl<$Res,
        _$GetOtherUserProfilePostDataImpl>
    implements _$$GetOtherUserProfilePostDataImplCopyWith<$Res> {
  __$$GetOtherUserProfilePostDataImplCopyWithImpl(
      _$GetOtherUserProfilePostDataImpl _value,
      $Res Function(_$GetOtherUserProfilePostDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? user = null,
    Object? content = freezed,
    Object? media = null,
    Object? likes = null,
    Object? shares = null,
    Object? bookmarks = null,
    Object? tags = null,
    Object? sharedFrom = freezed,
    Object? privacy = null,
    Object? views = null,
    Object? commentCount = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? allowComment = null,
  }) {
    return _then(_$GetOtherUserProfilePostDataImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as MyUser,
      content: freezed == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String?,
      media: null == media
          ? _value._media
          : media // ignore: cast_nullable_to_non_nullable
              as List<String?>,
      likes: null == likes
          ? _value._likes
          : likes // ignore: cast_nullable_to_non_nullable
              as List<String>,
      shares: null == shares
          ? _value._shares
          : shares // ignore: cast_nullable_to_non_nullable
              as List<String>,
      bookmarks: null == bookmarks
          ? _value._bookmarks
          : bookmarks // ignore: cast_nullable_to_non_nullable
              as List<String>,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String?>,
      sharedFrom: freezed == sharedFrom
          ? _value.sharedFrom
          : sharedFrom // ignore: cast_nullable_to_non_nullable
              as String?,
      privacy: null == privacy
          ? _value.privacy
          : privacy // ignore: cast_nullable_to_non_nullable
              as String,
      views: null == views
          ? _value.views
          : views // ignore: cast_nullable_to_non_nullable
              as int,
      commentCount: null == commentCount
          ? _value.commentCount
          : commentCount // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      allowComment: null == allowComment
          ? _value.allowComment
          : allowComment // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GetOtherUserProfilePostDataImpl
    implements _GetOtherUserProfilePostData {
  const _$GetOtherUserProfilePostDataImpl(
      {@JsonKey(name: '_id') required this.id,
      required this.user,
      this.content,
      final List<String?> media = const [],
      final List<String> likes = const [],
      final List<String> shares = const [],
      final List<String> bookmarks = const [],
      final List<String?> tags = const [],
      this.sharedFrom,
      required this.privacy,
      @JsonKey(name: 'views') this.views = 0,
      @JsonKey(name: 'commentCount') this.commentCount = 0,
      required this.createdAt,
      required this.updatedAt,
      this.allowComment = true})
      : _media = media,
        _likes = likes,
        _shares = shares,
        _bookmarks = bookmarks,
        _tags = tags;

  factory _$GetOtherUserProfilePostDataImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$GetOtherUserProfilePostDataImplFromJson(json);

  @override
  @JsonKey(name: '_id')
  final String id;
  @override
  final MyUser user;
  @override
  final String? content;
  final List<String?> _media;
  @override
  @JsonKey()
  List<String?> get media {
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

  final List<String> _bookmarks;
  @override
  @JsonKey()
  List<String> get bookmarks {
    if (_bookmarks is EqualUnmodifiableListView) return _bookmarks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_bookmarks);
  }

  final List<String?> _tags;
  @override
  @JsonKey()
  List<String?> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  final String? sharedFrom;
  @override
  final String privacy;
  @override
  @JsonKey(name: 'views')
  final int views;
  @override
  @JsonKey(name: 'commentCount')
  final int commentCount;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  @JsonKey()
  final bool allowComment;

  @override
  String toString() {
    return 'GetOtherUserProfilePostData(id: $id, user: $user, content: $content, media: $media, likes: $likes, shares: $shares, bookmarks: $bookmarks, tags: $tags, sharedFrom: $sharedFrom, privacy: $privacy, views: $views, commentCount: $commentCount, createdAt: $createdAt, updatedAt: $updatedAt, allowComment: $allowComment)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GetOtherUserProfilePostDataImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.content, content) || other.content == content) &&
            const DeepCollectionEquality().equals(other._media, _media) &&
            const DeepCollectionEquality().equals(other._likes, _likes) &&
            const DeepCollectionEquality().equals(other._shares, _shares) &&
            const DeepCollectionEquality()
                .equals(other._bookmarks, _bookmarks) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.sharedFrom, sharedFrom) ||
                other.sharedFrom == sharedFrom) &&
            (identical(other.privacy, privacy) || other.privacy == privacy) &&
            (identical(other.views, views) || other.views == views) &&
            (identical(other.commentCount, commentCount) ||
                other.commentCount == commentCount) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.allowComment, allowComment) ||
                other.allowComment == allowComment));
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
      const DeepCollectionEquality().hash(_bookmarks),
      const DeepCollectionEquality().hash(_tags),
      sharedFrom,
      privacy,
      views,
      commentCount,
      createdAt,
      updatedAt,
      allowComment);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GetOtherUserProfilePostDataImplCopyWith<_$GetOtherUserProfilePostDataImpl>
      get copyWith => __$$GetOtherUserProfilePostDataImplCopyWithImpl<
          _$GetOtherUserProfilePostDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GetOtherUserProfilePostDataImplToJson(
      this,
    );
  }
}

abstract class _GetOtherUserProfilePostData
    implements GetOtherUserProfilePostData {
  const factory _GetOtherUserProfilePostData(
      {@JsonKey(name: '_id') required final String id,
      required final MyUser user,
      final String? content,
      final List<String?> media,
      final List<String> likes,
      final List<String> shares,
      final List<String> bookmarks,
      final List<String?> tags,
      final String? sharedFrom,
      required final String privacy,
      @JsonKey(name: 'views') final int views,
      @JsonKey(name: 'commentCount') final int commentCount,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      final bool allowComment}) = _$GetOtherUserProfilePostDataImpl;

  factory _GetOtherUserProfilePostData.fromJson(Map<String, dynamic> json) =
      _$GetOtherUserProfilePostDataImpl.fromJson;

  @override
  @JsonKey(name: '_id')
  String get id;
  @override
  MyUser get user;
  @override
  String? get content;
  @override
  List<String?> get media;
  @override
  List<String> get likes;
  @override
  List<String> get shares;
  @override
  List<String> get bookmarks;
  @override
  List<String?> get tags;
  @override
  String? get sharedFrom;
  @override
  String get privacy;
  @override
  @JsonKey(name: 'views')
  int get views;
  @override
  @JsonKey(name: 'commentCount')
  int get commentCount;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  bool get allowComment;
  @override
  @JsonKey(ignore: true)
  _$$GetOtherUserProfilePostDataImplCopyWith<_$GetOtherUserProfilePostDataImpl>
      get copyWith => throw _privateConstructorUsedError;
}
