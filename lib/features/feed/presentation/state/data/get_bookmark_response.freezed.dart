// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'get_bookmark_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

GetBookmarkResponse _$GetBookmarkResponseFromJson(Map<String, dynamic> json) {
  return _GetBookmarkResponse.fromJson(json);
}

/// @nodoc
mixin _$GetBookmarkResponse {
  bool get success => throw _privateConstructorUsedError;
  int get count => throw _privateConstructorUsedError;
  List<GetBookmarkResponseData> get data => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GetBookmarkResponseCopyWith<GetBookmarkResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GetBookmarkResponseCopyWith<$Res> {
  factory $GetBookmarkResponseCopyWith(
          GetBookmarkResponse value, $Res Function(GetBookmarkResponse) then) =
      _$GetBookmarkResponseCopyWithImpl<$Res, GetBookmarkResponse>;
  @useResult
  $Res call({bool success, int count, List<GetBookmarkResponseData> data});
}

/// @nodoc
class _$GetBookmarkResponseCopyWithImpl<$Res, $Val extends GetBookmarkResponse>
    implements $GetBookmarkResponseCopyWith<$Res> {
  _$GetBookmarkResponseCopyWithImpl(this._value, this._then);

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
              as List<GetBookmarkResponseData>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GetBookmarkResponseImplCopyWith<$Res>
    implements $GetBookmarkResponseCopyWith<$Res> {
  factory _$$GetBookmarkResponseImplCopyWith(_$GetBookmarkResponseImpl value,
          $Res Function(_$GetBookmarkResponseImpl) then) =
      __$$GetBookmarkResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool success, int count, List<GetBookmarkResponseData> data});
}

/// @nodoc
class __$$GetBookmarkResponseImplCopyWithImpl<$Res>
    extends _$GetBookmarkResponseCopyWithImpl<$Res, _$GetBookmarkResponseImpl>
    implements _$$GetBookmarkResponseImplCopyWith<$Res> {
  __$$GetBookmarkResponseImplCopyWithImpl(_$GetBookmarkResponseImpl _value,
      $Res Function(_$GetBookmarkResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? count = null,
    Object? data = null,
  }) {
    return _then(_$GetBookmarkResponseImpl(
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
              as List<GetBookmarkResponseData>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GetBookmarkResponseImpl implements _GetBookmarkResponse {
  const _$GetBookmarkResponseImpl(
      {required this.success,
      required this.count,
      required final List<GetBookmarkResponseData> data})
      : _data = data;

  factory _$GetBookmarkResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$GetBookmarkResponseImplFromJson(json);

  @override
  final bool success;
  @override
  final int count;
  final List<GetBookmarkResponseData> _data;
  @override
  List<GetBookmarkResponseData> get data {
    if (_data is EqualUnmodifiableListView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_data);
  }

  @override
  String toString() {
    return 'GetBookmarkResponse(success: $success, count: $count, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GetBookmarkResponseImpl &&
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
  _$$GetBookmarkResponseImplCopyWith<_$GetBookmarkResponseImpl> get copyWith =>
      __$$GetBookmarkResponseImplCopyWithImpl<_$GetBookmarkResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GetBookmarkResponseImplToJson(
      this,
    );
  }
}

abstract class _GetBookmarkResponse implements GetBookmarkResponse {
  const factory _GetBookmarkResponse(
          {required final bool success,
          required final int count,
          required final List<GetBookmarkResponseData> data}) =
      _$GetBookmarkResponseImpl;

  factory _GetBookmarkResponse.fromJson(Map<String, dynamic> json) =
      _$GetBookmarkResponseImpl.fromJson;

  @override
  bool get success;
  @override
  int get count;
  @override
  List<GetBookmarkResponseData> get data;
  @override
  @JsonKey(ignore: true)
  _$$GetBookmarkResponseImplCopyWith<_$GetBookmarkResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GetBookmarkResponseData _$GetBookmarkResponseDataFromJson(
    Map<String, dynamic> json) {
  return _GetBookmarkResponseData.fromJson(json);
}

/// @nodoc
mixin _$GetBookmarkResponseData {
  @JsonKey(name: '_id')
  String get id => throw _privateConstructorUsedError;
  MyUser get user => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _bookmarkMediaFromJson)
  List<String> get media => throw _privateConstructorUsedError;
  List<dynamic> get likes => throw _privateConstructorUsedError;
  List<dynamic> get shares => throw _privateConstructorUsedError;
  List<dynamic> get bookmarks => throw _privateConstructorUsedError;
  dynamic get sharedFrom => throw _privateConstructorUsedError;
  String get privacy => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;
  String get updatedAt => throw _privateConstructorUsedError;
  @JsonKey(name: '__v')
  int? get v => throw _privateConstructorUsedError;
  @JsonKey(name: 'commentCount')
  int get commentCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'id')
  String? get bookMarkId => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GetBookmarkResponseDataCopyWith<GetBookmarkResponseData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GetBookmarkResponseDataCopyWith<$Res> {
  factory $GetBookmarkResponseDataCopyWith(GetBookmarkResponseData value,
          $Res Function(GetBookmarkResponseData) then) =
      _$GetBookmarkResponseDataCopyWithImpl<$Res, GetBookmarkResponseData>;
  @useResult
  $Res call(
      {@JsonKey(name: '_id') String id,
      MyUser user,
      String content,
      @JsonKey(fromJson: _bookmarkMediaFromJson) List<String> media,
      List<dynamic> likes,
      List<dynamic> shares,
      List<dynamic> bookmarks,
      dynamic sharedFrom,
      String privacy,
      String createdAt,
      String updatedAt,
      @JsonKey(name: '__v') int? v,
      @JsonKey(name: 'commentCount') int commentCount,
      @JsonKey(name: 'id') String? bookMarkId});

  $MyUserCopyWith<$Res> get user;
}

/// @nodoc
class _$GetBookmarkResponseDataCopyWithImpl<$Res,
        $Val extends GetBookmarkResponseData>
    implements $GetBookmarkResponseDataCopyWith<$Res> {
  _$GetBookmarkResponseDataCopyWithImpl(this._value, this._then);

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
    Object? sharedFrom = freezed,
    Object? privacy = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? v = freezed,
    Object? commentCount = null,
    Object? bookMarkId = freezed,
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
      bookMarkId: freezed == bookMarkId
          ? _value.bookMarkId
          : bookMarkId // ignore: cast_nullable_to_non_nullable
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
abstract class _$$GetBookmarkResponseDataImplCopyWith<$Res>
    implements $GetBookmarkResponseDataCopyWith<$Res> {
  factory _$$GetBookmarkResponseDataImplCopyWith(
          _$GetBookmarkResponseDataImpl value,
          $Res Function(_$GetBookmarkResponseDataImpl) then) =
      __$$GetBookmarkResponseDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: '_id') String id,
      MyUser user,
      String content,
      @JsonKey(fromJson: _bookmarkMediaFromJson) List<String> media,
      List<dynamic> likes,
      List<dynamic> shares,
      List<dynamic> bookmarks,
      dynamic sharedFrom,
      String privacy,
      String createdAt,
      String updatedAt,
      @JsonKey(name: '__v') int? v,
      @JsonKey(name: 'commentCount') int commentCount,
      @JsonKey(name: 'id') String? bookMarkId});

  @override
  $MyUserCopyWith<$Res> get user;
}

/// @nodoc
class __$$GetBookmarkResponseDataImplCopyWithImpl<$Res>
    extends _$GetBookmarkResponseDataCopyWithImpl<$Res,
        _$GetBookmarkResponseDataImpl>
    implements _$$GetBookmarkResponseDataImplCopyWith<$Res> {
  __$$GetBookmarkResponseDataImplCopyWithImpl(
      _$GetBookmarkResponseDataImpl _value,
      $Res Function(_$GetBookmarkResponseDataImpl) _then)
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
    Object? sharedFrom = freezed,
    Object? privacy = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? v = freezed,
    Object? commentCount = null,
    Object? bookMarkId = freezed,
  }) {
    return _then(_$GetBookmarkResponseDataImpl(
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
      bookMarkId: freezed == bookMarkId
          ? _value.bookMarkId
          : bookMarkId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GetBookmarkResponseDataImpl implements _GetBookmarkResponseData {
  const _$GetBookmarkResponseDataImpl(
      {@JsonKey(name: '_id') required this.id,
      required this.user,
      this.content = '',
      @JsonKey(fromJson: _bookmarkMediaFromJson)
      final List<String> media = const [],
      final List<dynamic> likes = const [],
      final List<dynamic> shares = const [],
      final List<dynamic> bookmarks = const [],
      this.sharedFrom,
      this.privacy = 'everyone',
      required this.createdAt,
      required this.updatedAt,
      @JsonKey(name: '__v') this.v,
      @JsonKey(name: 'commentCount') this.commentCount = 0,
      @JsonKey(name: 'id') this.bookMarkId})
      : _media = media,
        _likes = likes,
        _shares = shares,
        _bookmarks = bookmarks;

  factory _$GetBookmarkResponseDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$GetBookmarkResponseDataImplFromJson(json);

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
  @JsonKey(fromJson: _bookmarkMediaFromJson)
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
  final dynamic sharedFrom;
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
  final String? bookMarkId;

  @override
  String toString() {
    return 'GetBookmarkResponseData(id: $id, user: $user, content: $content, media: $media, likes: $likes, shares: $shares, bookmarks: $bookmarks, sharedFrom: $sharedFrom, privacy: $privacy, createdAt: $createdAt, updatedAt: $updatedAt, v: $v, commentCount: $commentCount, bookMarkId: $bookMarkId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GetBookmarkResponseDataImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.content, content) || other.content == content) &&
            const DeepCollectionEquality().equals(other._media, _media) &&
            const DeepCollectionEquality().equals(other._likes, _likes) &&
            const DeepCollectionEquality().equals(other._shares, _shares) &&
            const DeepCollectionEquality()
                .equals(other._bookmarks, _bookmarks) &&
            const DeepCollectionEquality()
                .equals(other.sharedFrom, sharedFrom) &&
            (identical(other.privacy, privacy) || other.privacy == privacy) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.v, v) || other.v == v) &&
            (identical(other.commentCount, commentCount) ||
                other.commentCount == commentCount) &&
            (identical(other.bookMarkId, bookMarkId) ||
                other.bookMarkId == bookMarkId));
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
      const DeepCollectionEquality().hash(sharedFrom),
      privacy,
      createdAt,
      updatedAt,
      v,
      commentCount,
      bookMarkId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GetBookmarkResponseDataImplCopyWith<_$GetBookmarkResponseDataImpl>
      get copyWith => __$$GetBookmarkResponseDataImplCopyWithImpl<
          _$GetBookmarkResponseDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GetBookmarkResponseDataImplToJson(
      this,
    );
  }
}

abstract class _GetBookmarkResponseData implements GetBookmarkResponseData {
  const factory _GetBookmarkResponseData(
          {@JsonKey(name: '_id') required final String id,
          required final MyUser user,
          final String content,
          @JsonKey(fromJson: _bookmarkMediaFromJson) final List<String> media,
          final List<dynamic> likes,
          final List<dynamic> shares,
          final List<dynamic> bookmarks,
          final dynamic sharedFrom,
          final String privacy,
          required final String createdAt,
          required final String updatedAt,
          @JsonKey(name: '__v') final int? v,
          @JsonKey(name: 'commentCount') final int commentCount,
          @JsonKey(name: 'id') final String? bookMarkId}) =
      _$GetBookmarkResponseDataImpl;

  factory _GetBookmarkResponseData.fromJson(Map<String, dynamic> json) =
      _$GetBookmarkResponseDataImpl.fromJson;

  @override
  @JsonKey(name: '_id')
  String get id;
  @override
  MyUser get user;
  @override
  String get content;
  @override
  @JsonKey(fromJson: _bookmarkMediaFromJson)
  List<String> get media;
  @override
  List<dynamic> get likes;
  @override
  List<dynamic> get shares;
  @override
  List<dynamic> get bookmarks;
  @override
  dynamic get sharedFrom;
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
  String? get bookMarkId;
  @override
  @JsonKey(ignore: true)
  _$$GetBookmarkResponseDataImplCopyWith<_$GetBookmarkResponseDataImpl>
      get copyWith => throw _privateConstructorUsedError;
}
